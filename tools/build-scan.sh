#!/bin/bash
# Copyright 2023 Canonical Ltd.
# See LICENSE file for licensing details.
#
# Build and scan all images one by one.
# Images are built, scanned, and removed to save space.
# Old Trivy reports and summaries are removed prior to scan.
# By default scanned images are cleaned up after every scan. Set CLEANUP_IMAGES to "false" to
# disable image cleanup.
#
# Usage: build-scan.sh
#
set -e

CLEANUP_IMAGES=true

# Kubeflow container images build and scan
echo "Build and scan ROCKs for Kubeflow"

COMPONENTS_LIST=(
"centraldashboard"
"jupyter-pytorch-full"
"notebook-controller"
)

# remove scan summary file and trivy-reports/
rm -f scan-summary.txt
rm -rf ./trivy-reports/
mkdir -p ./trivy-reports/

# perform build and scan for each components
for COMPONENT in "${COMPONENTS_LIST[@]}"; do
	cd "$COMPONENT"
	NAME=$(yq eval ".name" rockcraft.yaml)
	VERSION=$(yq eval ".version" rockcraft.yaml)
	ARCH=$(yq eval ".platforms | keys" rockcraft.yaml | awk -F ' ' '{print $2}')
        ROCK="${NAME}_${VERSION}_${ARCH}"

	echo "Build $ROCK for component $COMPONENT"
	rockcraft pack
	echo "Copy $ROCK to Docker"
	sudo skopeo --insecure-policy copy oci-archive:$ROCK.rock docker-daemon:$ROCK:$VERSION
	cd -

	echo "Scan $ROCK:$VERSION"
	docker run -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:`pwd` -w `pwd` aquasec/trivy image --timeout 20m -f json -o trivy-report/$ROCK.json --ignore-unfixed $ROCK:$VERSION

        if [ "$CLEANUP_IMAGES" != true ]; then
                continue
        fi

	echo "Clean up scanned image"
	docker rmi $ROCK:$VERSION
done

echo "Cleanup running containers and intermediate images"
# stop and remove all running containers
set +e
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images --filter=dangling=true -q) 2>/dev/null
set -e

# End of Kubeflow container images build and scan

echo "Done."

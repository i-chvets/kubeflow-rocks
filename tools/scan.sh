#!/bin/bash
# Copyright 2023 Canonical Ltd.
# See LICENSE file for licensing details.
#
# Scan all image based on rockcraft.yaml
#
# Usage: scan.sh
#
set -e

# Kubeflow container images scan
echo "Scan ROCKs for Kubeflow"
NAME=$(yq eval ".name" rockcraft.yaml)
VERSION=$(yq eval ".version" rockcraft.yaml)
ARCH=$(yq eval ".platforms | keys" rockcraft.yaml | awk -F ' ' '{print $2}')
ROCK="${NAME}_${VERSION}_${ARCH}"
sudo skopeo --insecure-policy copy oci-archive:$ROCK.rock docker-daemon:$ROCK:$VERSION
echo "Scan $ROCK:$VERSION"
docker run -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:`pwd` -w `pwd` aquasec/trivy image --timeout 20m -f json -o trivy-reports/$ROCK.json --ignore-unfixed $ROCK:$VERSION

# End of Kubeflow container images build and scan

echo "Done."

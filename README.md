# Kubeflow ROCKs

Collection of ROCKs for Kubeflow components.

# Development notes
- Rockcraft tutorial:
  https://canonical-rockcraft.readthedocs-hosted.com/en/latest/tutorials.html
- Example:
  https://github.com/jnsgruk/seldon-core-operator-rock
- Use `stage-packages` to install required packages for application to run.
- Use `build-evironment` to setup environment variables for build stage.
- Use `build-packages` and `build-snaps` for build stage. Those will not be used by application. As a result, if build and application require the same package, it needs to be in both `build-packages` and `stage-packages`
- If issues with LXD/Docker arise review firewall setup:
  https://linuxcontainers.org/lxd/docs/master/howto/network_bridge_firewalld/
- While building ROCKs these commands are very helpful:
  ```
  rockcraft clean
  lxc --project rockcraft image list
  ```

# Building ROCKs

## centraldashboard

To build ROCK image of `centraldashboard` (version 1.6.0):
```
cd components/centraldashboard/
rockcraft pack
```

To copy resulting image `kubeflow-central-dashboard_1.6.0_amd64:rock` to Docker:
```
sudo skopeo --insecure-policy copy oci-archive:kubeflow-central-dashboard_1.6.0_amd64.rock docker-daemon:kubeflow-central-dashboard_1.6.0_amd64:rock
```

# Testing

## centraldashboard

- After copying image to Docker using `skopeo`, run it:
  ```
  docker run -p 8082:8082 -p 8080:8080 kubeflow-central-dashboard_1.6.0_amd64:rock
  ```
- Then navigate to `http://localhost:8082/`. UI should be displayed.

# Kubeflow ROCKs

Collection of ROCKs for Kubeflow components.

# Development notes
- Rockcraft tutorial:
  https://canonical-rockcraft.readthedocs-hosted.com/en/latest/tutorials.html
- Example:
  https://github.com/jnsgruk/seldon-core-operator-rock
- Use `stage-packages` to install required packages for application to run.
- Use `build-environment` to setup environment variables for build stage.
- Entry point in ROCK is Pebble. At this point there is no way to specify other entry point. To start container, a Pebble layer is added via adding `001-deafault.yaml` file to `/var/lib/pebble/default/layers/`. Refer to source code for more details.

# Building ROCKs

To build ROCK images for Kubeflow components:
```
cd <image-directory>
rockcraft pack
```

# Testing

# Building ROCKs

## centraldashboard

To build ROCK image of `centraldashboard` (version 1.6.0):
```

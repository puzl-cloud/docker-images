# tensorflow-2 Docker image

Tensorflow (version 2) ML framework with various python runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official tensorflow](https://hub.docker.com/r/tensorflow/tensorflow) Docker image.
## Supported languages and interpreter versions
- python3.10
- python3.11

## Installed packages
### OS
- rclone
- conda
- openssh-server
- rsync
- cuda, version 11.8

### Python
- [tensorflow-gpu](https://pypi.org/project/tensorflow-gpu/), version 2.14.0
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 4.0.7


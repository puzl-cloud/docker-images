# keras Docker image

Keras ML framework with various python runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official tensorflow](https://hub.docker.com/r/tensorflow/tensorflow) Docker image.
## Supported languages and interpreter versions
- python3.7
- python3.8
- python3.9

## Installed packages
### OS
- rclone
- conda
- openssh-server
- rsync
- cuda, version 11.2

### Python
- [tensorflow-gpu](https://pypi.org/project/tensorflow-gpu/), version 2.7.0
- [keras](https://pypi.org/project/keras/), version 2.7.0
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 3.2.5



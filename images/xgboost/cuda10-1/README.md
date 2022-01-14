# xgboost Docker image

Xgboost ML library for various python runtime.

Non-root Docker image used by puzl.ee [cloud Kubernetes](https://puzl.ee) service. Based on [official tensorflow](https://hub.docker.com/r/tensorflow/tensorflow) Docker image.
## Supported languages and interpreter versions
- python3.6
- python3.7
- python3.8

## Installed packages
### OS
- rclone
- conda
- openssh-server
- rsync

### Python
- [tensorflow-gpu](https://pypi.org/project/tensorflow-gpu/), version 2.3.0
- [xgboost](https://pypi.org/project/xgboost/), version 1.2.0
- [jupyterlab](https://pypi.org/project/jupyterlab/)

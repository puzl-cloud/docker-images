# xgboost Docker image

Xgboost ML library for various python runtime.

Non-root Docker image used by puzl.ee [cloud Kubernetes](https://puzl.ee) service. Based on [official tensorflow](https://hub.docker.com/r/tensorflow/tensorflow) Docker image.
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

### Python
- [tensorflow-gpu](https://pypi.org/project/tensorflow-gpu/), version 2.7.0
- [xgboost](https://pypi.org/project/xgboost/), version 1.5.1
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 3.2.5

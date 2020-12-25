# h2o4gpu Docker image

H2O ML framework with GPU support and various python runtime.

Non-root Docker image used by puzl.ee [cloud Kubernetes](https://puzl.ee) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
## Supported languages and interpreter versions
- python3.6
- python3.7

## Installed packages
### OS
- caffe2
- rclone
- conda
- openssh-server
- rsync

### Python
- [jupyterlab](https://pypi.org/project/jupyterlab/)
- [h2o4gpu](https://pypi.org/project/h2o4gpu/), version 0.4.1

# fastai Docker image

Fast.ai ML framework with various python runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
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
- cuda, version 10.1

### Python
- [torch](https://pypi.org/project/torch/), version 1.6.0
- [torchvision](https://pypi.org/project/torchvision/), version 0.7.0
- [fastai](https://pypi.org/project/fastai/), version 2.0.8
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 3.0.5



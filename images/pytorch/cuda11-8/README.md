# pytorch Docker image

Pytorch ML framework with various python runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
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
- [torch](https://pypi.org/project/torch/), version 2.1.0
- [torchvision](https://pypi.org/project/torchvision/), version 0.16.0
- [torchaudio](https://pypi.org/project/torchaudio/), version 2.1.0
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 4.0.7


# fastai Docker image

Fast.ai ML framework with various python runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
## Supported languages and interpreter versions
- python3.7
- python3.8

## Installed packages
### OS
- rclone
- conda
- openssh-server
- rsync
- cuda, version 11.3

### Python
- [torch](https://pypi.org/project/torch/), version 1.10.1+cu113
- [torchvision](https://pypi.org/project/torchvision/), version 0.11.2+cu113
- [torchaudio](https://pypi.org/project/torchaudio/), version 0.10.1+cu113
- [fastai](https://pypi.org/project/fastai/), version 2.5.3
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 3.2.5



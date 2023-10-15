# fastai Docker image

Fast.ai ML framework with various python runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
## Supported languages and interpreter versions
- python3.9
- python3.10

## Installed packages
### OS
- rclone
- conda
- openssh-server
- rsync
- cuda, version 11.8

### Python
- [torch](https://pypi.org/project/torch/), version 2.0.1
- [torchvision](https://pypi.org/project/torchvision/), version 0.15.2
- [torchaudio](https://pypi.org/project/torchaudio/), version 2.0.1
- [fastai](https://pypi.org/project/fastai/), version 2.7.13
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 4.0.7



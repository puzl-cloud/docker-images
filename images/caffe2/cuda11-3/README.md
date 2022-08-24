# caffe2 Docker image

Caffe2 ML framework with various python runtime.

Non-root Docker image used by puzl.ee [cloud Kubernetes](https://puzl.ee) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
## Supported languages and interpreter versions
- python3.7
- python3.8

## Installed packages
### OS
- caffe2
- rclone
- conda
- openssh-server
- rsync

### Python
- [torch](https://pypi.org/project/torch/), version 1.10.1+cu113
- [torchvision](https://pypi.org/project/torchvision/), version 0.11.2+cu113
- [torchaudio](https://pypi.org/project/torchaudio/), version 0.10.1+cu113
- [jupyterlab](https://pypi.org/project/jupyterlab/), version 3.2.5
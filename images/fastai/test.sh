#!/usr/bin/env bash

set -e

#Check python
python --version && python3 --version

#Check jupyter 
jupyter --version

#Check pip
pip --version

#Check conda
conda --version

#Check rclone
rclone --version

#Check ssh
ssh -V

#Check torch
python -c 'import torch; print("torch_version = ",torch.__version__)' \
  && python3 -c 'import torch; print("torch_version =",torch.__version__)'

#Check fastai
python -c 'import fastai; print("fastai_version = ",fastai.__version__)' \
  && python3 -c 'import fastai; print("fastai_version = ",fastai.__version__)'

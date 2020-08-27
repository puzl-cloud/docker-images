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
python -c "import torch" && python3 -c "import torch"

#Check torchvision
python -c "import torchvision" && python3 -c "import torchvision"

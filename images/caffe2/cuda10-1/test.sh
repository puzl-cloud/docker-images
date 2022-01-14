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

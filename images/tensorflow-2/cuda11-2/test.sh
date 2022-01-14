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

#Check tensorflow
python -c 'import tensorflow as tf; print(tf.__version__)' \
  && python3 -c 'import tensorflow as tf; print(tf.__version__)'

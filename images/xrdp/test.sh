#!/usr/bin/env bash

set -e

#Check python
python --version && python3 --version

#Check pip
pip --version

#Check conda
conda --version

#Check xrpd
xrdp --version

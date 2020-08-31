#Check torch
python -c 'import torch; print("torch_version = ",torch.__version__)' \
  && python3 -c 'import torch; print("torch_version =",torch.__version__)'

#Check torchvision
python -c 'import torchvision; print("torchvision_version =",torchvision.__version__)' \
  && python3 -c 'import torchvision; print("torchvision_version =",torchvision.__version__)'

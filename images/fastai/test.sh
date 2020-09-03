#Check torch
python -c 'import torch; print("torch_version = ",torch.__version__)' \
  && python3 -c 'import torch; print("torch_version =",torch.__version__)'

#Check fastai
python -c 'import fastai; print("fastai_version = ",fastai.__version__)' \
  && python3 -c 'import fastai; print("fastai_version = ",fastai.__version__)'

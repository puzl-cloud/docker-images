# tensorflowjs Docker image

Tensorflow (version 2) ML framework with node.js runtime.

Non-root Docker image used by Puzl [Kubernetes cloud](https://puzl.cloud) service. Based on [official cuda](https://hub.docker.com/r/nvidia/cuda) Docker image.
## Supported languages and interpreter versions
- nodejs12

## Installed packages
### OS
- rclone
- openssh-server
- rsync
- cuda, version 10.1


### JavaScript

- [@tensorflow/tfjs](https://www.npmjs.com/package/@tensorflow/tfjs/), version 2.0.1
- [@tensorflow/tfjs-node-gpu](https://www.npmjs.com/package/@tensorflow/tfjs-node-gpu/), version 2.0.1


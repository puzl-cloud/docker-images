![CI](https://github.com/puzl-ee/docker-images/workflows/CI/badge.svg)

# Puzl Docker images
Set of bash scripts and Jinja templates used to automatically build and push Docker images, which are using on [puzl.ee](https://puzl.ee).

## What for?
On Puzl, we have [cloud app Marketplace](https://puzl.ee/cloud-marketplace) that contains various apps. Some of these apps may require the similar environment to run, some of them not. We want to know, which Docker image can be used to run which application.

## Metadata-first approach
1. We use GitOps way to manage Docker images. All Dockerfiles sources are stored in one repo (this) and managed centrally.
1. For each Docker image we use metadata file to describe the packages installed inside. This metadata lets us match images and applications.
1. We use the same metadata file to generate final Dockerfile by Jinja template automatically. This helps us to not miss any package, if Dockerfile was changed: it simply can not be changed without changing its metadata.

## Repo
### Structure
```
.
├── deploy - CI scripts
│   └── functions
├── githooks - Git scripts
├── globals - Global settings
├── images - each folder inside contains sources and compiled Dockerfile for some Docker image
│   ├── caffe2
|       ├── dockerfile.j2 - Jinja template of Dockerfile
|       ├── metadata.json - metadata of this Docker image used as variables for .j2 template at the same time
|       ├── test.sh - integration test of built Docker image
|       ├── README.md - readme file to show on Docker Hub
|       └── Dockerfile - Dockerfile built from .j2 template
│   ├── ...
└── template - basic Jinja templates to build Dockerfiles on them
    └── configs
```

### Requirements
  - docker
  - docker-compose
  - jq
  - jo
  - j2cli
  - hadolint
  - yq
 
## How does it work
### Generate Dockerfile
```bash
j2 -f json images/{image_name}/dockerfile.j2 images/{image_name}/metadata.json -o ./Dockerfile
```
### Build Docker image
```bash
docker build -t {image_name} .
```
### Run integration tests
```bash
bash deploy/functions/dockertest.sh images/{image_name}
```

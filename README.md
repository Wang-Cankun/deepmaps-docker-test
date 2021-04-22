# DeepMAPS-docker

## Prerequisite: nvidia-docker2

NVIDIA Container Toolkit is needed to enable GPU device access within Docker containers:
https://github.com/anibali/docker-pytorch

```{bash}
sudo yum install -y nvidia-docker2
sudo systemctl restart docker

# Follow the tutorial
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/user-guide.html

sudo pkill -SIGHUP dockerd

sudo tee /etc/docker/daemon.json <<EOF
{
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "default-runtime": "nvidia"
}
EOF

```

## Docker swarm

1. Enable ports 2377 and 2946

```{bash}
firewall-cmd --zone=public --add-port=2377/tcp --permanent
firewall-cmd --zone=public --add-port=2946/tcp --permanent
firewall-cmd --reload
```
## Python-api

### Base image

This base image contains all necessary for the package. Including PyTorch, PyTorch Geometric, Velocity, Lisa2


```{bash, eval=FALSE}
# Build
docker build -f Python-base.Dockerfile -t wangcankun100/deepmaps-python-base .

# Test
docker run wangcankun100/deepmaps-python-base

# Start Jupyter notebook
docker run -p 8888:8888 --gpus=all --ipc=host wangcankun100/deepmaps-python-base
docker run -p 8888:8888 --gpus=all --ipc=host wangcankun100/deepmaps-python-base jupyter notebook --allow-root --ip 0.0.0.0

# Push
docker push wangcankun100/deepmaps-python-base
```

### Client image

```{bash, eval=FALSE}
# Build
docker build -f Python-client.Dockerfile -t wangcankun100/deepmaps-python-client .

# Test
docker run wangcankun100/deepmaps-python-client

# Start Jupyter notebook
docker run -p 5000:5000 --gpus=all --ipc=host wangcankun100/deepmaps-python-client
docker run -p 8888:8888 --gpus=all --ipc=host wangcankun100/deepmaps-python-client jupyter notebook --allow-root --ip 0.0.0.0
docker run -p 5000:5000 --ipc=host wangcankun100/deepmaps-python-client

# Push
docker push wangcankun100/deepmaps-python-client
```

## R-api

We split the package to 2 containers, as it can speed up the build and deployment time (40 min ->  5 min).

To build the docker image, enter project root directory first.

#### Base image

This base image contains all necessary for the package. Including plumber, Seurat, Signac, tidyverse, BioConductor suite (GenomicRanges, SingleCellExperiment, etc.)

```{bash, eval=FALSE}
# Build
docker build -f R-base.Dockerfile -t wangcankun100/deepmaps-r-base .

# Test what packages are installed
docker run wangcankun100/deepmaps-r-base
```

#### Client image

This client image builds upon the deepmaps-api-base image. It will only install the R package itself.

```{bash, eval=FALSE}
# Build
docker build --no-cache -f R-client.Dockerfile -t wangcankun100/deepmaps-r-client .
docker push wangcankun100/deepmaps-r-client

# Deploy
docker pull wangcankun100/deepmaps-r-client
docker run -d -v /var/www/nodejs/data/:/data --name deepmaps-r-client -p 8000:8000 wangcankun100/deepmaps-r-client
docker logs deepmaps-r-client
docker restart deepmaps-r-client

# Run
docker run --rm -p 8000:8000 wangcankun100/deepmaps-r-client
docker run -v /var/www/nodejs/data/:/data -p 8000:8000 wangcankun100/deepmaps-r-client

```

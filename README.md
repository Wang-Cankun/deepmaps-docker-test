# DeepMAPS-docker

## Prerequisite: allow docker connection on remote

```{bash}
docker run --restart unless-stopped -p 2375:2375 -v /var/run/docker.sock:/var/run/docker.sock jarkt/docker-remote-api
```

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

1. Docker shared volume in multiple servers

```{bash}
docker run --rm -itd --name nfs \
  --restart unless-stopped \
  --privileged \
  -v /scratch/deepmaps-data:/data \
  -e SHARED_DIRECTORY=/data \
  -p 2049:2049 \
  itsthenetwork/nfs-server-alpine:latest

firewall-cmd --zone=public --add-port=2049/tcp --permanent
firewall-cmd --reload

sudo mount -v 10.94.2.224:/ /var/www/nodejs/deepmaps-data
sudo umount -l /var/www/nodejs/deepmaps-data

docker run -d -it --name test2 --mount type=volume,volume-driver=vieux/sshfs,source=cluster-volume,target=/data,volume-opt=sshcmd='wan268@10.82.14.183:/var/www/nodejs/deepmaps-data',volume-opt=password='862naw' wangcankun100/deepmaps-python-base

```

## Python-api

### Base image

This base image contains all necessary dependencies for DeepMAPS. Including PyTorch (1.7.0, CUDA11, GPU version), PyTorch Geometric, Velocity, Lisa2, etc.

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

We split the package to 2 containers, as it can speed up the build and deployment time (40 min -> 5 min).

To build the docker image, enter project root directory first.

### Base image

This base image contains all necessary for the package. Including plumber, Seurat, Signac, tidyverse, BioConductor suite (GenomicRanges, SingleCellExperiment, etc.)

```{bash, eval=FALSE}
# Build
docker build --progress=plain -f R-base.Dockerfile -t wangcankun100/deepmaps-r-base .

# Test what packages are installed
docker run wangcankun100/deepmaps-r-base

# Push
docker push wangcankun100/deepmaps-r-base
```

### Client image

This client image builds upon the deepmaps-api-base image. It will only install the R package itself.

```{bash, eval=FALSE}
# Build
docker build --progress=plain --no-cache -f R-client.Dockerfile -t wangcankun100/deepmaps-r-client .
docker push wangcankun100/deepmaps-r-client

# Deploy
docker pull wangcankun100/deepmaps-r-client

# manage
docker logs deepmaps-r-client
docker restart deepmaps-r-client

# Run
docker run -dv /var/www/nodejs/deepmaps-data:/data -p 8000:8000 wangcankun100/deepmaps-r-client
docker run -dv /home/wan268/deepmaps/data:/data -p 8000:8000 wangcankun100/deepmaps-r-client
docker run -dv /scratch/deepmaps/data:/data -p 8000:8000 wangcankun100/deepmaps-r-client

```

### Other images

```{bash, eval=FALSE}
# whoami
docker run -d -P -p 9000:80 --restart unless-stopped containous/whoami

```

deepmaps-docker

## Python-api

### Base image

```{bash, eval=FALSE}
# Build
docker build -f Python-base.Dockerfile -t wangcankun100/deepmaps-python-api-base .

# Test
docker run wangcankun100/deepmaps-python-api-base

# Start Jupyter notebook
docker run -p 8888:8888 --gpus=all --ipc=host wangcankun100/deepmaps-python-api-base 
docker run -p 8888:8888 wangcankun100/deepmaps-python-api-base jupyter notebook --allow-root --ip 0.0.0.0

# Push
docker push wangcankun100/deepmaps-python-api-base
```

## R-api
### Docker build

We split the package to 2 containers, as it can speed up the build and deployment time (40 min ->  5 min).

To build the docker image, enter project root directory first.

#### Base image

This base image contains all necessary for the package. Including plumber, Seurat, Signac, tidyverse, BioConductor suite (GenomicRanges, SingleCellExperiment, etc.)

```{bash, eval=FALSE}
# Build
docker build -f base.Dockerfile -t wangcankun100/deepmaps-api-base .

# Test what packages are installed
docker run wangcankun100/deepmaps-api-base
```

#### Client image

This client image builds upon the deepmaps-api-base image. It will only install the R package itself.

```{bash, eval=FALSE}
# Build
docker build --no-cache -f client.Dockerfile -t wangcankun100/deepmaps-api-client .
docker push wangcankun100/deepmaps-api-client

# Deploy
docker pull wangcankun100/deepmaps-api-client
docker run -d -v /var/www/nodejs/data/:/data --name deepmaps-api-client -p 8000:8000 wangcankun100/deepmaps-api-client
docker logs deepmaps-api-client
docker restart deepmaps-api-client

# Run
docker run --rm -p 8000:8000 wangcankun100/deepmaps-api-client
docker run -v /var/www/nodejs/data/:/data -p 8000:8000 wangcankun100/deepmaps-api-client

```

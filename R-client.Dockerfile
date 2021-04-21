FROM wangcankun100/deepmaps-r-base
LABEL maintainer="Cankun Wang <cankun.wang@osumc.edu>"

WORKDIR /tmp

# Install package, skip dependency and suggested packages

RUN installGithub.r -d FALSE -u FALSE\
	Wang-Cankun/iris3api@master

# Clean up installation
RUN rm -rf /tmp/* 
RUN rm -rf /var/lib/apt/lists/*

# Set up working directory
RUN mkdir /data
WORKDIR /data

# app.R is the entry to start API server
COPY app.R /data/app.R

# Copy example multiome data
# COPY inst/extdata/pbmc_match_3k.qsave /extdata/pbmc_match_3k.qsave

# Expose plumber API port inside docker
EXPOSE 8000

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
#ENTRYPOINT ["/tini", "--"]
ENTRYPOINT ["/tini", "--"]
# Default: Start R API server
CMD ["Rscript", "app.R"]

# Test running
# docker build -f client.Dockerfile -t wangcankun100/deepmaps-api-client .


FROM wangcankun100/deepmaps-r-base
LABEL maintainer="Cankun Wang <cankun.wang@osumc.edu>"

WORKDIR /tmp

# app.R is the entry to start API server
ADD https://raw.githubusercontent.com/Wang-Cankun/rDeepMAPS/master/app.R /app.R


# Install package, skip dependency and suggested packages

RUN installGithub.r -d FALSE -u FALSE\
	Wang-Cankun/iris3api@master

# Clean up installation
RUN rm -rf /tmp/* 
RUN rm -rf /var/lib/apt/lists/*

# Set up working directory
RUN mkdir /data
WORKDIR /data

# Expose plumber API port inside docker
EXPOSE 8000

ENTRYPOINT ["/tini", "--"]
# Default: Start R API server
CMD ["Rscript", "/app.R"]

# Test running
# docker build -f client.Dockerfile -t wangcankun100/deepmaps-api-client .


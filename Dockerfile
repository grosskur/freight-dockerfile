FROM ubuntu:14.04
MAINTAINER Alan Grosskurth <code@alan.grosskurth.ca>

RUN \
  locale-gen en_US.UTF-8 && \
  apt-get update && \
  env DEBIAN_FRONTEND=noninteractive apt-get -q -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git-core \
    libbz2-dev \
    libcurl4-openssl-dev \
    liblzma-dev \
    libncurses5-dev \
    libpq-dev \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    pkg-config \
    zlib1g-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV \
  HOME=/app \
  PATH=/app/.local/python/bin:/app/.local/node/bin:$PATH \
  PYTHONPATH=/app

RUN \
  mkdir -p /tmp/src /app/.local/python /app/.local/node && \
  cd /tmp/src && \
  curl -fsLS -O https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tar.xz && \
  curl -fsLS -O http://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz && \
  curl -fsLS -O https://bootstrap.pypa.io/get-pip.py && \
  curl -fsLS -o freight.tar.gz https://github.com/getsentry/freight/archive/3f6a677782709d1adf532d11f8dc48a27eed66a7.tar.gz && \
  echo '1cd3730781b91caf0fa1c4d472dc29274186480161a150294c42ce9b5c5effc0  Python-2.7.10.tar.xz' | sha256sum -c && \
  echo '6a2b3077f293d17e2a1e6dba0297f761c9e981c255a2c82f329d4173acf9b9d5  node-v0.12.7-linux-x64.tar.gz' | sha256sum -c && \
  echo '9ff40c7a52e6a37943e280d1487fa016959a7284bd12d3fc7c990cfd1dc39395  freight.tar.gz' | sha256sum -c && \
  tar -xJf Python-2.7.10.tar.xz && \
  tar -C /app/.local/node --strip-components=1 -xzf node-v0.12.7-linux-x64.tar.gz && \
  cd /tmp/src/Python-2.7.10 && \
  env LDFLAGS='-Wl,-rpath=/app/.local/python/lib' \
    ./configure --enable-shared --prefix=/app/.local/python && \
  make && \
  make install && \
  ldconfig && \
  cd /tmp/src && \
  /app/.local/python/bin/python get-pip.py && \
  tar -C /app --strip-components=1 -xzf freight.tar.gz && \
  cd /tmp && \
  rm -rf /tmp/src

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN /app/.local/python/bin/pip install --no-cache-dir --no-deps -r requirements.txt

RUN \
  /app/.local/node/bin/npm install && \
  /app/.local/node/bin/npm run postinstall && \
  /app/.local/node/bin/npm cache clean

USER nobody

ENTRYPOINT []
CMD []

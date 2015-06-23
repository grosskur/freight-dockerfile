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
  curl -fsLS -O http://nodejs.org/dist/v0.12.5/node-v0.12.5-linux-x64.tar.gz && \
  curl -fsLS -O https://bootstrap.pypa.io/get-pip.py && \
  curl -fsLS -o freight.tar.gz https://github.com/getsentry/freight/archive/4ea4bee4db37e891518ca3b8e36d6ca7ad1193e5.tar.gz && \
  echo '1cd3730781b91caf0fa1c4d472dc29274186480161a150294c42ce9b5c5effc0  Python-2.7.10.tar.xz' | sha256sum -c && \
  echo 'd4d7efb9e1370d9563ace338e01f7be31df48cf8e04ad670f54b6eb8a3c54e03  node-v0.12.5-linux-x64.tar.gz' | sha256sum -c && \
  echo 'd50506ff9e1cd4999f8b2b4ef058fb5f6379d14188d7e4757c5d143ea43b0796  freight.tar.gz' | sha256sum -c && \
  tar -xJf Python-2.7.10.tar.xz && \
  tar -C /app/.local/node --strip-components=1 -xzf node-v0.12.5-linux-x64.tar.gz && \
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
RUN /app/.local/python/bin/pip install --no-cache-dir -r requirements.txt

RUN \
  /app/.local/node/bin/npm install && \
  /app/.local/node/bin/npm run postinstall && \
  /app/.local/node/bin/npm cache clean

USER nobody

ENTRYPOINT []
CMD []

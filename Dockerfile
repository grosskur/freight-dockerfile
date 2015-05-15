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
  curl -fsLS -O https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz && \
  curl -fsLS -O http://nodejs.org/dist/v0.12.3/node-v0.12.3-linux-x64.tar.gz && \
  curl -fsLS -O https://bootstrap.pypa.io/get-pip.py && \
  curl -fsLS -o freight.tar.gz https://github.com/getsentry/freight/archive/c236df6ba6735b60f6f14d7fef4b09b59796d353.tar.gz && \
  echo '90d27e14ea7e03570026850e2e50ba71ad20b7eb31035aada1cf3def8f8d4916  Python-2.7.9.tar.xz' | sha256sum -c && \
  echo '22478ba86906666a95010e4eb73763535211719a53da9139b95daeb5b6c170b8  node-v0.12.3-linux-x64.tar.gz' | sha256sum -c && \
  echo '1a699248611eb3b6c6231c9aaac1f4dd04bce54a2eec5be581c61bdbdad4ac05  freight.tar.gz' | sha256sum -c && \
  tar -xJf Python-2.7.9.tar.xz && \
  tar -C /app/.local/node --strip-components=1 -xzf node-v0.12.3-linux-x64.tar.gz && \
  cd /tmp/src/Python-2.7.9 && \
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

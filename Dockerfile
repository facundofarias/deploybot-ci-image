FROM debian:8

ENV DEBIAN_FRONTEND=non-interactive

RUN apt-get --yes update && \
    apt-get install --yes \
      build-essential \
      ca-certificates \
      curl \
      git \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev \
      lsb-release \
      apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    VERSION=node_8.x && \
    DISTRO="$(lsb_release -s -c)" && \
    echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
    apt-get --yes update && \
    apt-get --yes install nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install and configure rbenv
RUN git clone https://github.com/rbenv/rbenv /usr/local/rbenv
RUN ln -s /usr/local/rbenv/bin/rbenv /usr/local/bin/rbenv
RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
ENV PATH=/root/.rbenv/shims:$PATH

# Install Ruby 2.0.0
RUN rbenv install 2.0.0-p648
RUN rbenv global 2.0.0-p648
RUN cd /root/.rbenv/versions && ln -s 2.0.0-p648 2.0.0

# Install bundler
RUN gem install bundler

# Install project dependencies
RUN apt-get --yes update && \
    apt-get install --yes \
      libmysqlclient-dev \
      libicu-dev \
      libcurl3 \
      libcurl4-openssl-dev \
      cmake \
      pkg-config \
      nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

COPY package.json .
COPY package-lock.json .
RUN npm install
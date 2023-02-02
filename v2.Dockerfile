FROM debian:11

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
    VERSION=node_16.x && \
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

# Install Ruby 2.7.6
RUN rbenv install 2.7.6
RUN rbenv global 2.7.6

# Install bundler
RUN gem install bundler -v 1.17.3

# Install project dependencies
RUN apt-get --yes update && \
    apt-get install --yes \
      libmariadb-dev \
      libicu-dev \
      libcurl4 \
      libcurl4-openssl-dev \
      cmake \
      pkg-config \
      libssh2-1-dev \
      unzip \
      nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /deploybot
WORKDIR /deploybot

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

ENV PATH /root/.rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
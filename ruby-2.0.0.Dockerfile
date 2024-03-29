FROM debian:8

ENV DEBIAN_FRONTEND=non-interactive

RUN rm /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian/ jessie main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian/ jessie main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian-security/ jessie/updates main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian-security/ jessie/updates main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "Acquire::Check-Valid-Until false;" | tee -a /etc/apt/apt.conf.d/10-nocheckvalid
RUN echo 'Package: *\nPin: origin "archive.debian.org"\nPin-Priority: 500' | tee -a /etc/apt/preferences.d/10-archive-pin
RUN apt-get update

RUN apt-get --yes update && \
    apt-get install --yes --allow-unauthenticated \
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

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# Install ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# Update the PATH env
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH $RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install Ruby 2.0.0-p648
RUN rbenv install 2.0.0-p648
RUN rbenv global 2.0.0-p648

# Install bundler
RUN gem install bundler -v 1.17.3

# Install project dependencies
RUN apt-get --yes update && \
    apt-get install --yes --allow-unauthenticated \
      libmysqlclient-dev \
      libicu-dev \
      libcurl3 \
      libcurl3-openssl-dev \
      cmake \
      pkg-config \
      libssh2-1-dev \
      unzip \
      nodejs && \
    rm -rf /var/lib/apt/lists/*

CMD ["bash"]
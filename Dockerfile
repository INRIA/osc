FROM debian:jessie-slim
LABEL maintainer="Mickael MASQUELIN <mickael.masquelin@univ-lille.fr>"

# Setup some environment vars
ENV APP_DIR /app
ENV BRANCH master
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LD_LIBRARY_PATH /opt/oracle/instantclient_12_2
ENV ORACLE_HOME /opt/oracle
ENV PATH ${PATH}:/usr/local/rvm/wrappers/default
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV TZ Europe/Paris

# Workaround tty check
# See https://github.com/hashicorp/vagrant/issues/1673#issuecomment-26650102
RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile

# Set bash "strict mode" to catch problems and bugs while running shell scripts
# Update apt cache, upgrade and install all dependencies
RUN set -eux; \
    apt-get update -qq -y \
    && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
    && apt-get install -qq -y --no-install-recommends tzdata netcat-traditional procps curl gnupg2 dirmngr git build-essential gawk autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline6-dev libssl-dev zip unzip nodejs npm imagemagick libmagickcore-dev libmagickwand-dev libaio1 libaio-dev libmysqlclient-dev \
    && apt-get clean \
    && rm -fr /var/lib/apt/lists/*

# Quick fix for gpg2
RUN mkdir /root/.gnupg \
    && echo "disable-ipv6" >> /root/.gnupg/dirmngr.conf

# and then install rvm to deploy ruby legacy versions (after importing gpg keys)
RUN gpg2 --quiet --no-tty --logger-fd 1 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && curl -sSL https://get.rvm.io | bash -s stable \
    && echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc \
    && echo "GEM_HOME=$APP_DIR/vendor/bundle/ruby/1.9.1" >> /etc/bash.bashrc \
    && echo "GEM_PATH=$APP_DIR/vendor/bundle/ruby/1.9.1" >> /etc/bash.bashrc \
    && /bin/bash -l -c 'source /etc/profile.d/rvm.sh && rvm install 1.9.3-p551 && rvm alias create default 1.9.3-p551 && rvm system 1.9.3-p551' \
    && echo "rvm_silence_path_mismatch_check_flag=1" >> /etc/rvmrc \
    && echo "gem: --no-rdoc --no-ri" >> /root/.gemrc

# Create app directory and copy all app content in the container
RUN git clone --depth 1 -b $BRANCH https://github.com/INRIA/osc.git $APP_DIR/ 

# Install oracle instant cli
# See https://github.com/pwnlabs/oracle-instantclient
RUN mkdir -p $ORACLE_HOME
WORKDIR $ORACLE_HOME
RUN curl -sSL raw.githubusercontent.com/pwnlabs/oracle-instantclient/master/instantclient-basic-linux.x64-12.2.0.1.0.zip -o /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip \
    && curl -sSL raw.githubusercontent.com/pwnlabs/oracle-instantclient/master/instantclient-sdk-linux.x64-12.2.0.1.0.zip -o /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip \
    && curl -sSL raw.githubusercontent.com/pwnlabs/oracle-instantclient/master/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -o /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
RUN unzip '/tmp/instantclient*.zip' \
    && ln -s $ORACLE_HOME/instantclient_12_2/libclntsh.so.12.1 $ORACLE_HOME/instantclient_12_2/libclntsh.so \
    && rm -fr /tmp/instantclient*.zip

# Setup production mode env vars for demo
RUN sed -i  -e "s/config.force_ssl = true/config.force_ssl = false/g" $APP_DIR/config/environments/production.rb \
    && sed -i  -e "s/config.assets.compile = false/config.assets.compile = true/g" $APP_DIR/config/environments/production.rb \
    && sed -i  -e "s/config.assets.digest = true/config.assets.digest = false/g" $APP_DIR/config/environments/production.rb

# Quick fix to avoid a warning
RUN cp $APP_DIR/config/osc.conf.base_rb $APP_DIR/config/osc.conf.rb \
    && sed -i  -e "s/API_KEY = \"123456789\"/# API_KEY = \"\"/g" $APP_DIR/config/osc.conf.rb

# Create base homedir for OSC
RUN addgroup \
    --gid "5000" \
    "app" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "$APP_DIR" \
    --ingroup "app" \
    --no-create-home \
    --uid "5000" \
    "app" \
    && /bin/chown -R app:app /app

# Deploy app in production mode
WORKDIR $APP_DIR
RUN bundle install --deployment --without test development \
    && bundle clean --force \
    && rm -fr $APP_DIR/vendor/bundle/ruby/1.9.1/cache/*.gem \
    && find $APP_DIR/vendor/bundle/ruby/1.9.1/gems/ -name "*.c" -delete \
    && find $APP_DIR/vendor/bundle/ruby/1.9.1/gems/ -name "*.o" -delete

USER app

COPY config/database.yml $APP_DIR/config/

# Default command to run
CMD ["tail", "-f", "/dev/null"]
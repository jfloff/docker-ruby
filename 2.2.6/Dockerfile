FROM heroku/cedar:14
MAINTAINER Terence Lee <terence@heroku.com>
MAINTAINER Joao Loff <jfloff@gmail.com>

ENV RUBY_VERSION 2.2.6
ENV NODE_VERSION 4.7.0

RUN mkdir -p /app/user
WORKDIR /app/user

# Install Ruby
RUN mkdir -p /app/heroku/ruby/ruby-$RUBY_VERSION && \
    curl -sL --retry 3 https://heroku-buildpack-ruby.s3.amazonaws.com/cedar-14/ruby-$RUBY_VERSION.tgz | tar xz -C /app/heroku/ruby/ruby-$RUBY_VERSION
ENV PATH /app/heroku/ruby/ruby-$RUBY_VERSION/bin:$PATH

# Install Node
RUN curl -sL --retry 3 http://s3pository.heroku.com/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz | tar xz -C /app/heroku/ruby/ && \
    mv /app/heroku/ruby/node-v$NODE_VERSION-linux-x64 /app/heroku/ruby/node-$NODE_VERSION
ENV PATH /app/heroku/ruby/node-$NODE_VERSION/bin:$PATH

# Install Bundler
ENV GEM_PATH /app/heroku/ruby/bundle/ruby/$RUBY_VERSION
ENV GEM_HOME /app/heroku/ruby/bundle/ruby/$RUBY_VERSION
RUN mkdir -p /app/heroku/ruby/bundle/ruby/$RUBY_VERSION && \
    gem install bundler --no-ri --no-rdoc
ENV PATH /app/user/bin:/app/heroku/ruby/bundle/ruby/$RUBY_VERSION/bin:$PATH
ENV BUNDLE_APP_CONFIG /app/heroku/ruby/.bundle/config

# Run bundler to cache dependencies
ONBUILD COPY ["Gemfile", "Gemfile.lock", "/app/user/"]
# bundle chooses GEM_PATH as default install path
ONBUILD RUN bundle install --jobs 4
ONBUILD ADD . /app/user

# How to conditionally `rake assets:precompile`?
ONBUILD ENV SECRET_KEY_BASE $(openssl rand -base64 32)
# removing this from build and adding to init.sh
# since we mostly use this for development we can live with a longer init when
# we are dealing with production containers
# ONBUILD ENV RAILS_ENV production
# ONBUILD RUN bundle exec rake assets:precompile

# export env vars during run time
RUN mkdir -p /app/.profile.d/ && \
    echo "cd /app/user/" > /app/.profile.d/home.sh
ONBUILD RUN echo "export PATH=\"$PATH\" GEM_PATH=\"$GEM_PATH\" GEM_HOME=\"$GEM_HOME\" RAILS_ENV=\"\${RAILS_ENV:-$RAILS_ENV}\" SECRET_KEY_BASE=\"\${SECRET_KEY_BASE:-$SECRET_KEY_BASE}\" BUNDLE_APP_CONFIG=\"$BUNDLE_APP_CONFIG\"" > /app/.profile.d/ruby.sh

COPY ./init.sh /usr/bin/init.sh
RUN chmod +x /usr/bin/init.sh

ENTRYPOINT ["/usr/bin/init.sh"]

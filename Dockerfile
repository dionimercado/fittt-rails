FROM ruby:2.6.2

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs ghostscript

RUN mkdir -p /app
WORKDIR /app

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN node -v
RUN npm -v

RUN npm install -g yarn

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile /app/Gemfile 
COPY Gemfile.lock /app/Gemfile.lock

RUN gem install bundler -v 2.0.2
# RUN gem install foreman -v 0.85.0
RUN bundle install --verbose --jobs 20 --retry 5

RUN yarn install --check-files

# Copy the main application.
# COPY . ./

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
# Expose port 3000 to the Docker host, so we can access it
# from the outside.
# EXPOSE 5000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
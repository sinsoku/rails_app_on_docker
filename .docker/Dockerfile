FROM ruby:2.7.2

WORKDIR /app
ENV BUNDLE_PATH vendor/bundle

# Using Node.js v12.x(LTS)
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Add packages
RUN apt-get update && apt-get install -y \
      nodejs vim

# Add yarnpkg for assets:precompile
RUN npm install -g yarn

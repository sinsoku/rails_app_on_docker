# syntax=docker/dockerfile:experimental
FROM ruby:2.7.2-alpine3.12 AS app-base

WORKDIR /app
ENV RAILS_ENV production
ENV BUNDLE_WITHOUT development:test
ENV BUNDLE_PATH vendor/bundle

# == builder
FROM app-base AS builder

# Add packages
RUN apk update && apk add --update \
     build-base yarn postgresql-dev tzdata git

# Install gems
COPY Gemfile .
COPY Gemfile.lock .
RUN --mount=type=cache,target=.cache/bundle \
     BUNDLE_PATH=.cache/bundle BUNDLE_CLEAN=1 bundle install && \
     mkdir vendor && \
     cp -ar .cache/bundle vendor/bundle

# Install npm packages
COPY package.json .
COPY yarn.lock .
RUN --mount=type=cache,target=.cache/node_modules \
     yarn install --modules-folder=.cache/node_modules && \
     cp -ar .cache/node_modules node_modules

COPY . .

# Set a dummy value to avoid errors when building docker image.
# refs: https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

# == main
FROM app-base

RUN apk update && apk add --update \
     postgresql-dev tzdata \
     && rm -rf /var/cache/apk/*

COPY . .

# Copy from build stages
COPY --from=builder /app/vendor/bundle vendor/bundle
COPY --from=builder /app/public/assets ./public/assets
COPY --from=builder /app/public/packs ./public/packs

EXPOSE 3000
CMD ["bin/rails", "server"]

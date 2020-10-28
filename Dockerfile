FROM ruby:2.7.2-alpine3.12 AS app-base

WORKDIR /app
ENV RAILS_ENV production
ENV BUNDLE_WITHOUT development:test

# == builder
FROM app-base AS builder

# Add packages
RUN apk update && apk add --update \
     build-base yarn postgresql-dev tzdata git

COPY . .
RUN bundle install

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
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/public/assets ./public/assets
COPY --from=builder /app/public/packs ./public/packs

EXPOSE 3000
CMD ["bin/rails", "server"]

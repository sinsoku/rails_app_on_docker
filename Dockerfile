FROM ruby:2.7.2-alpine3.12

WORKDIR /app
ENV RAILS_ENV production
ENV BUNDLE_WITHOUT development:test

# Add packages
RUN apk update && apk add --update \
     build-base yarn postgresql-dev tzdata git

COPY . .
RUN bundle install

# Set a dummy value to avoid errors when building docker image.
# refs: https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

EXPOSE 3000
CMD ["bin/rails", "server"]

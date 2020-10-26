FROM ruby:2.7.2

WORKDIR /app
ENV RAILS_ENV production
ENV BUNDLE_WITHOUT development:test

# Using Node.js v12.x(LTS)
# refs: https://github.com/nodesource/distributions/blob/9dcbaaec9a6f3d482ec6897a6c351faaa195d21b/README.md
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Add packages
RUN apt-get update && apt-get install -y nodejs

# Add yarnpkg for assets:precompile
RUN npm install -g yarn

COPY . .
RUN bundle install

# Set a dummy value to avoid errors when building docker image.
# refs: https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

EXPOSE 3000
CMD ["bin/rails", "server"]

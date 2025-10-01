# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.3.5
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Build stage
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (Rails statique)
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# Final stage
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Créer utilisateur rails
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails log storage tmp

USER rails:rails

# Ne plus utiliser docker-entrypoint (il appelle db:prepare)
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]  # ❌ supprimer

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]

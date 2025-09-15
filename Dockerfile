# Base runtime
FROM ruby:3.4.5-alpine AS builder

RUN apk add --no-cache build-base

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler --no-document && \
    bundle config --global frozen 1 && \
    bundle config --global without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    bundle clean --force


FROM ruby:3.4.5-alpine

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S -G appgroup -s /bin/sh -h /app appuser

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle

COPY --chown=appuser:appgroup . .

USER appuser

ENV RUBY_YJIT_ENABLE=1

CMD ["bundle", "exec", "ruby", "--yjit", "main.rb"]

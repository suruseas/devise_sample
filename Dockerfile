ARG ALPINE_VERSION=3.16
ARG RUBY_VERSION=3.1.2

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} as builder

ENV ROOT="/app"
ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

RUN mkdir ${ROOT}
WORKDIR ${ROOT}

RUN apk update && \
    apk add --no-cache \
        linux-headers \
        libxml2-dev \
        make \
        gcc \
        git \
        libc-dev \
        tzdata \
        postgresql \
        postgresql-dev && \
    apk add --virtual build-packages --no-cache build-base curl-dev

COPY Gemfile ${ROOT}
COPY Gemfile.lock ${ROOT}

RUN bundle install
RUN apk del build-packages

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}

ENV ROOT="/app"
ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

RUN apk update && \
    apk add \
        bash \
        yarn \
        git \
        postgresql-dev \
        tzdata \
        npm

WORKDIR ${ROOT}

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . ${ROOT}
# COPY entrypoint.sh /usr/bin/

# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
# EXPOSE 3000

# CMD ["bin/dev"]
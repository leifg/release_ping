FROM alpine:3.6
MAINTAINER Leif Gensert <leif@leif.io>

RUN apk add --no-cache ncurses-libs openssl postgresql-client

ARG VERSION

ADD _build/prod/rel/release_ping/releases/${VERSION}/release_ping.tar.gz /app

ENTRYPOINT ["app/bin/release_ping"]
CMD ["foreground"]

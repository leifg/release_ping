FROM alpine:3.7
MAINTAINER Leif Gensert <leif@leif.io>

RUN apk add --no-cache ncurses-libs openssl postgresql-client bash

ARG VERSION

ADD deployment/app.sh /usr/local/bin/app
ADD _build/prod/rel/release_ping/releases/${VERSION}/release_ping.tar.gz /app

ENTRYPOINT ["/usr/local/bin/app"]
CMD ["foreground"]

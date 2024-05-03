FROM alpine:3.10

RUN apk add --no-cache bash curl gzip

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
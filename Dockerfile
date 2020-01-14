FROM debian:stretch-slim

ENV VARNISH_VERSION 6.0.5-1~stretch
ENV MAGENTO_HOST 127.0.0.1
ENV MAGENTO_PORT 8081

COPY docker-varnish-entrypoint /usr/local/bin/

RUN set -ex; \
    fetchDeps=" \
        dirmngr \
        gnupg \
    "; \
    apt-get update; \
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates $fetchDeps; \
    key=48D81A24CB0456F5D59431D94CFCFD6BA750EDCD; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver http://ha.pool.sks-keyservers.net/ --recv-keys $key; \
    gpg --batch --export export $key > /etc/apt/trusted.gpg.d/varnish.gpg; \
    gpgconf --kill all; \
    rm -rf $GNUPGHOME; \
    echo deb https://packagecloud.io/varnishcache/varnish60lts/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
    \
    chmod +x /usr/local/bin/docker-varnish-entrypoint; \
    \
    rm -rf /var/lib/apt/lists/*

COPY varnish.vcl /etc/varnish/default.vcl

WORKDIR /etc/varnish

EXPOSE 8080

ENTRYPOINT ["docker-varnish-entrypoint"]
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl", "-a", ":8080", "-s", "malloc,512m"]

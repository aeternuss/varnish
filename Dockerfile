FROM debian:stretch-slim

ENV VARNISH_VERSION 5.2.1-1~stretch
ENV MAGENTO_HOST 127.0.0.1
ENV MAGENTO_PORT 80

RUN set -ex; \
	fetchDeps=" \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates $fetchDeps; \
    key=91CFD5635A1A5FAC0662BEDD2E9BA3FE86BE909D; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver http://ha.pool.sks-keyservers.net/ --recv-keys $key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/varnish.gpg; \
	gpgconf --kill all; \
	rm -rf $GNUPGHOME; \
	echo deb https://packagecloud.io/varnishcache/varnish52/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 6081
COPY varnish.vcl /etc/varnish/default.vcl
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]

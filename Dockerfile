FROM debian:stable-slim

ENV SS_SERVER 127.0.0.1
ENV SS_SERVER_PORT 8388
ENV SS_PASSWORD barfoo!
ENV SS_TIMEOUT 86400
ENV SS_METHOD chacha20-ietf-poly1305
ENV SS_ARGS ""

ENV FLAG_OUTDATED 0
COPY scripts/version-check.sh /

RUN apt-get update -qq && \
	apt-get upgrade -y

RUN apt-get install --no-install-recommends -y \
		autoconf  \
		automake \
		libtool \
		libpcre3-dev \
		libmbedtls-dev \
		libsodium-dev \ 
		libc-ares-dev \
		libev-dev \
		git && \
	cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
	echo 'deb http://deb.debian.org/debian bullseye main' > /etc/apt/sources.list && apt-get update -qq && \
	apt-get install --no-install-recommends -y golang-1.13 \
	/etc/apt/sources.list.bak /etc/apt/sources.list && \
	rm -rf /var/lib/apt/lists/*

RUN set -ex && \
	cd /tmp && \
	git clone --recursive https://github.com/shadowsocks/shadowsocks-libev.git && \
	cd shadowsocks-libev && \
	bash /version-check.sh && \
	./autogen.sh && \
	./configure --disable-documentation && \
	make install && \
	cd .. && rm -rf shadowsocks-libev

RUN set -ex && \
	cd /tmp && \
	git clone https://github.com/shadowsocks/v2ray-plugin.git && \
	cd v2ray-plugin && \
	bash /version-check.sh && \
	go get -d && \
	go build && \
	cp v2ray-plugin /usr/local/bin/ && \
	cd .. && rm -rf v2ray-plugin && \
	rm -f /version-check.sh

CMD exec ss-server \
	-s $SS_SERVER \
	-p $SS_SERVER_PORT \
	-k $SS_PASSWORD \
	-m $SS_METHOD \
	-t $SS_TIMEOUT \
	$SS_ARGS

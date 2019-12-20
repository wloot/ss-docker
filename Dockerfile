# Start from the latest slim of Debian stable
FROM debian:stable-slim

# Shadowsocks environment variables, 
ENV SS_SERVER 0.0.0.0
ENV SS_SERVER_PORT 8388
ENV SS_PASSWORD "barfoo!"
ENV SS_TIMEOUT 86400
ENV SS_METHOD chacha20-ietf-poly1305
# Additional parameters
ENV SS_ARGS ""

# If upstream sources haven't change for few days, ship the docker imsage update
ENV FLAG_OUTDATED 0
COPY scripts/version-check.sh /

# Update software sources
RUN apt-get update -qq && \
	apt-get upgrade -y \

# Install the packages which be needed
&& set -ex && apt-get install --no-install-recommends -y \
		autoconf \
		automake \
		libtool \
		libpcre3-dev \
		libmbedtls-dev \
		libsodium-dev \ 
		libc-ares-dev \
		libev-dev \
		git \
		build-essential \

# As Debian 10 (which is stable build for now)'s software sources still use outdated golang package which will fail
# build later. Change to testing sources Temporarily and use golang-1.13.
&& cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
	echo 'deb http://deb.debian.org/debian bullseye main' > /etc/apt/sources.list && apt-get update -qq && \
	apt-get install --no-install-recommends -y golang ca-certificates && \
	cp -f /etc/apt/sources.list.bak /etc/apt/sources.list && \
	rm -rf /var/lib/apt/lists/* \

# Build shadowsocks-libev from source
&& cd /tmp && \
	git clone --recursive https://github.com/shadowsocks/shadowsocks-libev.git --depth=1 && \
	cd shadowsocks-libev && \
	bash /version-check.sh && \
	./autogen.sh && \
	./configure --disable-documentation && \
	make install && \
	cd .. && rm -rf shadowsocks-libev \

# Build v2ray-plugin from source
&& cd /tmp && \
	git clone https://github.com/shadowsocks/v2ray-plugin.git --depth=1 && \
	cd v2ray-plugin && \
	bash /version-check.sh && \
	go get -d && \
	go build && \
	cp v2ray-plugin /usr/local/bin/ && \
	cd .. && rm -rf v2ray-plugin \

# Build v2ray-plugin from source
&& cd /tmp && \
	git clone https://github.com/xtaci/kcptun.git --depth=1 && \
	cd kcptun && \
	bash /version-check.sh && \
	GO111MODULE=on go get -d github.com/xtaci/kcptun/... && \
	go build -o kcptun-server -ldflags "-X main.VERSION=$(date -u +%Y%m%d) -s -w" github.com/xtaci/kcptun/server && \
	cp kcptun-server /usr/local/bin/ && \
	cd .. && rm -rf kcptun \

&& rm -f /version-check.sh \

# Uninstall build tools as we don't need them anymore
&& apt-get purge -y \
		autoconf \
		automake \
		libtool \
		git \
		build-essential \
		golang \
		ca-certificates && \
	apt-get autoremove -y

# Finally start ss server
CMD exec ss-server \
	-s $SS_SERVER \
	-p $SS_SERVER_PORT \
	-k "$SS_PASSWORD" \
	-m $SS_METHOD \
	-t $SS_TIMEOUT \
	$SS_ARGS

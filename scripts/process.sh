#!/bin/bash

set -m

if [[ $KCP_ENABLE -eq 0 ]]; then
	ln -sf /bin/true /usr/local/bin/kcptun-server
fi

ss-server \
	-s $SS_SERVER \
	-p $SS_SERVER_PORT \
	-k "$SS_PASSWORD" \
	-m $SS_METHOD \
	-t $SS_TIMEOUT \
	$SS_ARGS &

kcptun-server \
	-l ":"$KCP_LISTEN \
	-t $SS_SERVER":"$SS_SERVER_PORT \
	--key "$KCP_KEY" \
	--crypt $KCP_CRYPT \
	--mode $KCP_MODE \
	$KCP_ARGS

fg %1

# ss-docker

## 我的配置
```
docker pull wloot/ss-docker

docker run -d \
-v <path to .acme.sh>:<user who executed this command>/.acme.sh \
-e SS_ARGS="--plugin v2ray-plugin --plugin-opts server;tls;host=example.com" \
-e SS_SERVER_PORT=443 \
-e SS_PASSWORD="your password" \
--name=ss-server \
-p 443:443/tcp \
--restart=always \
wloot/ss-docker
```
更多配置方法请看 shadwosocks 和 kcptun 官方文档

## 可配置的环境变量以及默认值
* ss
   * SS_SERVER - 0.0.0.0
   * SS_SERVER_PORT - 8388
   * SS_PASSWORD - "barfoo!"
   * SS_TIMEOUT - 86400
   * SS_METHOD - chacha20-ietf-poly1305
   * SS_ARGS - <空>
* kcp
   * KCP_ENABLE - 0 # 设置为非零以开启 kcptun
   * KCP_LISTEN - 29900
   * KCP_KEY - "it's a secrect"
   * KCP_CRYPT - aes
   * KCP_MODE - fsat
   * KCP_ARGS - <空>

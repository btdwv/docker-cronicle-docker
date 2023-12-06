FROM  lsiobase/alpine:3.18
LABEL maintainer="BlueT - Matthew Lien - 練喆明 <bluet@bluet.org>"

# Docker defaults
ENV        CRONICLE_VERSION 0.9.39
ENV        CRONICLE_base_app_url 'http://localhost:3012'
ENV        CRONICLE_WebServer__http_port 3012
ENV        CRONICLE_WebServer__https_port 443
ENV        EDITOR=nano

RUN \
echo "**** install runtime packages ****" && \
apk add --no-cache nodejs npm git curl wget perl bash perl-pathtools tar procps nano tini tzdata python3 py3-pip build-base libffi-dev python3-dev jq && \
echo "**** install pip packages ****" && \
pip3 install --no-cache-dir -U pip      && \
pip3 install --no-cache-dir -U requests && \
pip3 install --no-cache-dir -U json5    && \
pip3 install --no-cache-dir -U aiohttp  && \
pip3 install --no-cache-dir -U python-dotenv && \
pip3 install --no-cache-dir -U PyYAML && \
apk del libffi-dev build-base python3-dev && \
echo "**** install Cronicle ****" && \
mkdir -p /opt/cronicle && \
cd /opt/cronicle && \
curl -L https://github.com/jhuckaby/Cronicle/archive/v${CRONICLE_VERSION}.tar.gz | tar zxvf - --strip-components 1 && \
npm install && \
node bin/build.js dist && \
rm -rf /root/.npm /root/.cache /tmp/*

# Runtime user
# RUN        adduser cronicle -D -h /opt/cronicle
# RUN        adduser cronicle docker
WORKDIR    /opt/cronicle/
ADD        docker/entrypoint.sh /entrypoint.sh

EXPOSE     3012

# data volume is also configured in entrypoint.sh
VOLUME     ["/opt/cronicle/data", "/opt/cronicle/logs", "/opt/cronicle/plugins"]

ENTRYPOINT ["/sbin/tini", "--"]
CMD        ["sh", "/entrypoint.sh"]

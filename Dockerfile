FROM zabbix/zabbix-agent2:alpine-5.2-latest

USER root

ENV GOSU_VERSION 1.8

RUN set -x && \
    apk add --no-cache --clean-protected curl gnupg && \
    curl -sSL https://github.com/Yelp/dumb-init/releases/download/v$DUMB_INIT_VERSION/dumb-init_${DUMB_INIT_VERSION}_amd64 > /usr/bin/dumb-init && \
    chmod +x /usr/bin/dumb-init && \
    curl -sSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 > /usr/bin/gosu && \
    curl -sSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc > /tmp/gosu.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu && \
    chmod +x /usr/bin/gosu && \
    rm -rf "$GNUPGHOME" /tmp/*

RUN set -eux && \
    apk add --no-cache --virtual build-dependencies \
            autoconf \
            automake \
            go \
            g++ \
            make \
            git \
            pcre-dev \
            openssl-dev \
            pacman \
            fakeroot \
            zlib-dev && \
    mkdir /rabbitmq && \
    cd /rabbitmq/ && \
    git clone https://github.com/zarplata/zabbix-agent-extension-rabbitmq.git && \
    chown -R zabbix:zabbix /rabbitmq && \
    chmod -R 770 /rabbitmq && \
    cd /rabbitmq/zabbix-agent-extension-rabbitmq/ && \
    gosu zabbix ./build-archlinux.sh && \
    ln -s /var/lib/zabbix/go/bin/zabbix-agent-extension-rabbitmq /usr/bin/ && \
    cp zabbix-agent-extension-rabbitmq.conf /etc/zabbix/zabbix_agentd.d/ && \
    cp template_app_rabbitmq_service.xml /etc/zabbix/ && \
    rm -rf /rabbitmq && \
    apk del --purge --no-network \
            build-dependencies && \
    rm -rf /var/cache/apk/*

USER zabbix

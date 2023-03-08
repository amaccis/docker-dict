FROM alpine:3.17.2

LABEL maintainer="Andrea Maccis <andrea.maccis@gmail.com>"

COPY docker-source-manager /usr/local/bin

ENV DICTD_VERSION 1.13.1

ENV BMKDEP_VERSION 20140112
ENV BMAKE_VERSION 20200710
ENV MKCONFIGURE_VERSION 0.38.2
ENV LIBMAA_VERSION 1.4.7
ENV DICTS_VERSION 2011.03.16

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
            curl \
            tar \
            autoconf \
            gcc \
            g++ \
            libc-dev \
            zlib-dev \
            flex \
            libtool \
            make \
            gawk \
            bison \
            groff; \
    # bmkdep \
    mkdir -p /usr/src; \
    cd /usr/src; \
    export BMKDEP_URL="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/bmkdep/bmkdep-${BMKDEP_VERSION}.tar.gz"; \
    curl -fsSL -o bmkdep.tar.gz "$BMKDEP_URL"; \
    unset BMKDEP_URL; \
    docker-source-manager bmkdep extract; \
    cd bmkdep; \ 
    cc findcc.c mkdep.c -o mkdep; \
    cp mkdep /usr/local/bin; \
    docker-source-manager bmkdep delete; \
    # bmake \
    cd /usr/src; \
    export BMAKE_URL="http://www.crufty.net/ftp/pub/sjg/bmake-${BMAKE_VERSION}.tar.gz"; \
    curl -fsSL -o bmake.tar.gz "$BMAKE_URL"; \
    unset BMAKE_URL; \
    docker-source-manager bmake extract; \
    cd bmake; \
    ./configure; \
    make; \
    cp bmake /usr/local/bin; \
    docker-source-manager bmake delete; \
    # mk-configure \
    cd /usr/src; \
    export MKCONFIGURE_URL="https://github.com/cheusov/mk-configure/archive/mk-configure-${MKCONFIGURE_VERSION}.tar.gz"; \
    curl -fsSL -o mk-configure.tar.gz "$MKCONFIGURE_URL"; \
    unset MKCONFIGURE_URL; \
    docker-source-manager mk-configure extract; \
    cd mk-configure; \
    touch sys.mk; \
    bmake all; \
    bmake install; \
    # libmaa \
    cd /usr/src; \
    export LIBMAA_URL="https://github.com/cheusov/libmaa/archive/libmaa-${LIBMAA_VERSION}.tar.gz"; \
    curl -fsSL -o libmaa.tar.gz "$LIBMAA_URL"; \
    unset LIBMAA_URL; \
    docker-source-manager libmaa extract; \
    cd libmaa; \
    export PREFIX=/usr; \
    mkcmake all; \
    mkcmake install; \
    unset PREFIX; \
    docker-source-manager libmaa delete; \
    cd /usr/src/mk-configure; \
    bmake uninstall; \
    docker-source-manager mk-configure delete; \
    # dictd \
    cd /usr/src; \
    export DICTD_URL="https://github.com/cheusov/dictd/archive/${DICTD_VERSION}.tar.gz"; \
    curl -fsSL -o dictd.tar.gz "$DICTD_URL"; \
    unset DICTD_URL; \
    docker-source-manager dictd extract; \
    cd dictd; \
    autoconf; \
    autoheader; \
    ./configure --prefix=/usr --sysconfdir=/etc; \
    make dict; \
    make dictd; \
    make install.dict; \
    make install.dictd; \
    cp examples/dictd1.conf /etc/dictd.conf; \
    docker-source-manager dictd delete; \
    # dictd-dicts \
    cd /usr/src; \
    export DICTS_URL="https://github.com/ferdnyc/dictd-dicts/archive/snap.${DICTS_VERSION}.tar.gz"; \
    curl -fsSL -o dicts.tar.gz "$DICTS_URL"; \
    unset DICTS_URL; \
    docker-source-manager dicts extract; \
    cd dicts; \
    mkdir -p /usr/lib/dict; \
    cp web1913* wn* gazetteer* jargon* foldoc* elements* easton* hitchcock* /usr/lib/dict; \
    docker-source-manager dicts delete; \
    apk del --no-network .build-deps

EXPOSE 2628 

CMD ["dictd", "-dnodetach"]

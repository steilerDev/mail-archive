FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive
ARG DOVECOT_VERSION="1:2.3.13+dfsg1-2+deb11u1"
ENV DOCKERVERSION=23.0.4

# Ensure that a valid SSL certificate is present and restart in order to load the (hopefully) renewed certificate
HEALTHCHECK --interval=1m --timeout=10s --retries=3 CMD true | openssl s_client -connect localhost:993 2>/dev/null | openssl x509 -noout -checkend 0 || /etc/dovecot/renew-certificate.sh

# Install stuff and remove caches
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
            tar curl ca-certificates dovecot-core=$DOVECOT_VERSION dovecot-imapd=$DOVECOT_VERSION && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

RUN useradd -mUs /bin/bash vmail

EXPOSE 993
VOLUME ["/mail-data", "/ssl", "/etc/dovecot/docker-conf.d/", "/conf"]

# Applying fs patch for assets
ADD rootfs.tar.gz /
RUN chmod +x /etc/dovecot/docker-entrypoint.sh
RUN chmod +x /etc/dovecot/renew-certificate.sh

WORKDIR /etc/dovecot
ENTRYPOINT ["/etc/dovecot/docker-entrypoint.sh"]
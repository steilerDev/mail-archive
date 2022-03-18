FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive

# Ensure that a valid SSL certificate is present and restart in order to load the (hopefully) renewed certificate
HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD true | openssl s_client -connect localhost:993 2>/dev/null | openssl x509 -noout -checkend 0

# Install dependencies to add repo
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
            curl gpg apt-transport-https ca-certificates

# Add dovecot repo & trust it
RUN curl https://repo.dovecot.org/DOVECOT-REPO-GPG | gpg --import && \  
    gpg --export ED409DA1 > /etc/apt/trusted.gpg.d/dovecot.gpg && \
    echo "deb https://repo.dovecot.org/ce-2.3-latest/debian/bullseye bullseye main" > /etc/apt/sources.list.d/dovecot.list

# Install stuff and remove caches
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
            dovecot-core dovecot-imapd && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN useradd -mUs /bin/bash vmail

EXPOSE 993
VOLUME ["/mail-data", "/ssl", "/etc/dovecot/conf.d/"]

WORKDIR /etc/dovecot

# Applying fs patch for assets
ADD rootfs.tar.gz /
RUN chmod +x /etc/dovecot/docker-entrypoint.sh

ENTRYPOINT ["/etc/dovecot/docker-entrypoint.sh"]
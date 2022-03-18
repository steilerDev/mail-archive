# Mail Archive - Docker Container
This docker container will spin up a simple IMAP server, using [dovecot](https://www.dovecot.org). The mailboxes can be configured through environmental variables. This can be used, in order to clean up cloud-based accounts, or when cancelling existing accounts. This long-term, low maintenance solutions keeps the messages viewable and searchable through a regular mail client. There is no WebUI, just an IMAP backend.

This container currently expects a valid SSL certificate in order to not fail the health-check. Let me know if there is any need to make this optional.

# Configuration options
## Environment Variables
The following environmental variables can be used for configuration:

 - `IMAP_USER_N`  
    The user definition in the format `<username>:<password>`, where `N` is the index starting at `1`, e.g. `IMAP_USER_1`.  
    At least one user (i.e. `IMAP_USER_1`) needs to be defined. The user db will be re-generated on every startup.

## Volume Mounts
The following paths are recommended for persisting state and/or accessing configurations

 - `/mail-data`  
    Location of the mailboxes (**Required**)
 - `/ssl`  
    This is where the SSL private key (`./key.pem`) and certificate (`./fullchain.pem`) are expected. It is possible to map this to the respective folder for this mail server's domain within `acme-companion` (**Required**)
  - `/conf`  
    Location of the user db (`./users`), which will be generated on startup - if the correct environment variables are set - and the Diffie Hellmann parameters (`./dhparams.pem`), which will be generated if not present on startup, will be stored
  - `/etc/dovecot/docker-conf.d/`  
    An optional directory to overwrite the dovecot configuration provided by this container (files matching `*.conf` will be read in ASCII order). See [available settings](https://doc.dovecot.org/settings/#settings) and [documentation of importing](https://doc.dovecot.org/configuration_manual/config_file/). 

# docker-compose example
Usage with [`acme-companion`](https://github.com/nginx-proxy/acme-companion) & [`nginx-proxy`](https://github.com/nginx-proxy/nginx-proxy), where `/opt/docker/nginx-proxy/volumes/certs/` is the mapped volume of those two, inside of predefined `steilerGroup` network.

```
version: '2'
services:
  mail-archive:
    image: steilerdev/mail-archive:latest
    container_name: mail-archive
    restart: unless-stopped
    environment:
        LETSENCRYPT_HOST: mail.doe.net
        IMAP_USER_1: "john@archive.doe.net:super-secure-password"
    ports:
      - "993:993"
    volumes:
      - /opt/docker/mail:/mail-data
      - /opt/docker/nginx-proxy/volumes/certs/mail.doe.de:/ssl:ro
networks:
  default:
    external:
      name: steilerGroup
```
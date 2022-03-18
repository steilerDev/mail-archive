# Mail Archive - Docker Container
This docker container will spin up a simple IMAP server, using [dovecot](https://www.dovecot.org). The mailboxes can be configured through environmental variables. This can be used, in order to clean up cloud-based accounts, or when cancelling existing accounts. This long-term, low maintenance solutions keeps the messages viewable and searchable through a regular mail client. There is no WebUI, just an IMAP backend.

This container currently expects a valid SSL certificate in order to not fail the health-check. Let me know if there is any need to make this optional.

# Configuration options
## Environment Variables
The following environmental variables can be used for configuration:

 - `VAR`  
    Description for var  
    Accepted options

## Volume Mounts
The following paths are recommended for persisting state and/or accessing configurations

 - `/some-path/` 
    Description on usage

# docker-compose example
Usage with `nginx-proxy` inside of predefined `steilerGroup` network.

```
version: '2'
services:
  <service-name>:
    image: steilerdev/mail-archive:latest
    container_name: mail-archive
    restart: unless-stopped
    # Trigger restart once the SSL cert has expired (and hopefully renewed)
    test: 
    hostname: "<hostname>"
    environment:
      VAR: "value"
    volumes:
      - /<some-host-path>:/<some-docker-path>
networks:
  default:
    external:
      name: steilerGroup
```
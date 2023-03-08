# dictd

This image uses [dictd](https://github.com/cheusov/dictd/), a client/server software that supports DICT protocol.

# The DICT Protocol

As per [RFC 2229](https://www.ietf.org/rfc/rfc2229.txt), the Dictionary Server Protocol (DICT) is a TCP transaction based query/response protocol that allows a client to access dictionary definitions from a set of natural language dictionary databases. For more details see [dict.org](https://dict.org/bin/Dict). 

# How to use this image

## Providing other dictionaries

```bash
$ docker run --name dictd -v /path/config/file.conf:/etc/dictd.conf -v /path/dictionaries/directory:/usr/lib/dict -d amaccis/dict
```

## Using docker-compose

Here is an example using docker-compose.yml:

```yaml
services:
  dictd: &dict-base 
    image: amaccis/dict
  dict:
    <<: *dict-base
    entrypoint: "dict"
    depends_on:
      - dictd
```

Once the dictd container is up&running, you can use the client to perform queries:

```bash
$ docker-compose run --rm dict -h <dictd_container_ip> hacker
```

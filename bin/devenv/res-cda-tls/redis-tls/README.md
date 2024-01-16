## TLS Certificates

Certificates and CA Certificates are managed in [certs](../certs) and copied into this folder. 

See [Document](../certs/README.md) for working Certificates

See [Redis TLS](https://redis.io/docs/management/security/encryption/) 

See [Redis Configuration](https://redis.io/docs/management/config/) 


## Authenticate using TLS

```shell
# Get into container
docker exec -ti cda-tls-redis /bin/sh

# Login
redis-cli --tls --cacert /usr/local/etc/redis/ca.crt --cert /usr/local/etc/redis/redis.crt --key /usr/local/etc/redis/redis.key
```
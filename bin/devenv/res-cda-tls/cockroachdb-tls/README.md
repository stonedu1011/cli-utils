## TLS Certificates

Certificates and CA Certificates are managed in [certs](../certs) and copied into this folder. 

See [Document](../certs/README.md) for working Certificates

See [Create Security Certificates using OpenSSL](https://www.cockroachlabs.com/docs/v22.2/create-security-certificates-openssl) 

See [Authenticating to CockroachDB](https://www.cockroachlabs.com/docs/v22.2/authentication)


## Authenticate using TLS

```shell
# Get into container
docker exec -ti cda-tls-cockroachdb /bin/sh

# Login
cockroach sql --url="postgresql://root@localhost:26257/defaultdb?sslcert=/cockroach/certs/client.root.crt&sslkey=/cockroach/certs/client.root.key&sslmode=require&sslrootcert=/cockroach/certs/ca.crt"
```
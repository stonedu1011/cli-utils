## Setup Certificates via MacOS KeyChain Access

- Use `KeyChain Access` to create CA and certificates. Steps are not covered in this document.

- Right click Certificate in the APP and select `Export "..."`

- The exported file need to be converted into PEM format for general usage.

### Convert `.cer` (DER) to `.crt` (PEM)

```shell
openssl x509 -inform DER -in ca.cer -out ca.crt 
openssl x509 -inform DER -in redis.cer -out redis.crt
openssl x509 -inform DER -in client.root.cer -out client.root.crt
openssl x509 -inform DER -in node.cer -out node.crt
```

### Convert Legacy `.p12` (PKCS12) Private Key to PEM

```shell
# read pkcs12
openssl pkcs12 -in ca.p12 -nocerts -provider legacy -provider default -out ca.pem
# remove passphrase
openssl rsa -in ca.pem -out ca.key
```

## Setup Certificates via OpenSSL CLI

> See [Create Security Certificates using OpenSSL](https://www.cockroachlabs.com/docs/v22.2/create-security-certificates-openssl)
> See [This Tutorial](https://stackoverflow.com/questions/21297139/how-do-you-sign-a-certificate-signing-request-with-your-certification-authority)

### Generate RSA Key

```shell
openssl genrsa -out ca.key 4096
```

### Create Root CA Cert

```shell
# Create a new Root CA
openssl req -new -x509 -config ca.cnf -key ca.key -days 3650 -out ca.crt

# Prepare for Signing
rm -f index.txt serial.txt
touch index.txt
echo '01' > serial.txt

# Inspect CA Certificate
openssl x509 -text -in ca.crt
openssl x509 -purpose -in ca.crt
```

### Create Certificates Signed by CA


```shell
### For SSL Server

# Create Cert Request for Server (node.crt)
openssl req -new -config node.cnf -key node.key -out node.csr

# Sign Cert
openssl ca -config ca.cnf -keyfile ca.key -cert ca.crt -policy signing_policy -extensions signing_server_req -days 3650 -outdir . -in node.csr -out node.crt

### Inspect Certificates
openssl x509 -text -in node.crt

### For SSL Client

# Create Cert Request
openssl req -new -config client.root.cnf -key client.root.key -out client.root.csr

# Sign Cert
openssl ca -config ca.cnf -keyfile ca.key -cert ca.crt -policy signing_policy -extensions signing_client_req -days 3650 -outdir . -in client.root.csr -out client.root.crt

### Inspect Certificates
openssl x509 -text -in client.root.crt
```

## Notes

- We use the same RSA 2048 bits key for all certificate for development purpose
- CA key is different

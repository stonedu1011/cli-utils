#!/bin/bash

# $1 name
# $2 CA filename
function importCert() {
  certPath="file:///data/$1.crt"
  keyPath="file:///data/$1.key"
  chainPath="file:///data/$2"
  arn=`aws acm import-certificate --certificate $certPath --private-key $keyPath \
         --certificate-chain $chainPath --tags Key=name,Value=redis \
         | jq -r ".CertificateArn"`
  echo Certificate: $1 - $arn
}

importCert redis "ca-bundle.pem"
importCert client.root "ca-bundle.pem"


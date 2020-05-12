#!/bin/bash
EXISTING_CERT=$(az storage file exists --path certs/cert.pem --share-name dtskombinefileshare --account-name dtskombinestorage)
EXISTS=$(jq '.exists' <<< "$EXISTING_CERT")
if [[ "$EXISTS" == "true" ]]; then
echo Certs already exist, downloading and setting env vars...
az storage file download --path certs/cert.pem --share-name dtskombinefileshare --account-name dtskombinestorage
az storage file download --path certs/pkcs8-plain.pem --share-name dtskombinefileshare --account-name dtskombinestorage
export TF_VAR_KOMBINE_TLS_CERT=`cat cert.pem`
export TF_VAR_KOMBINE_TLS_KEY=`cat pkcs8-plain.pem`
echo Done.
echo Removing certs from source...
rm cert.pem pkcs8-plain.pem
echo Done.
elif [[ "$EXISTS" == "false" ]]; then
echo No existing certs, creating now...
echo "[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

# Details about the issuer of the certificate
[req_distinguished_name]
C = CA
ST = Quebec
L = Gatineau
O = ESDC
OU = DTS-STN
CN = *.dts-stn.com

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names


[alt_names]
IP.1 = 203.0.113.42
DNS.1 = *.dts-stn.com" > openssl-graylog.cnf
openssl req -x509 -days 365 -nodes -newkey rsa:2048 -config openssl-graylog.cnf -keyout pkcs5-plain.pem -out cert.pem
echo Generating a 2048 bit RSA private key
openssl pkcs8 -in pkcs5-plain.pem -topk8 -nocrypt -out pkcs8-plain.pem
echo Done.
echo "Creating directory for certs in azure storage..."
az storage directory create -n certs --share-name dtskombinefileshare --account-name dtskombinestorage
echo Done.
echo Uploading files to azure storage and setting env vars...
az storage file upload --share-name dtskombinefileshare --source pkcs8-plain.pem --path certs/pkcs8-plain.pem --account-name dtskombinestorage
az storage file upload --share-name dtskombinefileshare --source cert.pem --path certs/cert.pem  --account-name dtskombinestorage
export TF_VAR_KOMBINE_TLS_CERT=`cat cert.pem`
export TF_VAR_KOMBINE_TLS_KEY=`cat pkcs8-plain.pem`
echo Done.
echo Removing certs from source...
rm cert.pem pkcs8-plain.pem pkcs5-plain.pem openssl-graylog.cnf
echo Done.
fi
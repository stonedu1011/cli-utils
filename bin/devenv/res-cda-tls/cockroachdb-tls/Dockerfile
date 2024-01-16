FROM cockroachdb/cockroach:latest-v22.2

RUN mkdir -p /cockroach/certs
COPY *.crt /cockroach/certs
COPY *.key /cockroach/certs

WORKDIR /cockroach/
EXPOSE 26257 26258
CMD ["start-single-node", "--host=cockrachdb", "--listen-addr=:26257", "--http-addr=:26258", "--certs-dir", "/cockroach/certs"]


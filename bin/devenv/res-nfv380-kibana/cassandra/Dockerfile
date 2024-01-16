ARG CASSANDRA_VERSION
FROM cassandra:$CASSANDRA_VERSION

ARG LUCENE_VERSION

RUN set -ex; \
  apt-get update && apt-get install -y --no-install-recommends ca-certificates wget; \
  wget -O /usr/share/cassandra/lib/cassandra-lucene-index-plugin-$LUCENE_VERSION.jar \
        "https://search.maven.org/remotecontent?filepath=com/stratio/cassandra/cassandra-lucene-index-plugin/$LUCENE_VERSION/cassandra-lucene-index-plugin-$LUCENE_VERSION.jar"; \
  chmod 644 /usr/share/cassandra/lib/cassandra-lucene-index-plugin-$LUCENE_VERSION.jar; \
  sed -i 's/enable_user_defined_functions:.*/enable_user_defined_functions: true/g' /etc/cassandra/cassandra.yaml;
  
        
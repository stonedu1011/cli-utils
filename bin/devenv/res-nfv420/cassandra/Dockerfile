ARG CASSANDRA_VERSION
FROM cassandra:$CASSANDRA_VERSION

ARG LUCENE_VERSION

# Cassandra 3.11.4 is a really old image and apt-get will complain about SSL. But we need it to install wget
RUN set -eux; \
  apt-get update || exit 0;
  
RUN set -eux; \
  apt-get install -y --no-install-recommends ca-certificates wget; \
  wget -O /usr/share/cassandra/lib/cassandra-lucene-index-plugin-$LUCENE_VERSION.jar \
        "https://search.maven.org/remotecontent?filepath=com/stratio/cassandra/cassandra-lucene-index-plugin/$LUCENE_VERSION/cassandra-lucene-index-plugin-$LUCENE_VERSION.jar"; \
  chmod 644 /usr/share/cassandra/lib/cassandra-lucene-index-plugin-$LUCENE_VERSION.jar; \
  sed -i 's/enable_user_defined_functions:.*/enable_user_defined_functions: true/g' /etc/cassandra/cassandra.yaml; \
  sed -i -E 's/^ *#? *authenticator:.*/authenticator: PasswordAuthenticator/g' /etc/cassandra/cassandra.yaml; \ 
  sed -i -E 's/^ *#? *authorizer:.*/authorizer: CassandraAuthorizer/g' /etc/cassandra/cassandra.yaml;     
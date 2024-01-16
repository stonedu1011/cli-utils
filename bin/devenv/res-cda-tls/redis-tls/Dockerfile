FROM redis:6.2-alpine
COPY redis.conf /usr/local/etc/redis/
COPY redis.crt /usr/local/etc/redis/
COPY redis.key /usr/local/etc/redis/
COPY ca.crt /usr/local/etc/redis/

WORKDIR /data
EXPOSE 6379 6380
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
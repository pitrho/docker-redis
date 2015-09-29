# -*- sh -*-

# Based on
# https://github.com/mweibel/redis-docker/blob/master/Dockerfile
FROM       	ubuntu:12.04
MAINTAINER  pitrho


# Set up the environment
#
ENV DEBIAN_FRONTEND noninteractive


# Update packages
#
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get -y -q upgrade  && apt-get clean


# Install build deps
#
RUN apt-get -y -q install \
	gcc make g++ build-essential libc6-dev tcl wget && \
	apt-get clean


# Download Redis source and install it
#
ENV REDIS_RELEASE 2.8.3
RUN wget http://download.redis.io/releases/redis-$REDIS_RELEASE.tar.gz
RUN tar -zxf redis-$REDIS_RELEASE.tar.gz
RUN \
	cd redis-$REDIS_RELEASE && \
	/usr/bin/make install && \
	cd .. && \
	rm -rf redis-$REDIS_RELEASE


# Move our config file and entrypoint script
# into the Docker image.  Make the latter executable.
#
ADD redis.conf /etc/redis/redis.conf
ADD start_redis.sh /
RUN chmod a+x start_redis.sh


# Add a redis user and
#
RUN useradd redis


# Create Redis data directory
#
ENV REDIS_DIR /var/lib/redis
ENV REDIS_LOG_DIR /var/log/redis
ENV REDIS_DATA_DIR /var/lib/redis
ENV REDIS_PID_DIR /var/run/redis
RUN \
	mkdir -p $REDIS_DIR && \
	mkdir -p $REDIS_LOG_DIR && \
	mkdir -p $REDIS_DATA_DIR && \
	mkdir -p $REDIS_PID_DIR && \
	chown redis:redis $REDIS_DIR && \
	chown redis:redis $REDIS_LOG_DIR && \
	chown redis:redis $REDIS_DATA_DIR && \
	chown redis:redis $REDIS_PID_DIR


# Expose redis port
#
EXPOSE 6379


# Start Redis
#
ENTRYPOINT ["/start_redis.sh"]
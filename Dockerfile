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
#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
#RUN apt-get update
#RUN apt-get upgrade -y

# Install build deps
#
#RUN apt-get install -y gcc make g++ build-essential libc6-dev tcl wget
RUN apt-get install -y gcc make g++ build-essential libc6-dev tcl wget

# Download Redis source and install it
#
ENV REDIS_RELEASE 2.8.3
RUN wget http://download.redis.io/releases/redis-$REDIS_RELEASE.tar.gz
RUN tar -zxf redis-$REDIS_RELEASE.tar.gz
RUN cd redis-$REDIS_RELEASE && /usr/bin/make install


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
RUN mkdir -p $REDIS_DIR
RUN mkdir -p $REDIS_LOG_DIR
RUN mkdir -p $REDIS_DATA_DIR
RUN mkdir -p $REDIS_PID_DIR
RUN chown redis:redis $REDIS_DIR
RUN chown redis:redis $REDIS_LOG_DIR
RUN chown redis:redis $REDIS_DATA_DIR
RUN chown redis:redis $REDIS_PID_DIR


# Expose redis port
#
EXPOSE 6379


# Start Redis
#
ENTRYPOINT ["/start_redis.sh"]
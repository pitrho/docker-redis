# Instructions for building Redis using Ubuntu 14.04

Redis version: 2.8.22

Unlike the [Ubuntu 12.04 configuration](../12.04/README.md), this image uses
the [phusion/baseimage](https://github.com/phusion/baseimage-docker) docker
base image.


## Building the image

Clone the repository

	export IMGTAG="pitrho/trusty-redis"
	git clone https://github.com/pitrho/docker-redis.git
	cd docker-redis/ubuntu/14.04
	docker build -t $IMGTAG .

Verify you have the image locally

	docker images | grep "$IMGTAG"

## Example usage

### Basic usage

Start the image using the default redis.conf included with this repo

	RID=$(docker run -d $IMGTAG)
	RIP=$(docker inspect -format='{{.NetworkSettings.IPAddress}}' $RID)

Now you should be able to connect with `redis-cli` as such

	redis-cli -h $RIP

Clearly, you will need to have a Redis client installed to have the
`redis-cli` command.

### Persisting data across container restarts

To persist data, you'll need to use
[Docker volumes](http://docs.docker.io/en/latest/use/working_with_volumes/).

On the host system, create a directory that will house the persisted
data.

	mkdir -p /tmp/rdata

Now, mount that as a volume when you start up the container and
tell Redis to store its data there

	RID=$(docker run -v /tmp/rdata/:/tmp/rdata/ -d $IMGTAG -d /tmp/rdata/)
	RIP=$(docker inspect -format='{{.NetworkSettings.IPAddress}}' $RID)

Again, you can connect from the host system like

	redis-cli -h $RIP

Go ahead and make some changes, e.g. setting a key/value, etc.  Then,
stop Redis, causing it to flush to disk


	redis 172.17.1.76:6379> set ricky bobby
	OK
	redis 172.17.1.76:6379> shutdown

That will also shutdown the container since Redis was not in daemonized.
Now, start up the container again. And connect again with `redis-cli`.

	redis 172.17.1.76:6379> get ricky
	"bobby"

### Customizing the Redis configuration

Bacause this image uses the base `phusion/baseimage`, it uses runit to start
and manage any services including redis. For this reason, to override any
configuration parameters, a new config file must be specified. To do this, put
the new redis.conf file in a directory on the host, and expose the file as a
volume to the container at path /etc/redis/redis.conf.

### Playing with the container

To get a shell prompt, override the Dockerfile's entrypoint as such

	docker run -t -i --entrypoint /bin/bash $IMGTAG

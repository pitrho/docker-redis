# Docker Precise Redis

This repository contains a Dockerfile and associated
scripts for building a [Redis](http://www.redis.io/)
Docker image from an [Ubuntu 12.04 LTS](http://releases.ubuntu.com/precise/)
base image.  This particular Redis Docker image

* has a reasonable default Redis configuration;
* makes it easy to override those defaults; and,
* makes it easy to persistent your Redis data across container restarts.


## Building the image

Clone the repository

	export IMGTAG="pitrho/precise-redis"
	git clone https://github.com/pitrho/docker-precise-redis.git
	cd docker-precise-redis
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

Clearly, you will need to have a Redis client installed to have the `redis-cli` command.

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

You can override each of the following
[Redis configuration file options](http://redis.io/topics/config)
using the `--` prefix on the option.  These can be passed directly
into the `docker run` command.  E.g., to use an append-only Redis log

	docker run pitrho/precise-redis --appendonly yes

If you want to pass in an entirely different Redis config file,
you'll need to put it in a directory that is exposed to
the running container as a volume.  (The
[Docker cp](http://docs.docker.io/en/master/commandline/command/cp/)
command can only copy files *from* a contain, alas.)

For example, imagine we have a custom Redis config_file at `/tmp/redis/redis.conf`
and we want to start Redis using this.  We'd start the container like

	RID=$(docker run -v /tmp/redis:/tmp/redis -d $IMGTAG /tmp/redis/redis.conf)

### Playing with the container

To get a shell prompt, override the Dockerfile's entrypoint as such

	docker run -t -i --entrypoint /bin/bash $IMGTAG

## License

MIT. See the LICENSE file.


## Contributors

* [Kyle Jensen](https://github.com/kljensen)
* [Gilman Callsen](https://github.com/callseng)

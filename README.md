# Docker Precise Redis

This repository contains the configuration for building a
[Redis](http://www.redis.io/) Docker image using
[Ubuntu 14.04 LTS](http://releases.ubuntu.com/trusty/). This particular Redis
Docker image

* has a reasonable default Redis configuration;
* makes it easy to override those defaults; and,
* makes it easy to persistent your Redis data across container restarts,
* makes it easy to backup the redis dump file to AWS S3.


## Building the image

Clone the repository

  	git clone https://github.com/pitrho/docker-redis.git
  	cd docker-redis/ubuntu/14.04
  	./build

De default tag for the new image is pitrho/redis. If you want to specify a
different tag, pass the -t flag along with the tag name:

    ./build -t new/tag

Be default, the image installs the latest stable release. If you want to install
a specific version, pass the -v flag along with the version name:

    ./build -v 3.0.4


## Example usage

### Basic usage

Start the image using the default redis.conf included with this repo:

	docker run -d -p 6739:6739 pitrho/redis


Now you should be able to connect with `redis-cli` as such:

	redis-cli -h <ip-addr>

Clearly, you will need to have a Redis client installed to have the
`redis-cli` command.

### Specifying command line arguments

This image support passing additional arguments to redis-server. To do this,
set the environment variable EXRTA_OPTS to any additional arguments. For example,
if you want to override the entire configuration file, simply mount a volume
to the image (e.g mount at /confg) containing the config file, and set
EXTRAT_OPTS to the new path.

    docker run -d -p 6739:6739 -v /local/path/redis.conf:/config/redis.conf -e EXTRAT_OPTS=/config/redis.conf pitrho/redis


## Database data and volumes

This image does not enforce any volumes on the user. Instead, it is up to the
user to decide how to create any volumes to store the data. Docker has several
ways to do this. More information can be found in the Docker
[user guide](https://docs.docker.com/userguide/dockervolumes/).

Note that the default path where the data is stored inside the container is at
/var/lib/redis. You can mount a volume at this location to create external
backups.


### Playing with the container

To get a shell prompt, override the Dockerfile's entrypoint as such

	docker run -ti --rm pitrho/redis bash


## License

MIT. See the LICENSE file.


## Contributors

* [Kyle Jensen](https://github.com/kljensen)
* [Gilman Callsen](https://github.com/callseng)
* [Alejandro Mesa](https://github.com/alejom99)

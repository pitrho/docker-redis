# Docker Redis

This repository contains the configuration for building a
[Redis](http://www.redis.io/) Docker image using
[Ubuntu 14.04 LTS](http://releases.ubuntu.com/trusty/). This particular Redis
Docker image:

* has a reasonable default Redis configuration;
* makes it easy to override those defaults; and,
* makes it easy to persist your Redis data across container restarts,
* makes it easy to backup the redis dump file to AWS S3.
* makes it easy to run a master/slave redis cluster using Sentinel.


## Building the image

Clone the repository

  	git clone https://github.com/pitrho/docker-redis.git
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
if you want to set a password for redis, you could run the image as follows:

    docker run -d -p 6739:6739 -v /local/path/redis.conf:/config/redis.conf -e EXTRAT_OPTS=--requirepass new_password

### Overriding the standard configuration file

To override the entire configuration file, simply mount a volume
to the image at path `/etc/redis/redis.conf`.

### Running redis under a different account

By default, redis runs under the `redis` user account. If you need to run it
under a different user (e.g root), set environment variable `REDIS_RUN_USER` to the new
account name.    

## Creating a redis master/slave cluster using Sentinel

This image can be used to create a master/slave cluster using redis Sentinel.
To do this, set the environment variable `ENABLE_SENTINEL` to `true` and
the image will take care of the rest. Make sure to first start one instance,
then second (first slave) instance, then the third (next slave), etc. You must
start the instances in sequence and wait for the previous instance to join the
cluster before starting a new one.

### Cluster config parameters:

The following cluster parameters can be modified using environment variables:

  * SENTINEL_CLUSTER_NAME: The name of the cluster. Defaults to `redis-cluster`.
  * SENTINEL_CLUSTER_QUORUM: The quorum is the number of Sentinels that need to
    agree about selecting the new master.
  * SENTINEL_DOWN_AFTER_MILLISECONDS: time in milliseconds an instance should
    not be reachable for a Sentinel starting to think it is down.
  * SENTINEL_PARALLEL_SYNCS: the number of slaves that can be reconfigured to
    use the new master after a failover at the same time
  * SENTINEL_FAILOVER_TIMEOUT: The failover timeout.
  * REDIS_MASTER_IP: The IP address of the intial master instance.
  * IS_SLAVE: Must be set to `true` for all slave instances. Defaults to `false`

More information about Sentinel can be found at http://redis.io/topics/sentinel.

## Running a master/slave cluster in Rancher

This image can also be used to run a master/slave cluster service in Rancher.
Simply follow the steps above to start the cluster. The only difference is that
this image will auto detect the intial master and configure any subsequent
instances as slave. To get this to work, you must set the following environment
variables as follows:

  * RANCHER_SENTINEL_SERVICE: The name of the rancher service that will contain
    the cluster instances.
  * REDIS_MASTER_IP: Do not set this environment variable.
  * IS_SLAVE: Do not set this environment variable.

## Database data and volumes

This image does not enforce any volumes on the user. Instead, it is up to the
user to decide how to create any volumes to store the data. Docker has several
ways to do this. More information can be found in the Docker
[user guide](https://docs.docker.com/userguide/dockervolumes/).

Note that the default path where the data is stored inside the container is at
/var/lib/redis. You can mount a volume at this location to create external
backups.

## Backups

This image has the ability to upload backups to AWS s3 using a cron schedule. To
use this, you need to set the following environment variables:

  * `CRON_TIME` = Cron time schedule. Example: `0 5 * * * root`
  * `S3_BUCKET` = relative s3 bucket path. Example: `bucket/folder1/.../folderN`
  * `AWS_ACCESS_KEY_ID` = Your aws access key id
  * `AWS_SECRET_ACCESS_KEY` = Your aws secret key
  * `AWS_DEFAULT_REGION` = The aws default region. Example: `us-east-1`
  * `REDIS_DB` = This is optional. Only set it if you have overridden the
  default database file name (dump.rdb)

Note that the image only uploads backups to s3, but it does not remove any old
backups. To do this, we suggest you use the s3 lifecycle policies to archive
and remove old files.

For this to run as a separate container, you must expose the directory /var/lib/redis
from the main container as a volume, and then use volumes-from in the backup
container.

### Backups under a master/slave cluster

When running a master/slave cluster, setup the backup as mentioned above. The
image will internally check if it's the master, and if so, proceed with the
backup. This means that the backup will not be executed in any of the slave
instances.

### Playing with the container

To get a shell prompt, override the Dockerfile's entrypoint as such

	docker run -ti --rm pitrho/redis bash


## License

MIT. See the LICENSE file.


## Contributors

* [Kyle Jensen](https://github.com/kljensen)
* [Gilman Callsen](https://github.com/callseng)
* [Alejandro Mesa](https://github.com/alejom99)

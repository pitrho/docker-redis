#!/bin/bash

REDIS_VERSION="stable"
IMAGE_TAG="pitrho/redis"

# Custom die function.
#
die() { echo >&2 -e "\nRUN ERROR: $@\n"; exit 1; }

# Parse the command line flags.
#
while getopts "v:t:" opt; do
  case $opt in
    t)
      IMAGE_TAG=${OPTARG}
      ;;

    v)
      REDIS_VERSION=${OPTARG}
      ;;

    \?)
      die "Invalid option: -$OPTARG"
      ;;
  esac
done

# Crete the build directory
rm -rf build
mkdir build

cp start_redis.sh build/
cp enable_backups.sh build/
cp backup.sh build/

# Copy docker file, and override the REDIS_VERSION string
sed 's/%%REDIS_VERSION%%/'"$REDIS_VERSION"'/g' Dockerfile.tmpl > build/Dockerfile

docker build -t="${IMAGE_TAG}" build/

rm -rf build

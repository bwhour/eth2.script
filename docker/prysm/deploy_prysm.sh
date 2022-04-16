#!/bin/bash

set -e
set -o pipefail

image="gcr.io/prysmaticlabs/prysm/beacon-chain"
tag=$1

if [[ -z "$tag" ]]; then
  echo "Empty tag name"
  exit 1
fi

app_path="/home/amber/.eth2"
now=$(date +"%Y-%m-%d_%H-%M-%S-%p")
logfile="$app_path/logs/deploy_$now.log"

cd $app_path

mkdir -p logs
touch $logfile

{
echo "=== Date: $now"
echo ""

echo "=== Deploing now:"
echo "=== Image: $image"
echo "=== Tag: $tag"
echo ""

sed -i -e "s#.*PRYSM_VERSION=.*#PRYSM_VERSION=$tag#" .env

echo "=== Remove unused data"
docker system prune -f
docker system prune -af
echo ""

echo "=== Pull new image"
docker pull $image:$tag
echo ""

echo "=== Update containers"
#docker-compose up -d
docker-compose run --rm beacon-node
echo ""

sleep 5s

docker images
echo ""
docker ps -a
echo ""

} 2>&1 | tee -a "$logfile"


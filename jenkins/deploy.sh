echo "WORKSPACE: "$1
echo "BUILD_NUMBER: "$2

WORKSPACE=$1
BUILD_NUMBER=$2

docker ps -q | xargs docker stop
docker ps -a -q | xargs docker rm

cd ${WORKSPACE}/jenkins/base

docker build --build-arg CACHE_BUILD=${BUILD_NUMBER} -t jenkins-practice_${BUILD_NUMBER} .
docker run -p 80:80 -d jenkins-practice_${BUILD_NUMBER}
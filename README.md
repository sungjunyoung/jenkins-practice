# 5월 9일 스터디
## Jenkins / Docker

---
## check list
vue-cli `npm install -g vue-cli`
docker ps
nginx status

---

1. vue.js project init
```sh
vue init webpack jenkins-practice
```
2. git configuration
```sh
cd jenkins-practice
git init
# 레포지토리 생성 (github.com)
git remote add origin <github repository url>
git add .
git commit -m "Init vuejs project"
git push --set-upstream origin master
```
3. 개발모드로 실행해보기
```sh
npm run dev
# (localhost:8080 / 127.0.0.1:8080)
```

--- 
3. 빌드해보기
```sh
node build/build.js
# dist 폴더 생성됨
```
5. nginx 포트변경
```sh
# mac 만! 윈도우는 기둘
vi /usr/local/etc/nginx/nginx.conf
8080 -> 3000 으로 변경 (vuejs 랑 겹쳐서)
sudo nginx -s stop
sudo nginx
```

4. nginx 로 렌더해보기
```sh
# mac 만! 윈도우는 기둘
rm -rf /usr/local/Cellar/nginx/1.13.12/html/*
cp -r dist/* /usr/local/Cellar/nginx/1.13.12/html/
```

---
5. 소스 변경해보기
- vue 로고 자기 프로필로 변경해보기
- 소개 링크들 자기 facebook, instagram 으로 변경해보기
- npm run dev

6. 변경된 소스 빌드하고, nginx 로 렌더해보기
```sh
node build/build.js # 빌드
# 기존 파일 삭제
rm -rf /usr/local/Cellar/nginx/1.13.12/html/* 
# 빌드된 파일로 대체
cp -r dist/* /usr/local/Cellar/nginx/1.13.12/html/ 
# nginx 리로드 (mac only)
sudo nginx -s reload
```
---
7. 소스를 빌드하고, nginx 렌더 디렉토리에 넣고 reload - jenkins 자동화를 하려면...
	1. jenkins 서버에 node / nginx / vue-cli 등등 설치
	2. 프로젝트 빌드
	3. 기존 nginx 렌더 디렉토리 있던 파일 삭제
	4. 빌드된 파일들로 대체
	5. nginx reload ...
	> 충분히 괜찮은 과정? BUT...

SOLUTION => DOCKER

---
7. Dockerfile 이란...
8. Dockerfile 만들어보기
```sh
mkdir -p jenkins/base
touch jenkins/base/Dockerfile
touch jenkins/deploy.sh
```
---
9. Dockerfile 수정
```dockerfile
FROM ubuntu:16.04

# install native dependency
RUN apt-get update -y
RUN apt-get install -y curl gnupg apt-utils build-essential nginx git

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

ARG CACHE_BUILD

# repository clone, install dependencies, build
RUN git clone https://github.com/sungjunyoung/jenkins-practice.git
RUN cd jenkins-practice && npm install && node build/build.js

# nginx host
RUN rm -rf /var/www/html/*
RUN cp -r /jenkins-practice/dist/* /var/www/html/

# port config
EXPOSE 80

# start nginx with daemon mode off
CMD ["nginx", "-g", "daemon off;"]
```
---
10. deploy.sh 수정
```sh
echo "WORKSPACE: "$1
echo "BUILD_NUMBER: "$2

WORKSPACE=$1
BUILD_NUMBER=$2

docker ps -q | xargs docker stop
docker ps -a -q | xargs docker rm

cd ${WORKSPACE}/jenkins/base

docker build --build-arg CACHE_BUILD=${BUILD_NUMBER} -t jenkins-practice_${BUILD_NUMBER} .
docker run -p 80:80 -d jenkins-practice_${BUILD_NUMBER}

```
---
11. jenkins 서버에 docker 설치
```sh
jenkins> sudo apt-get update
jenkins> sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
jenkins> curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
jenkins> sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
jenkins> sudo apt-get update
jenkins> sudo apt-get install docker-ce
```
12. jenkins 유저에게 sudo 패스워드 묻지 않게 변경
```
jenkins> vi /etc/sudoers
jenkins ALL=NOPASSWD: ALL
```

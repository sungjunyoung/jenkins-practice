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
# Original source from https://hub.docker.com/_/node/
FROM node:9.7.1-alpine
MAINTAINER Neal Shyam <neal@spokenlayer.com>


# NPM_CONFIG_PREFIX: See below
# PATH: Required for ask cli location
ENV TZ="GMT" \
  NPM_CONFIG_PREFIX=/home/node/.npm-global \
  PATH="${PATH}:/home/node/.npm-global/bin/:/home/node/.local/bin/"

# Required pre-reqs for ask cli
RUN apk add --update --no-cache \
  python \
  make \
  bash \
  py-pip \
  jq

# basic flask environment
RUN apk add --no-cache bash git nginx uwsgi uwsgi-python py2-pip nano \
	&& pip2 install --upgrade pip \
	&& pip2 install flask

# application folder
ENV APP_DIR /app

# app dir
RUN mkdir ${APP_DIR} \
	&& chown -R nginx:nginx ${APP_DIR} \
	&& chmod 777 /run/ -R \
	&& chmod 777 /root/ -R
VOLUME [${APP_DIR}]
WORKDIR ${APP_DIR}

# expose web server port
# only http, for ssl use reverse proxy
EXPOSE 5000

# copy config files into filesystem
COPY nginx.conf /etc/nginx/nginx.conf
COPY app.ini /app.ini
COPY startup.sh /startup.sh
COPY entrypoint.sh /entrypoint.sh
COPY app/ /home/node/app/

RUN chmod 777 /home/node/app -R

# See https://github.com/nodejs/docker-node/issues/603
# ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
USER node

# /home/node/.ask: For ask CLI configuration file
# /home/node/.ask: Folder to map to for app development
RUN npm install -g ask-cli bespoken-tools && \
  mkdir /home/node/.ask && \
  mkdir /home/node/.aws && \
  mkdir /home/node/.bst && \
  pip install awscli --upgrade --user

# Patch for  https://github.com/martindsouza/docker-amazon-ask-cli/issues/1
WORKDIR /$NPM_CONFIG_PREFIX/lib/node_modules/ask-cli
RUN npm install simple-oauth2@1.5.0 --save-exact

# Volumes:
# /home/node/.ask: This is the location of the ask cli config folder
# /home/node/.aws: This is the location of the aws sdk config folder
# /home/node/.bst: This is the location of the bespoken config folder
# /home/node/app: Your development folder
VOLUME ["/home/node/.ask", "/home/node/.aws", "/home/node/.bst"]

# Default folder for developers to work in
WORKDIR /home/node/app

# execute start up script
#RUN ["chmod", "+x", "/entrypoint.sh"]
#RUN ["chmod", "+x", "/startup.sh"]
ENTRYPOINT ["/entrypoint.sh"]
# Enable this if you want the container to permanently run
CMD ["/bin/bash"]
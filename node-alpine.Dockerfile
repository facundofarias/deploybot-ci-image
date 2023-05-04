FROM node:14.21.0-alpine3.15

RUN apk update
RUN apk add --no-cache --virtual .gyp python2 make g++
RUN apk add git openssh rsync curl

RUN npm install --quiet node-gyp -g
RUN npm install --quiet gulp-cli -g

RUN mkdir /src

CMD ["bash"]
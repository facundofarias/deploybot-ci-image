FROM node:14.21.3-alpine

RUN apk update
RUN apk add git openssh rsync curl

RUN mkdir /src

CMD ["bash"]
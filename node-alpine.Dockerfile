FROM node:lts-alpine

RUN apk update
RUN apk add git openssh rsync curl

RUN mkdir /src

CMD ["bash"]
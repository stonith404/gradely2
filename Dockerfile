#Docker file to deploy the web app
#To publish run `flutter build web --release && buildx ghcr.io/generalxhd/gradely2-app-web`
FROM alpine
RUN apk update
RUN apk add --no-cache php

WORKDIR /usr/src/app
COPY ./build/web ./

EXPOSE 80

CMD [ "php", "-S","0.0.0.0:80"]
#Docker file to deploy the web app
#To publish run `flutter build web --release && buildx ghcr.io/stonith404/gradely2-webapp`
FROM nginx:alpine

COPY ./build/web /usr/share/nginx/html

EXPOSE 80
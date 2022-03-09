#Docker file to deploy the web app
#To publish run `flutter build web --release && docker buildx build -t ghcr.io/stonith404/gradely2-webapp --platform linux/amd64,linux/arm64  --push .`
FROM nginx:alpine

COPY ./build/web /usr/share/nginx/html

EXPOSE 80
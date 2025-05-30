#
# Sneaklardooon Dockerfile.
#
#
FROM golang:alpine3.21 AS build-env
#
# Copy source from repo submodules
COPY /sneaker /sneaker_build
COPY /lardoon /lardoon_build
COPY /jambon /jambon_build
#
# Install pre-reqs
RUN apk --no-cache add build-base git ca-certificates nodejs-current yarn npm gcc
#
# Make the app dir so the binaries have somewhere to go
RUN mkdir /app
#
# Build Sneaker
WORKDIR /sneaker_build
RUN go install github.com/josephspurrier/goversioninfo/cmd/goversioninfo@latest 
RUN yarn && yarn build
RUN go generate && env GOOS=linux GOARCH=386 go build -o ./sneaker cmd/sneaker-server/main.go && chmod +x sneaker && mv sneaker /app/sneaker
#
# Build Lardoon
WORKDIR /lardoon_build
RUN export NODE_ENV=production && npm ci --include=dev && npm run build
RUN env CGO_ENABLED=1 CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=amd64 go build -v -o ./lardoon cmd/lardoon/main.go && chmod +x lardoon && mv lardoon /app/lardoon
#
# Build Jambon
WORKDIR /jambon_build
RUN go mod download && env GOOS=linux GOARCH=amd64 go build -v -o ./jambon cmd/jambon/main.go && chmod +x jambon && mv jambon /app/jambon
#
#################### Create main Docker image ####################
#
FROM ghcr.io/linuxserver/baseimage-alpine:3.22
LABEL maintainer="Aterfax"
#
COPY --from=build-env /app /app/
RUN chmod +x -R /app/
#
# Note that folder user and group ownership is handled in the s6 init script for binaries to start up.
# e.g. docker_src/s6-src/s6-services/s6-init-sneaker-webgci/run
#
# General setup
COPY docker_src/s6-src/branding /etc/s6-overlay/s6-rc.d/init-adduser/branding
#
# Sneaker
COPY docker_src/s6-src/s6-services/s6-init-sneaker-webgci /etc/s6-overlay/s6-rc.d/init-sneaker-webgci
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-sneaker-webgci
#
# Jambon
COPY docker_src/s6-src/s6-services/s6-init-jambon /etc/s6-overlay/s6-rc.d/init-jambon
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-jambon
#
# Lardoon Web (Serves the portal and spawns the import daemon.)
COPY docker_src/s6-src/s6-services/s6-init-lardoon-web /etc/s6-overlay/s6-rc.d/init-lardoon-web
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-lardoon-web
# 
# No user config file will result in the defaults being present.
COPY docker_src/sneaker-cfg/ /config/sneaker/
COPY docker_src/lardoon-cfg/ /config/lardoon/

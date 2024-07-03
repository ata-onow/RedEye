FROM node:18-bullseye as redeye-builder

WORKDIR /app
COPY ./ ./
ENV CYPRESS_INSTALL_BINARY=0
RUN npm install -g pkg rimraf
RUN yarn install --immutable --inline-builds
RUN yarn moon run server:build client:build
RUN bash create-release.sh
RUN tar -zcvf release.tar.gz ./release/
RUN mkdir outputs
RUN cp release.tar.gz outputs/release.tar.gz

FROM node:18-bullseye as redeye-linux-builder

WORKDIR /app
COPY ./ ./
ENV CYPRESS_INSTALL_BINARY=0
RUN yarn install --immutable --inline-builds
RUN npx pkg-fetch --platform linux --node-range node18
RUN yarn release:linux

### CORE IMAGE ###
FROM debian:12.6 as redeye-core
WORKDIR /app
COPY --from=redeye-linux-builder /app/release/linux .
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD ["./RedEye"]

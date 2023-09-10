FROM node:lts-bullseye

RUN apt-get update && apt-get install -y tini

COPY . /ai

WORKDIR /ai
RUN npm install --save @types/babel__traverse@7.18.3 && npm run build

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD npm start

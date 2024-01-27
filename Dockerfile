FROM node:lts

RUN apt-get update && apt-get install tini --no-install-recommends -y && apt-get clean && rm -rf /var/lib/apt-get/lists/*

ARG enable_mecab=1

RUN if [ $enable_mecab -ne 0 ]; then apt-get update \
  && apt-get install git patch openssl mecab libmecab-dev mecab-ipadic-utf8 make curl xz-utils file sudo --no-install-recommends -y \
  && apt-get clean \
  && rm -rf /var/lib/apt-get/lists/* \
  && cd /opt \
  && export GIT_SSL_NO_VERIFY=1 \
  && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
  && cd /opt/mecab-ipadic-neologd \
  && ./bin/install-mecab-ipadic-neologd -n -y \
  && rm -rf /opt/mecab-ipadic-neologd \
  && echo "dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd/" > /etc/mecabrc \
  && apt-get purge git patch openssl make curl xz-utils file -y \
  && apt-get autoremove -y; else mkdir -p /usr/lib/x86_64-linux-gnu/mecab; fi

COPY . /ai

WORKDIR /ai
RUN npm install && npm run build || test -f ./built/index.js

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD npm start

FROM node:lts-jessie-slim

RUN apt-get update && apt-get install -y \
  curl make xvfb apt-transport-https ca-certificates gnupg --no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y google-chrome-stable --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ADD xvfb-chrome /usr/bin/xvfb-chrome

RUN chmod 755 /usr/bin/xvfb-chrome \
  && mv /usr/bin/google-chrome /usr/bin/google-chrome-bin \
  && ln -s /usr/bin/xvfb-chrome /usr/bin/google-chrome \
  && usermod -l docker node \
  && usermod -m -d /home/docker docker \
  && groupmod --new-name docker node \
  && groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
  && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome \
  && chown -R chrome:chrome /opt/google/chrome \
  && mkdir /home/docker/app \
  && chown -R docker:docker /home/docker

EXPOSE 5000
USER docker
WORKDIR /home/docker/app
ENV HOME="/home/docker"

RUN npm i -g pm2 && ~/npm/bin/pm2 start sockets-server.js && ~/npm/bin/pm2 start http-server.js

CMD ["/usr/bin/google-chrome", "http://localhost:3000/"]

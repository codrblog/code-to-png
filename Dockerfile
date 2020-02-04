FROM node:lts-jessie-slim

RUN apt-get update && apt-get install -y \
  curl make xvfb apt-transport-https ca-certificates gnupg --no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y google-chrome-stable --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ADD xvfb-chrome /usr/bin/xvfb-chrome

RUN chmod 755 /usr/bin/xvfb-chrome \
  && rm /usr/bin/google-chrome \
  && ln -s /usr/bin/xvfb-chrome /usr/bin/google-chrome \
  && usermod -l docker node \
  && usermod -m -d /home/docker docker \
  && groupmod --new-name docker node \
  && groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
  && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome \
  && chown -R chrome:chrome /opt/google/chrome \
  && mkdir /home/docker/app \
  && chown -R docker:docker /home/docker

# Variable for Karma tests to recognize chrome
ENV CHROME_BIN=/usr/bin/google-chrome

EXPOSE 5000

USER docker
WORKDIR /home/docker/app
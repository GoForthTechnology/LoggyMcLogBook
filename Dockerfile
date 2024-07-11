FROM ubuntu:20.04

ARG SSH_PRIVATE_KEY

# Setup
RUN apt-get update && apt-get install -y unzip xz-utils git openssh-client curl python3 && apt-get upgrade -y && rm -rf /var/cache/apt

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter doctor -v

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN mkdir -p ~/.ssh \
&& umask 0077 \
&& eval `ssh-agent -s` \
&& echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa \
&& ssh-add ~/.ssh/id_rsa \
&& ssh-keyscan github.com >> ~/.ssh/known_hosts \
&& flutter pub get \
&& flutter build web

# Record the exposed port
EXPOSE 5000

# make server startup script executable and start the web server
RUN ["chmod", "+x", "/app/server/server.sh"]

ENTRYPOINT [ "/app/server/server.sh"]
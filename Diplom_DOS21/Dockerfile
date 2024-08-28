FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    nginx \
    mysql-server \
    nodejs \
    npm

WORKDIR /app

COPY . /app

RUN chmod +x /app/start.sh

CMD ["./start.sh"]

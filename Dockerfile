FROM gradle:9.4.1-jdk25

RUN apt-get update && apt-get install -qq -y --no-install-recommends

ENV INSTALL_PATH /barber-shop-api

RUN mkdir $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY . .
FROM debian:11
RUN apt update && apt install -y imagemagick && apt-clean
ADD ./* /app
WORKDIR /app
CMD ["/bin/bash", "-c", "badgen.sh" ]

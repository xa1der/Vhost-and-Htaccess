FROM ubuntu

RUN apt-get update

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt-get update && apt-get install -y tzdata

RUN apt-get install -y apache2-utils

RUN apt-get install -y apache2

COPY index.html /var/www/html/

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80

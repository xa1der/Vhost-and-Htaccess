#####Intial Image and Installations 
FROM ubuntu

RUN apt-get update

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt-get update && apt-get install -y tzdata

RUN apt-get install apache2-utils -y

RUN apt-get install -y apache2 -y
###USER 1 Configurations #####
RUN useradd -ms /bin/bash user1

USER user1

RUN mkdir /home/user1/public_html

COPY ./index.html /home/user1/public_html

RUN mkdir /home/user1/public_html/Dev

COPY ./secret.html /home/user1/public_html/Dev 

RUN htpasswd -c /home/user1/.htpasswd 4@@Captain

COPY ./.htaccess /home/user1/public_html/Dev
 
#######Apache and Virtual Hosts Configurations ######
USER root

RUN a2dissite 000-default.conf

RUN mkdir /var/www/html/site1

RUN mkdir /var/www/html/site2

RUN mkdir /var/www/html/site3

COPY ./domain1.html /var/www/html/site1

COPY ./domain2.html /var/www/html/site2

COPY ./domain3.html /var/www/html/site3

COPY ./site1.conf /etc/apache2/sites-available

COPY ./site2.conf /etc/apache2/sites-available

COPY ./site3.conf /etc/apache2/sites-available

RUN a2ensite site1.conf

RUN a2ensite site2.conf 

RUN a2ensite site3.conf 

RUN service apache2 restart

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80

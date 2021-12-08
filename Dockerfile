#####Intial Image and Installations 
FROM ubuntu

RUN apt-get update

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt-get update && apt-get install -y tzdata

RUN apt-get install apache2-utils -y

RUN apt-get install -y apache2 -y

#####Proxy Install and enable####
RUN apt-get update

RUN service apache2 stop

RUN service apache2 start

RUN service apache2 restart

RUN a2enmod proxy

RUN a2enmod proxy_http

RUN a2enmod proxy_balancer

RUN a2enmod lbmethod_byrequests
###Self Signed CERT##########
RUN apt-get update && \
    apt-get install -y openssl && \
    openssl genrsa -des3 -passout pass:x -out /etc/ssl/private/server.pass.key 2048 && \
    openssl rsa -passin pass:x -in /etc/ssl/private/server.pass.key -out /etc/ssl/private/server.key && \
    rm /etc/ssl/private/server.pass.key && \
    openssl req -new -key /etc/ssl/private/server.key -out /etc/ssl/certs/server.csr \
        -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=site1.internal" && \
    openssl x509 -req -days 365 -in /etc/ssl/certs/server.csr -signkey /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt

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

RUN mkdir /var/www/html/site2

RUN mkdir /var/www/html/site3

COPY ./domain2.html /var/www/html/site2

COPY ./domain3.html /var/www/html/site3

#############Upate images for site1.internal######
RUN mkdir /home/images

COPY ./image1.jpg /home/images

COPY ./image2.jpg /home/images

COPY ./image3.jpg /home/images
######################################

COPY ./site1.conf /etc/apache2/sites-available

COPY ./proxy-site2.conf /etc/apache2/sites-available

COPY ./proxy-site3.conf /etc/apache2/sites-available

COPY ./proxy-site1-ssl.conf /etc/apache2/sites-available

RUN a2ensite site1.conf

RUN a2ensite proxy-site2.conf 

RUN a2ensite prxy-site3.conf 

RUN service apache2 restart

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80

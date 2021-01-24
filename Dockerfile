# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nhill <marvin@42.fr>                       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/01/14 17:31:29 by nhill             #+#    #+#              #
#    Updated: 2021/01/22 16:52:10 by nhill            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#задаёт базовый (родительский) образ
FROM debian:buster

#устанавливает постоянные переменные среды
ENV AUTOINDEX on

#загружаем все необходимое нам
RUN apt-get update && apt-get install -y \
    nginx \
    mariadb-server \
    php-fpm \
    php-mysql \
    php-mbstring \
    wget \
    && rm -rf /var/lib/apt/lists/*

#Nginx использует директиву daemon off для запуска на переднем плане
RUN     echo "daemon off;" >> /etc/nginx/nginx.conf && \
        rm var/www/html/index.nginx-debian.html
COPY	srcs/nginx/*.conf /tmp/

# PHPMYADMIN
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz && \
    tar -xzvf phpMyAdmin-5.0.4-all-languages.tar.gz && \
    mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin && \
    rm -rf phpMyAdmin-5.0.4-all-languages.tar.gz
COPY srcs/phpmyadmin/config.inc.php /var/www/html/phpmyadmin

# WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzvf latest.tar.gz && \
    mv wordpress /var/www/html/ && \
    rm -rf latest.tar.gz
COPY srcs/wordpress/wp-config.php /var/www/html/wordpress

# SLL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/selfsigned.key \
    -out /etc/ssl/selfsigned.pem \
    -subj "/C=RU/ST=Tatarstan/L=Kazan/O=21 school/OU=nhill/CN=localhost"

# права пользователя 
RUN	chown -R www-data:www-data /var/www/html/*

COPY srcs/*.sh ./

EXPOSE 80 443

CMD bash start.sh

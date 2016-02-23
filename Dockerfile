FROM ubuntu:14.04
MAINTAINER Invision <invision70@gmail.com>

# LABEL todokey.type="service"

ENV SERVICE_ALIAS test-service
ENV SERVICE_PATH /var/www/services/$SERVICE_ALIAS
ENV SERVICE_PORT 80
ENV PG_USER someuser
ENV PG_PWD somepassword
ENV GITHUB https://github.com/Invision70/lumen-test-service


# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Postgres PPA
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN apt-get install -y wget
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -

RUN apt-get update && apt-get install -y \
    python-software-properties \
    software-properties-common \
    postgresql-9.5 \
    postgresql-contrib \
    nginx \
    memcached \
    curl \
    git \
    mercurial \
    unzip \
    php5-fpm \
    php5-pgsql \
    php5-memcached \
    php5-curl \
    php5-gd \
    php5-mcrypt \
    php5-curl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# nginx service conf
COPY ./nginx.conf /etc/nginx/sites-enabled/$SERVICE_ALIAS
RUN rm /etc/nginx/sites-enabled/default

# Postgres user
USER postgres
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER $PG_USER WITH SUPERUSER PASSWORD '$PG_PWD';" &&\
    createdb -O $PG_USER $SERVICE_ALIAS

# Adjust PostgreSQL configuration so that remote connections to the database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

USER root
# Service initialization
VOLUME ["$SERVICE_PATH"]
# copy project on initial
ADD . $SERVICE_PATH
RUN chown -R www-data:www-data $SERVICE_PATH
RUN chmod -R 0777 $SERVICE_PATH

# install components
WORKDIR $SERVICE_PATH
RUN composer install

# private expose
EXPOSE 5432
EXPOSE $SERVICE_PORT

VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.5/bin/postgres", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]
CMD service nginx start
CMD service php5-fpm start
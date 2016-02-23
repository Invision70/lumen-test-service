# vars
SERVICE_ALIAS="test-service"
SERVICE_PATH="/var/www/services/$SERVICE_ALIAS"
GIT_PATH="https://github.com/Invision70/lumen-test-service"
ENV_PATH="$SERVICE_PATH/.env"

DB_PASSWORD=`pwgen -c -n -1 12`
echo $MYSQL_PASSWORD > /db-root-pw.txt

# install service
mkdir -p $SERVICE_PATH
git clone $GIT_PATH $SERVICE_PATH
cd $SERVICE_PATH
composer install --no-dev

# configure ENV
printf 'APP_ENV=local\n' > $ENV_PATH
printf 'APP_DEBUG=true\n' >> $ENV_PATH
printf 'APP_KEY=random1010101011102\n' >> $ENV_PATH
printf 'DB_CONNECTION=pgsql\n' >> $ENV_PATH
printf 'DB_HOST=localhost\n' >> $ENV_PATH
printf 'DB_PORT=5432\n' >> $ENV_PATH
printf "DB_DATABASE=$SERVICE_ALIAS\n" >> $ENV_PATH
printf 'DB_USERNAME=someuser\n' >> $ENV_PATH
printf 'DB_PASSWORD=somepassword' >> $ENV_PATH

CACHE_DRIVER=memcached
QUEUE_DRIVER=sync


chown -R www-data:www-data $SERVICE_PATH
/etc/init.d/postgresql start
yes | php artisan migrate
/etc/init.d/postgresql stop


# start all the services
/usr/local/bin/supervisord -n

VERSION="$1"
ROOT_DIR="$HOME/docker-openbill-webhooks"
SERVICE_NAME="openbill_webhooks"


if [ -d "$ROOT_DIR/openbill-webhooks" -a -d "$ROOT_DIR/openbill-webhooks/.git" ];
then
	echo 'Running git pull'
	cd $ROOT_DIR/openbill-webhooks && git pull;
else
	echo "clone repo IN $ROOT_DIR/openbill-webhooks"
	cd $ROOT_DIR && git clone https://github.com/openbill-service/openbill-webhooks.git
fi

cd ~/docker-openbill-webhooks && docker build -t $SERVICE_NAME:$VERSION .
docker stop $SERVICE_NAME


export APP_ROOT=/home/wwwkiiiosk/kiiiosk.ru/current/
export DB_NAME=$(cat $APP_ROOT/config/database.yml |grep 'database:'| awk '{print $2}'); 
export DB_HOST=$(cat $APP_ROOT/config/database.yml|grep host |awk '{print $2}');
export DB_PORT=$(cat $APP_ROOT/config/database.yml|grep 'port:' |awk '{print $2}');
export DB_PASSWORD=$(cat $APP_ROOT/config/database.yml|grep 'password:' |awk '{print $2}');
export DB_USERNAME=$(cat $APP_ROOT/config/database.yml|grep 'username:' |awk '{print $2}');


docker ps -a | grep Exit |grep $SERVICE_NAME|cut -d ' ' -f 1|xargs docker rm

docker run \
	--name 'openbill_webhooks' \
	-e 'PGREQUIRESSL=false' \
	-e "PGDATABASE=$DB_NAME" \
	-e "PGUSER=$DB_USERNAME" \
	-e "PGPASSWORD=$DB_PASSWORD" \
	-e "PGHOST=$DB_HOST" \
	-e "PGPORT=$DB_PORT" -itd openbill_webhooks:$VERSION

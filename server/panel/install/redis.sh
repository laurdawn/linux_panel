#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
redis_version=yum
runPath=/root
setupPath=/usr/bin/
versionPath=/www/server/redis

check_Redis()
{
	status=`rpm -qa |grep redis`
	if [ ! -z "$status" ];then
		Uninstall_Redis
	fi
}

Install_Redis()
{
	yum install -y redis
	chkconfig redis on
	sed -i 's?bind 127.0.0.1?bind 0.0.0.0?g' /etc/redis.conf
	sed -i '$i\  <port protocol="tcp" port="6379"/>' /etc/firewalld/zones/public.xml
	firewall-cmd --reload

	echo "#!/bin/sh
# chkconfig: 2345 55 25
# description: Redis Service

### BEGIN INIT INFO
# Provides:          Redis
# Required-Start:    \$all
# Required-Stop:     \$all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts Redis
# Description:       starts the BT-Web
### END INIT INFO

# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDISPORT=$(cat /etc/redis.conf |grep -v '#' |grep port |awk '{print $2}')

redis_start(){
systemctl start redis
}
redis_stop(){
systemctl stop redis
}


case \"\$1\" in
start)
	redis_start
    ;;
stop)
    redis_stop
    ;;
restart|reload)
	redis_stop
	sleep 0.3
	redis_start
	;;
*)
    echo \"Please use start or stop as first argument\"
    ;;
esac
" > /etc/init.d/redis
	chmod +x /etc/init.d/redis
	/etc/init.d/redis start
	if [ ! -d "$versionPath" ];then
		mkdir $versionPath
	fi
	#添加到服务列表
	chkconfig --add redis
	chkconfig --level 2345 redis on

	echo 'yum' > $versionPath/version.pl
	echo '==============================================='
	echo 'successful!'
}

Uninstall_Redis()
{
	yum remove -y redis
	sed -i '/6379/d' /etc/firewalld/zones/public.xml
	if [ -d "$versionPath" ];then
		rm -rf $versionPath
	fi
	chkconfig --del redis
	echo '==============================================='
	echo 'successful!'
}
actionType=$1
if [ "$actionType" == 'install' ];then
	check_Redis
	Install_Redis
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_Redis
fi

#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#准备基础数据
Is_64bit=`getconf LONG_BIT`
actionType=$1
setup_path=/home/svnrepos
storage_name='default'

add_storage()
{
    if [ ! -d "$setup_path" ];then
        mkdir $setup_path
    fi
    storage_path=$setup_path/$storage_name
    if [ -d "$storage_path" ];then
    	echo '当前仓库已存在，为确保仓库数据，请手动处理！'
    	exit
    fi
    mkdir $storage_path
    svnadmin create $storage_path
    
	#配置svnserve.conf
	sed -i 's/# anon-access = read/anon-access = none/g' $storage_path/conf/svnserve.conf
	sed -i 's/# auth-access = write/auth-access = write/g' $storage_path/conf/svnserve.conf
	sed -i 's/# password-db = passwd/password-db = .\/..\/..\/passwd/g' $storage_path/conf/svnserve.conf
	sed -i 's/# authz-db = authz/authz-db = .\/..\/..\/authz/g' $storage_path/conf/svnserve.conf
	sed -i 's?# realm = My First Repository?realm = '"$storage_path"'?g' $storage_path/conf/svnserve.conf

    if [ "$storage_name" == 'default' ];then
    	#配置authz
		sed -i '$a\[/]' ${storage_path}/conf/authz
		sed -i '$a\*=' ${storage_path}/conf/authz
		cp ${storage_path}/conf/authz $setup_path
		cp ${storage_path}/conf/passwd $setup_path
	fi
}

check_svn()
{
	status=`yum list installed | grep subversion`
	if [ ! -z "$status" ];then
        uninstall_svn
	fi
}

install_svn()
{
	yum install -y subversion subversion-libs
	#添加仓库
	add_storage
    echo 'yum' > $setup_path/version.pl
    #cp /www/server/panel/install/system/subversion /etc/init.d/subversion
    echo "#!/bin/sh
 
### BEGIN INIT INFO
# Provides:          subversion
# Required-Start:    \$local_fs \$remote_fs \$network $syslog
# Required-Stop:     \$local_fs \$remote_fs \$network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the subversion daemon
# Description:       starts subversion using start-stop-daemon
### END INIT INFO
 
# sudo svnserve -d -r /home/pi/repos
# http://www.everville.de/pages/howtos/linux/svnserve/index.html
 
# start/stop subversion daemon
 
#test -f /home/svn || exit 0
 
OPTIONS=\"-d -T -r /home/svnrepos\"
 
case \"\$1\" in
	start)
		echo -n \"Starting subversion :\"
		echo -n \" svnserve\"
		svnserve \$OPTIONS
		echo \".\"
    	;;
 
	stop)
		echo -n \"Stopping subversion :\"
		echo -n \" svnserve\"
		killall svnserve
		echo \".\"
		;;
 
	reload)
		killall svnserve && svnserve \$OPTIONS
		;;
 
	force-reload)
	\$0 restart
		;;
 
	restart)
	\$0 stop
	\$0 start
		;;
 
	*)
		echo \"Usage: /etc/init.d/subversion (start|stop|reload|restart)\"
		exit 1
		;;
 
esac
 
exit 0
"> /etc/init.d/subversion
    chmod +x /etc/init.d/subversion

	#添加到服务列表
	chkconfig --add subversion
	chkconfig --level 2345 subversion on

    /etc/init.d/subversion start
    echo '安装完成，正在启动svn。。。'
}

uninstall_svn()
{
    killall svnserve
	if [ -d "$setup_path" ];then
		rm -rf $setup_path
		yum remove -y subversion subversion-libs
        rm -f /etc/init.d/subversion
        chkconfig --del subversion
        echo 'svn卸载成功...'
	fi
}


if [ "$actionType" == 'install' ];then
	check_svn
    install_svn
elif [ "$actionType" == 'uninstall' ];then
	uninstall_svn
elif [ "$actionType" == 'addStorage' ];then
	if [ ! -z "$2" ];then
		storage_name=$2
	fi
    add_storage
fi

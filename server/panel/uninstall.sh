#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Remove_Bt(){
	if [ ! -f "/etc/init.d/bt" ] || [ ! -d "/www/server/panel" ]; then
		echo -e "此服务器没有安装Linux面板！"
		echo -e "This server does not install bt-panel"
		exit;
	fi
	/etc/init.d/bt stop
	if [ -f "/usr/sbin/chkconfig" ];then
		chkconfig --del bt
	elif [ -f "/usr/sbin/update-rc.d" ];then
		/usr/sbin/update-rc.d
	fi
	rm -rf /www/server/panel
	rm -f /etc/init.d/bt 
	echo -e "Linux面板已卸载成功"
	echo -e "Linux panel uninstall success"
}
Remove_Service(){
	servicePath="/www/server"
	for service in nginx mysqld tomcat redis subversion
	do
		if [ -f "/etc/init.d/${service}" ]; then
			/etc/init.d/${service} stop
			if [ -f "/usr/sbin/chkconfig" ];then
				chkconfig  --del ${service}
			elif [ -f "/usr/sbin/update-rc.d" ];then
				update-rc.d -f ${service} remove
			fi
			if [ "${service}" = "mysqld" ]; then
			 	rm -rf ${servicePath}/mysql
			 	rm -f /etc/my.cnf
			elif [ "${service}" = "nginx" ] || [ "${service}" = "redis" ] || [ "${service}" = "tomcat" ] || [ "${service}" = "pure-ftpd" ] ; then
				rm -rf ${servicePath}/${service}
			fi 
			rm -f /etc/init.d/${service}
			echo -e ${service} "\033[32mclean\033[0m"
		fi
	done
}
Remove_Rpm(){
	echo -e "查询已安装rpm包.."
	echo -e "Find installed packages"
	for lib in libiconv-1.14 libmcrypt-2.5.8 mcrypt-2.6.8 mhash-0.9.9.9 bt-mysql bt-httpd bt-mariadb bt-php-5.2 bt-php-5.3 bt-php-5.4 bt-php-5.5 bt-php-5.6 bt-php-7.0 bt-php-7.1
	do
		rpm -qa |grep ${lib} > ${lib}.pl
		libRpm=`cat ${lib}.pl`
		if [ "${libRpm}" != "" ]; then
			rpm -e ${libRpm} --nodeps > /dev/null 2>&1
			echo -e ${lib} "\033[32mclean\033[0m"
		fi
		rm -f ${lib}.pl
	done
	echo -e "清理完毕"
	echo -e "Clean over"
}

Remove_Data(){
	rm -rf /www/server/data
	rm -rf /www/wwwlogs
	rm -rf /www/wwwroot
}

echo "================================================="  
#echo -e "What you want to do ?(Default:1)"
echo "1) 卸载面板"  
echo "2) 卸载面板及运行环境"
#echo "3) 卸载面板及运行环境并清除所有站点相关数据"
read -p "请选择你要进行的操作(1-2 默认:1): " action;
echo "================================================="  

case $action in
	'1')
		Remove_Bt
		;;
	'2')
		Remove_Service
		if [ -f "/usr/bin/yum" ] & [ -f "/usr/bin/rpm" ]; then
			Remove_Rpm
		fi
		Remove_Bt
		;;
	*)
		Remove_Bt
	;;
esac

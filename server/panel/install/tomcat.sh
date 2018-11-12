#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
country=`curl -sS --connect-timeout 10 -m 60 http://ip.vpser.net/country`
#准备基础数据
Root_Path='/www'
run_path='/root'
Is_64bit=`getconf LONG_BIT`
tomcat7='7.0.76'
tomcat8='8.0.53'
tomcat9='9.0.0.M18'
download_tomcat8='http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v8.0.53/bin/apache-tomcat-8.0.53.tar.gz'

#安装tomcat
Install_Tomcat()
{
	#前置准备
	Uninstall_Tomcat
	Install_JavaJdk
	
	yum install rng-tools -y
	service rngd start
	systemctl start rngd
	
	#下载并安装主程序
	filename=apache-tomcat-8.0.53.tar.gz
	#wget -c -O $filename  $download_Url/install/src/$filename -T 20
	wget -c -O $filename  $download_tomcat8 -T 20
	tar xvf $filename
	mv -f apache-tomcat-$tomcatVersion $Setup_Path
	rm -f $filename
	if [ "$tomcatVersion" == "$tomcat9" ];then
		tomcatVersion="9.0.0";
	fi
	echo "$tomcatVersion" > $Setup_Path/version.pl
	
	#替换默认配置
	sxml=$Setup_Path/conf/server.xml
	#mkdir -p /www/server/panel/vhost/tomcat
	#sed -i "s#webapps#/www/server/panel/vhost/tomcat#" $sxml
	#sed -i "s#TOMCAT_USER=tomcat#TOMCAT_USER=www#" $Setup_Path/bin/daemon.sh
	#chown -R www.www /www/server/panel/vhost/tomcat
	chown -R www.www $Setup_Path
	#\cp -a -r /www/server/tomcat/webapps/* /www/server/panel/vhost/tomcat/
	
	#替换端口
	#sed -i "s/8080/9001/" $sxml
	#sed -i "s/8009/901$version/" $sxml
	#sed -i "s/8005/902$version/" $sxml
	
	#添加到服务
	sed -i "s@bin/sh@bin/bash\n# chkconfig: 2345 55 25\n# description: tomcat$version\n### BEGIN INIT INFO\n# Provides:          tomcat$version\n# Required-Start:    \$all\n# Required-Stop:     \$all\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: starts tomcat$version\n# Description:       starts the tomcat$version\n\n### END INIT INFO\n\nJAVA_HOME=$jdk_path\nCATALINA_HOME=/www/server/tomcat@" $Setup_Path/bin/catalina.sh
	\cp -r -a $Setup_Path/bin/catalina.sh /etc/init.d/tomcat
	chmod +x /etc/init.d/tomcat
	chkconfig --add tomcat
	chkconfig --level 2345 tomcat on
	/etc/init.d/tomcat start
}

#安装java-jdk
Install_JavaJdk()
{
	download_jdk=http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm
	if [ ! -d "$jdk_path" ];then
		wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -c -O java-jdk.rpm $download_jdk -T 20
		rpm -ivh java-jdk.rpm --force --nodeps
		rm -f java-jdk.rpm
	fi
}
Install_Jsvs(){
	cd /www/server/tomcat/bin
	tar -zxf commons-daemon-native.tar.gz
	cd commons-daemon-1.1.0-native-src/unix
	./configure --with-java=$jdk_path
	make
	\cp jsvc /www/server/tomcat/bin
	sed -i "s@# JAVA_HOME=\/opt\/jdk-1.6.0.22@JAVA_HOME=$jdk_path@" /www/server/tomcat/bin/daemon.sh
	if [ -f "/etc/init.d/tomcat" ]; then
		rm -f /etc/init.d/tomcat
	fi
cat >>/etc/init.d/tomcat<<EOF
#!/bin/bash
# chkconfig: 2345 55 25
# description: tomcat Service

### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts tomcat
# Description:       starts the tomcat
### END INIT INFO
path=/www/server/tomcat/bin
cd \$path
bash daemon.sh \$1
EOF
	chmod +x /etc/init.d/tomcat
	chkconfig --add tomcat
	chkconfig --level 2345 tomcat on
	groupadd www
    useradd -r -s /sbinlogin -g www tomcat
    chown -R tomcat:www /www/server/tomcat
	/etc/init.d/tomcat start
}

#卸载tomcat
Uninstall_Tomcat()
{
	if [ -d "$Setup_Path" ];then
		$Setup_Path/bin/daemon.sh stop
		rm -rf $Setup_Path
	fi
	sed -i '/jenkins/d' /etc/profile
	if [ -f "/etc/init.d/tomcat" ];then
		chkconfig --del tomcat
		rm -f /etc/init.d/tomcat
		rm -f /etc/rc.d/init.d/tomcat
	fi
}

actionType=$1
#version=$2
Setup_Path=$Root_Path/server/tomcat
if [ "$actionType" == 'install' ];then
	tomcatVersion=$tomcat8
	jdk='8u181'
	jdk_path='/usr/java/jdk1.8.0_181-amd64'
	Install_Tomcat
	Install_Jsvs
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_Tomcat
fi

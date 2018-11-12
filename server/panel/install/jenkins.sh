#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#准备基础数据
Root_Path='/www'
Is_64bit=`getconf LONG_BIT`
download_url='https://mirrors.tuna.tsinghua.edu.cn/jenkins/war-stable/2.138.1/jenkins.war'
actionType=$1
Setup_Path=$Root_Path/server/tomcat

check_tomcat()
{
	if [ ! -d "${Setup_Path}" ];then
		if [ ! -f "${Root_Path}/server/panel/install/tomcat.sh" ];then
			echo '缺少tomcat安装文件'
			exit
		fi
        echo '准备安装tomcat配置。。。'
		bash ${Root_Path}/server/panel/install/tomcat.sh
        echo 'config tomcat success...'
	fi
}

check_jenkins()
{
    echo 'check local jenkins...'
	if [ ! -d "${Setup_Path}/webapps" ];then
		echo 'tomcat异常。。。'
		exit
	fi
	uninstall_jenkins
}

install_jenkins()
{
    echo '准备安装jenkins。。。'
    /etc/init.d/tomcat stop
	cd ${Setup_Path}/webapps/
	wget -c $download_url -T 20
    sed -i '$aexport JENKINS_HOME='"${Setup_Path}"'/webapps/jenkins/.jenkins' /etc/profile
	source /etc/profile
    echo 'install jenkins success...'
    /etc/init.d/tomcat start
}

uninstall_jenkins()
{
	if [ -d "${Setup_Path}/webapps/jenkins" ];then
        echo 'prepare uninstall jenkins....'
		rm -rf ${Setup_Path}/webapps/jenkins
        if [ -f "${Setup_Path}/webapps/jenkins.war" ];then
            rm -f ${Setup_Path}/webapps/jenkins.war
        fi
		sed -i '/jenkins/d' /etc/profile
        echo 'uninstall jenkins success...'
	fi
}


if [ "$actionType" == 'install' ];then
	#检查是否已经安装tomcat
	check_tomcat
	#检查是否已经安装jenkins
	check_jenkins
	install_jenkins
elif [ "$actionType" == 'uninstall' ];then
	uninstall_jenkins
fi

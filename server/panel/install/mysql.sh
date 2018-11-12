#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# public_file=/www/server/panel/install/public.sh
# if [ ! -f $public_file ];then
# 	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
# fi
# . $public_file

# download_Url=$NODE_URL

#Root_Path=`cat /var/bt_setupPath.conf`
# Setup_Path=$Root_Path/server/mysql
# Data_Path=$Root_Path/server/data
Setup_Path=/usr/local/mysql
Data_Path=/usr/local/mysql/data
#查询系统位数
Is_64bit=`getconf LONG_BIT`
run_path='/root'
mysql_57='5.7.23'
mysql_80='8.0.12'

#检测hosts文件
hostfile=`cat /etc/hosts | grep 127.0.0.1 | grep localhost`
if [ "${hostfile}" = '' ]; then
	echo "127.0.0.1  localhost  localhost.localdomain" >> /etc/hosts
fi

cpuInfo=$(getconf _NPROCESSORS_ONLN)
if [ "${cpuInfo}" -ge "4" ];then
	cpuCore=$((${cpuInfo}/2))
else
	cpuCore="1"
fi

#删除软链
DelLink()
{	
	rm -f /usr/bin/mysql*
	# rm -f /usr/lib/libmysql*
	# rm -f /usr/lib64/libmysql*
}
#设置软件链
SetLink()
{
    ln -sf ${Setup_Path}/bin/mysql /usr/bin/mysql
    ln -sf ${Setup_Path}/bin/mysqldump /usr/bin/mysqldump
    ln -sf ${Setup_Path}/bin/myisamchk /usr/bin/myisamchk
    ln -sf ${Setup_Path}/bin/mysqld_safe /usr/bin/mysqld_safe
    ln -sf ${Setup_Path}/bin/mysqlcheck /usr/bin/mysqlcheck
	ln -sf ${Setup_Path}/bin/mysql_config /usr/bin/mysql_config
	
	# rm -f /usr/lib/libmysqlclient.so.16
	# rm -f /usr/lib64/libmysqlclient.so.16
	# rm -f /usr/lib/libmysqlclient.so.18
	# rm -f /usr/lib64/libmysqlclient.so.18
	# rm -f /usr/lib/libmysqlclient.so.20
	# rm -f /usr/lib64/libmysqlclient.so.20
	# rm -f /usr/lib/libmysqlclient.so.21
	# rm -f /usr/lib64/libmysqlclient.so.21
	
	# if [ -f "${Setup_Path}/lib/libmysqlclient.so.18" ];then
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.20
	# elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient.so.18" ];then
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.20
	# elif [ -f "${Setup_Path}/lib/libmysqlclient.so.16" ];then
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.20
	# elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient.so.16" ];then
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.20
	# elif [ -f "${Setup_Path}/lib/libmysqlclient_r.so.16" ];then
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient_r.so.16 /usr/lib/libmysqlclient_r.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient_r.so.16 /usr/lib64/libmysqlclient_r.so.16
	# elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient_r.so.16" ];then
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient_r.so.16 /usr/lib/libmysqlclient_r.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient_r.so.16 /usr/lib64/libmysqlclient_r.so.16
	# elif [ -f "${Setup_Path}/lib/libmysqlclient.so.20" ];then
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.20
	# elif [ -f "${Setup_Path}/lib/libmysqlclient.so.21" ];then
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.21
	# 	ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.21
	# elif [ -f "${Setup_Path}/lib/libmariadb.so.3" ]; then
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.21
	# 	ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.21
	# elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient.so.20" ];then
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.16
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.18
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.20
	# 	ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.20
	# fi
}

Install_MySQL_57()
{
	Close_MySQL
	cd ${run_path}
	#准备安装
	Setup_Path="/usr/local/mysql"
	Data_Path="/usr/local/mysql/data"

	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz  https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mysql-${mysql_57}-linux-glibc2.12-x86_64/* ${Setup_Path}

    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql

    cat > /etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = ${Data_Path}
skip-external-locking
performance_schema_max_table_instances=400
table_definition_cache=400
key_buffer_size = 16M
max_allowed_packet = 100G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on
early-plugin-load = ""

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

    MySQL_Opt
    if [ -d "${Data_Path}" ]; then
        rm -rf ${Data_Path}/*
    else
        mkdir -p ${Data_Path}
    fi
    chown -R mysql:mysql ${Data_Path}
    ${Setup_Path}/bin/mysqld --initialize-insecure --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
    chgrp -R mysql ${Setup_Path}/.
    \cp support-files/mysql.server /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
    sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    ${Setup_Path}/lib
    /usr/local/lib
EOF


	#启动服务
    ldconfig
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	# /etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig
	
	#添加到服务列表
	chkconfig --add mysqld
	chkconfig --level 2345 mysqld on
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf mysql-${mysql_57}-linux-glibc2.12-x86_64
	echo "${mysql_57}" > ${Setup_Path}/version.pl
	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: mysql-5.7 installation failed.\033[0m";
		rm -rf ${Setup_Path}
		exit 0;
	fi
}
# Install_MySQL_80(){
# 	Close_MySQL
# 	cd ${run_path}
# 	#准备安装
# 	Setup_Path="/www/server/mysql"
# 	Data_Path="/www/server/data"

# 	mkdir -p ${Setup_Path}
# 	rm -rf ${Setup_Path}/*
# 	cd ${Setup_Path}
# 	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
# 		wget -O ${Setup_Path}/src.tar.gz  https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.12-linux-glibc2.12-x86_64.tar.xz -T20
# 	fi
# 	tar -zxvf src.tar.gz
# 	mv mysql-${mysql_80}-linux-glibc2.12-x86_64 src
# 	cd src 

# 	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DENABLED_LOCAL_INFILE=1 -DWITH_BOOST=boost
# 	make -j${cpuCore}
# 	make install

# 	groupadd mysql
# 	useradd -s /sbin/nologin -M -g mysql mysql
# 	cat > /etc/my.cnf<<EOF
# [client]
# #password   = your_password
# port        = 3306
# socket      = /tmp/mysql.sock

# [mysqld]
# port        = 3306
# socket      = /tmp/mysql.sock
# datadir = ${Data_Path}
# skip-external-locking
# performance_schema_max_table_instances=400
# table_definition_cache=400
# key_buffer_size = 16M
# max_allowed_packet = 1G
# table_open_cache = 64
# sort_buffer_size = 512K
# net_buffer_length = 8K
# read_buffer_size = 256K
# read_rnd_buffer_size = 512K
# myisam_sort_buffer_size = 8M
# thread_cache_size = 8
# tmp_table_size = 16M
# sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
# default_authentication_plugin=mysql_native_password

# explicit_defaults_for_timestamp = true
# #skip-networking
# max_connections = 500
# max_connect_errors = 100
# open_files_limit = 65535

# log-bin=mysql-bin
# binlog_format=mixed
# server-id   = 1
# binlog_expire_logs_seconds = 600000
# slow_query_log=1
# slow-query-log-file=${Data_Path}/mysql-slow.log
# long_query_time=3
# #log_queries_not_using_indexes=on
# early-plugin-load = ""

# #loose-innodb-trx=0
# #loose-innodb-locks=0
# #loose-innodb-lock-waits=0
# #loose-innodb-cmp=0
# #loose-innodb-cmp-per-index=0
# #loose-innodb-cmp-per-index-reset=0
# #loose-innodb-cmp-reset=0
# #loose-innodb-cmpmem=0
# #loose-innodb-cmpmem-reset=0
# #loose-innodb-buffer-page=0
# #loose-innodb-buffer-page-lru=0
# #loose-innodb-buffer-pool-stats=0
# #loose-innodb-metrics=0
# #loose-innodb-ft-default-stopword=0
# #loose-innodb-ft-inserted=0
# #loose-innodb-ft-deleted=0
# #loose-innodb-ft-being-deleted=0
# #loose-innodb-ft-config=0
# #loose-innodb-ft-index-cache=0
# #loose-innodb-ft-index-table=0
# #loose-innodb-sys-tables=0
# #loose-innodb-sys-tablestats=0
# #loose-innodb-sys-indexes=0
# #loose-innodb-sys-columns=0
# #loose-innodb-sys-fields=0
# #loose-innodb-sys-foreign=0
# #loose-innodb-sys-foreign-cols=0

# default_storage_engine = InnoDB
# innodb_data_home_dir = ${Data_Path}
# innodb_data_file_path = ibdata1:10M:autoextend
# innodb_log_group_home_dir = ${Data_Path}
# innodb_buffer_pool_size = 16M
# innodb_log_file_size = 5M
# innodb_log_buffer_size = 8M
# innodb_flush_log_at_trx_commit = 1
# innodb_lock_wait_timeout = 120
# innodb_max_dirty_pages_pct = 90
# innodb_read_io_threads = 4
# innodb_write_io_threads = 4

# [mysqldump]
# quick
# max_allowed_packet = 16M

# [mysql]
# no-auto-rehash

# [myisamchk]
# key_buffer_size = 20M
# sort_buffer_size = 20M
# read_buffer = 2M
# write_buffer = 2M

# [mysqlhotcopy]
# interactive-timeout
# EOF
#     MySQL_Opt
#     if [ -d "${Data_Path}" ]; then
#         rm -rf ${Data_Path}/*
#     else
#         mkdir -p ${Data_Path}
#     fi
#     chown -R mysql:mysql ${Data_Path}
#     ${Setup_Path}/bin/mysqld --initialize-insecure --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
#     chgrp -R mysql ${Setup_Path}/.
#     \cp support-files/mysql.server /etc/init.d/mysqld
#     chmod 755 /etc/init.d/mysqld
#     sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
#     cat > /etc/ld.so.conf.d/mysql.conf<<EOF
# ${Setup_Path}/lib
# /usr/local/lib
# EOF

# 	#启动服务
#     ldconfig
#     ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
#     ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
# 	/etc/init.d/mysqld start
	
# 	#设置软链
#     SetLink
# 	ldconfig
	
# 	#设置密码
#     ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
		
# 	#添加到服务列表
# 	chkconfig --add mysqld
# 	chkconfig --level 2345 mysqld on
	
# 	cd ${Setup_Path}
# 	rm -f src.tar.gz
# 	rm -rf src
# 	echo "${mysql_80}" > ${Setup_Path}/version.pl
# 	echo "True" > ${Setup_Path}/mysqlDb3.pl
# 	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
# 		echo '========================================================'
# 		echo -e "\033[31mERROR: mysql-8.0 installation failed.\033[0m";
# 		rm -rf ${Setup_Path}
# 		exit 0;
# 	fi
# }

# Update_MySQL_57(){
# 	cd ${run_path}
# 	wget ${download_Url}/src/boost_1_59_0.tar.gz -T20
# 	tar -zxvf boost_1_59_0.tar.gz
# 	cd boost_1_59_0
	
#     ./bootstrap.sh
#     ./b2
#     ./b2 install
	
# 	cd ..
#     rm -rf boost_1_59_0
# 	rm -f boost_1_59_0.tar.gz
# 	mkdir -p ${Setup_Path}/update
# 	rm -rf ${Setup_Path}/update/*
# 	cd ${Setup_Path}/update
# 	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mysql-$mysql_57.tar.gz -T20
# 	tar -zxvf src.tar.gz
# 	mv mysql-$mysql_57 src
# 	cd src
# 	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
# 	make -j${cpuCore}
# 	/etc/init.d/mysqld stop
# 	sleep 2
# 	make install
# 	sleep 2
# 	/etc/init.d/mysqld start
# 	echo "${mysql_57}" > ${Setup_Path}/version.pl
# }
#配置系统参数
MySQL_Opt()
{
	cpuInfo=`cat /proc/cpuinfo |grep "processor"|wc -l`
	sed -i 's/innodb_write_io_threads = 4/innodb_write_io_threads = '${cpuInfo}'/g' /etc/my.cnf
	sed -i 's/innodb_read_io_threads = 4/innodb_read_io_threads = '${cpuInfo}'/g' /etc/my.cnf
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -lt 2048 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 32M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 128#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 768K#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 768K#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 16#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 16M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 32M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 16M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 2048 && ${MemTotal} -lt 4096 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 64M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 256#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 1M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 1M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 32#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 32M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 32M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 4096 && ${MemTotal} -lt 8192 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 128M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 512#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 2M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 2M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 32M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 64#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 64M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 64M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 8192 && ${MemTotal} -lt 16384 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 256M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 1024#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 4M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 4M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 64M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 128#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 128M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 1024M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 128M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 16384 && ${MemTotal} -lt 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 512M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 2048#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 128M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 256#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 256M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 2048M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 256M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 1024M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 4096#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 256M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 512#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 512M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 4096M#" /etc/my.cnf
        if [ "${version}" == "5.5" ];then
        	sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" /etc/my.cnf
        	sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 256M#" /etc/my.cnf
        else
        	sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 2048M#" /etc/my.cnf
        	sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 512M#" /etc/my.cnf
        fi
    fi
}

# Install_mysqldb()
# {
# 	wget -O MySQL-python-1.2.5.zip ${download_Url}/install/src/MySQL-python-1.2.5.zip -T 10
# 	unzip MySQL-python-1.2.5.zip
# 	rm -f MySQL-python-1.2.5.zip
# 	cd MySQL-python-1.2.5
# 	python setup.py install
# 	cd ..
# 	rm -rf MySQL-python-1.2.5
# }
# Install_mysqldb3()
# {
# 	wget -O mysqlclient-1.3.12.zip ${download_Url}/install/src/mysqlclient-1.3.12.zip -T 10
# 	unzip mysqlclient-1.3.12.zip
# 	rm -f mysqlclient-1.3.12.zip
# 	cd mysqlclient-1.3.12
# 	python setup.py install
# 	cd ..
# 	rm -rf mysqlclient-1.3.12
# }
#python3.*选择pymysql模块进行安装
Install_mysqldb()
{
	pip install pymysql
}


Close_MySQL()
{
	systemctl mysqld stop
	if [ "$1" == 'del' ];then
		rm -rf $Setup_Path
	fi
	
	# if [ -d "${Data_Path}" ];then
	# 	mkdir -p $Root_Path/backup
	# 	mv $Data_Path  $Root_Path/backup/oldData
	# 	rm -rf $Data_Path
	# fi
	
	chkconfig --del mysqld
	rm -rf /etc/init.d/mysqld
	DelLink
}

actionType=$1
#version=$2

if [ "$actionType" == 'install' ];then
	mysqlpwd=`cat /dev/urandom | head -n 16 | md5sum | head -c 16`
    Install_MySQL_57
	# systemctl mysqld start
	cd /www/server/panel
	#设置mysql密码
	python tools.py root $mysqlpwd
	
elif [ "$actionType" == 'uninstall' ];then
	Close_MySQL del
fi


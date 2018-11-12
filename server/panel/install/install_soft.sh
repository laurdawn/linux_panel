#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
name=$1
actionType=$2
param=$3

#从bt官网爬取所有需要的sh脚本后删除
#. /www/server/panel/install/public.sh
#serverUrl=$NODE_URL/install
#wget -O $name.sh $serverUrl/$mtype/$name.sh

# if [ ! -f 'lib.sh' ];then
# 	wget -O lib.sh $serverUrl/$mtype/lib.sh
# fi

# if [ "$actionType" == 'install' ];then
# 	bash lib.sh
# fi
bash $name.sh $actionType $param

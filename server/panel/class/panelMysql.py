#coding: utf-8
# +-------------------------------------------------------------------
# | 宝塔Linux面板
# +-------------------------------------------------------------------
# | Copyright (c) 2015-2016 宝塔软件(http://bt.cn) All rights reserved.
# +-------------------------------------------------------------------
# | Author: 黄文良 <287962566@qq.com>
# +-------------------------------------------------------------------

import re,os

class panelMysql:
    __DB_PASS = None
    __DB_USER = 'root'
    __DB_PORT = 3306
    __DB_HOST = 'localhost'
    __DB_CONN = None
    __DB_CUR  = None
    __DB_ERR  = None
    #连接MYSQL数据库
    def __Conn(self):
        try:
            import public
            socket = '/tmp/mysql.sock';
            try:
                import pymysql
            except Exception as ex:
                self.__DB_ERR = ex
                return False;
            try:
                myconf = public.readFile('/etc/my.cnf');
                rep = "port\s*=\s*([0-9]+)"
                self.__DB_PORT = int(re.search(rep,myconf).groups()[0]);
            except:
                self.__DB_PORT = 3306;
            self.__DB_PASS = public.M('config').where('id=?',(1,)).getField('mysql_root');
            
            try:
                self.__DB_CONN = pymysql.connect(host = self.__DB_HOST,port = self.__DB_PORT, user = self.__DB_USER,passwd = self.__DB_PASS,charset="utf8",connect_timeout=1,unix_socket=socket)
            except pymysql.Error as e:
                self.__DB_HOST = '127.0.0.1';
                self.__DB_CONN = pymysql.connect(host = self.__DB_HOST,port = self.__DB_PORT, user = self.__DB_USER,passwd = self.__DB_PASS,charset="utf8",connect_timeout=1,unix_socket=socket)
            self.__DB_CUR  = self.__DB_CONN.cursor()
            return True
        except pymysql.Error as e:
            self.__DB_ERR = e
            return False
          
    def execute(self,sql):
        #执行SQL语句返回受影响行
        if not self.__Conn(): return self.__DB_ERR
        try:
            result = self.__DB_CUR.execute(sql)
            self.__DB_CONN.commit()
            self.__Close()
            return result
        except Exception as ex:
            return ex
    
    
    def query(self,sql):
        #执行SQL语句返回数据集
        if not self.__Conn(): return self.__DB_ERR
        try:
            self.__DB_CUR.execute(sql)
            result = self.__DB_CUR.fetchall()
            #将元组转换成列表
            data = map(list,result)
            self.__Close()
            return data
        except Exception as ex:
            return ex
        
     
    #关闭连接        
    def __Close(self):
        self.__DB_CUR.close()
        self.__DB_CONN.close()

#coding: utf-8
# +-------------------------------------------------------------------
# | 宝塔Linux面板
# +-------------------------------------------------------------------
# | Copyright (c) 2015-2017 宝塔软件(http://bt.cn) All rights reserved.
# +-------------------------------------------------------------------
# | Author: 黄文良 <287962566@qq.com>
# +-------------------------------------------------------------------
import public,web,os,sys,json,time,psutil
from imp import reload
class mget: pass;
class panelPlugin:
    __isTable = None;
    __install_path = None;
    __tasks = None;
    __list = 'data/list.json'
    __type = 'data/type.json'
    __product_list = None
    __plugin_list = None
    pids = None
    ROWS = 15;
    
    def __init__(self):
        self.__install_path = '/www/server/panel/plugin'
        #if not os.path.exists(self.__list): self.getCloudPlugin(None);
    
    #取列表
    def GetList(self,get = None):
        try:
            if not os.path.exists(self.__list): return [];
            data = json.loads(public.readFile(self.__list));
            #排序
            data = sorted(data, key= lambda b:b['sort'],reverse=False);
            #索引列表
            if get:
                display = None
                if hasattr(get,'display'): display = True;
                if not hasattr(get,'type'): 
                    get.type = 0;
                else:
                    get.type = int(get.type)
                if not hasattr(get,'search'): 
                    search = None
                    m = 0
                else:
                    search = get.search.lower();
                    m = 1
                tmp = [];
                for d in data:
                    self.get_icon(d['name']);
                    if display:
                        if d['display'] == 0: continue;
                    i=0;
                    if get.type > 0:
                        if get.type == d['id']: i+=1
                    else:
                        i+=1
                    if search:
                        if d['name'].lower().find(search.lower()) != -1: i+=1;
                        if d['title'].lower().find(search.lower()) != -1: i+=1;
                        if get.type > 0 and get.type != d['type']: i -= 1;
                    if i>m:tmp.append(d);
                data = tmp;
            return data
        except:
            return [];
        
    
    #获取图标
    def get_icon(self,name):
        iconFile = '/www/server/panel/static/img/soft_ico/ico-' + name + '.png'
        if not os.path.exists(iconFile):
            self.download_icon(name,iconFile)
        else:
            size = os.path.getsize(iconFile)
            if size == 0: self.download_icon(name,iconFile)
        
    #下载图标
    def download_icon(self,name,iconFile):
        srcIcon = self.__install_path + '/' + name + '/icon.png';
        public.ExecShell('wget -O ' + iconFile + ' ' + public.get_url() + '/install/lib/plugin/' + name + '/icon.png &');
                
    
    #取分页
    def GetPage(self,data,get):
        #包含分页类
        import page
        #实例化分页类
        page = page.Page();
        info = {}
        info['count'] = len(data)
        info['row']   = self.ROWS;
        info['p'] = 1
        if hasattr(get,'p'):
            info['p']     = int(get['p'])
        info['uri']   = {}
        info['return_js'] = ''
        if hasattr(get,'tojs'):
            info['return_js']   = get.tojs
        
        #获取分页数据
        result = {}
        result['page'] = page.GetPage(info)
        n = 0;
        result['data'] = [];
        for i in range(info['count']):
            if n > page.ROW: break;
            if i < page.SHIFT: continue;
            n += 1;
            result['data'].append(data[i]);
        return result;
    
    #取分类
    def GetType(self,get = None):
        try:
            if not os.path.exists(self.__type): return False;
            data = json.loads(public.readFile(self.__type));
            return data
        except:
            return False;
        
    #取单个
    def GetFind(self,name):
        try:
            data = self.GetList(None);
            for d in data:
                if d['name'] == name: return d;
            return None
        except:
            return None;
    
    #设置
    def SetField(self,name,key,value):
        data = self.GetList(None);
        for i in range(len(data)):
            if data[i]['name'] != name: continue;
            data[i][key] = value;
        
        public.writeFile(self.__list,json.dumps(data));
        return True;
    
    
    
    #安装插件
    def install(self,get):
        pluginInfo = self.GetFind(get.name);
        if not pluginInfo:
            import json
            pluginInfo = json.loads(public.readFile(self.__install_path + '/' + get.name + '/info.json'));
        
        if pluginInfo['tip'] == 'lib':
            if not os.path.exists(self.__install_path + '/' + pluginInfo['name']): os.system('mkdir -p ' + self.__install_path + '/' + pluginInfo['name']);
            if not hasattr(web.ctx.session,'downloadUrl'): web.ctx.session.downloadUrl = 'http://download.bt.cn';
            downloadUrl = web.ctx.session.downloadUrl + '/install/lib/plugin/' + pluginInfo['name'] + '/install.sh';
            toFile = self.__install_path + '/' + pluginInfo['name'] + '/install.sh';
            public.downloadFile(downloadUrl,toFile);
            os.system('/bin/bash ' + toFile + ' install');
            if self.checksSetup(pluginInfo['name'],pluginInfo['checks'],pluginInfo['versions'])[0]['status'] or os.path.exists(self.__install_path + '/' + get.name):
                public.WriteLog('TYPE_SETUP','PLUGIN_INSTALL_LIB',(pluginInfo['title'],));
                #os.system('rm -f ' + toFile);
                return public.returnMsg(True,'PLUGIN_INSTALL_SUCCESS');
            return public.returnMsg(False,'PLUGIN_INSTALL_ERR');
        else:
            import db,time
            issue = public.readFile('/etc/issue')
            if web.ctx.session.server_os['x'] != 'RHEL': get.type = '3'
            
            # apacheVersion='false';
            # if public.get_webserver() == 'apache':
            #     apacheVersion = public.readFile('/www/server/apache/version.pl');
            # public.writeFile('/var/bt_apacheVersion.pl',apacheVersion)
            # public.writeFile('/var/bt_setupPath.conf',web.ctx.session.rootPath)
            isTask = '/tmp/panelTask.pl'

            actionType = 'install';
            mmsg = '安装';
            if hasattr(get, 'actionType'):
                if get.actionType:
                    actionType = get.actionType;
                    mmsg = '添加仓库';
            if hasattr(get, 'param'):
                if get.param:
                    actionType += ' ' + get.param
            execstr = "cd /www/server/panel/install && /bin/bash install_soft.sh " + get.name + " " + actionType;
            sql = db.Sql()
            if hasattr(get,'id'):
                id = get.id;
            else:
                id = None;
            sql.table('tasks').add('id,name,type,status,addtime,execstr',(None, mmsg + '['+get.name+'-'+get.version+']','execshell','0',time.strftime('%Y-%m-%d %H:%M:%S'),execstr))
            public.writeFile(isTask,'True')
            public.WriteLog('TYPE_SETUP','PLUGIN_ADD',(get.name,get.version));
            return public.returnMsg(True,'PLUGIN_INSTALL');
        
        
    #卸载插件
    def unInstall(self,get):
        pluginInfo = self.GetFind(get.name);
        if not pluginInfo:
            import json
            pluginInfo = json.loads(public.readFile(self.__install_path + '/' + get.name + '/info.json'));
        
        if pluginInfo['tip'] == 'lib':
            if not os.path.exists(self.__install_path+ '/' + pluginInfo['name']): os.system('mkdir -p ' + self.__install_path + '/' + pluginInfo['name']);
            downloadUrl = web.ctx.session.downloadUrl + '/install/lib/plugin/' + pluginInfo['name'] + '/install.sh';
            toFile = self.__install_path + '/' + pluginInfo['name'] + '/uninstall.sh';
            public.downloadFile(downloadUrl,toFile)
            os.system('/bin/bash ' + toFile + ' uninstall')
            os.system('rm -rf ' + web.ctx.session.downloadUrl + '/install/lib/plugin/' + pluginInfo['name'])
            pluginPath = self.__install_path + '/' + pluginInfo['name']
            
            if os.path.exists(pluginPath + '/install.sh'):
                os.system('/bin/bash ' + pluginPath + '/install.sh uninstall');
                
            if os.path.exists(pluginPath):
                public.ExecShell('rm -rf ' + pluginPath);
                
            public.WriteLog('TYPE_SETUP','PLUGIN_UNINSTALL_SOFT',(pluginInfo['title'],));
            return public.returnMsg(True,'PLUGIN_UNINSTALL');
        else:
            get.type = '0'
            issue = public.readFile('/etc/issue')
            if web.ctx.session.server_os['x'] != 'RHEL': get.type = '3'
            public.writeFile('/var/bt_setupPath.conf',web.ctx.session.rootPath)
            execstr = "cd /www/server/panel/install && /bin/bash install_soft.sh " + get.name.lower() + " uninstall ";
            os.system(execstr);
            public.WriteLog('TYPE_SETUP','PLUGIN_UNINSTALL',(get.name,get.version));
            return public.returnMsg(True,"PLUGIN_UNINSTALL");
    
    #取插件列表
    def getPluginList(self,get):
        import json
        arr = self.GetList(get);
        result = {}
        if not arr: 
            result['data'] = arr;
            result['type'] = self.GetType(None);
            return result;
        apacheVersion = ""
        try:
            apavFile = '/www/server/apache/version.pl';
            if os.path.exists(apavFile):
                apacheVersion = public.readFile(apavFile).strip();
        except:
            pass;
        
        result = self.GetPage(arr,get);
        arr = result['data'];
        for i in range(len(arr)):
            '''
            arr[i]['end'] = '--';
            if 'price' in arr[i]:
                if arr[i]['price'] > 0:
                    arr[i]['end'] = self.getEndDate(arr[i]['title']);
                    if os.path.exists('plugin/beta/config.conf'):
                        if os.path.exists('/www/server/panel/plugin/' + arr[i]['name'] + '/' + arr[i]['name'] + '_main.py') and arr[i]['end'] == '未开通': arr[i]['end'] = '--';
            '''
            arr[i]['versions'] = self.checksSetup(arr[i]['name'].replace('_soft',''),arr[i]['checks'],arr[i]['versions'])
            
            try:
                arr[i]['update'] = arr[i]['update'].split(',');
            except:
                arr[i]['update'] = [];
            
            #是否强制使用插件模板 LIB_TEMPLATE
            if os.path.exists(self.__install_path+'/'+arr[i]['name']): arr[i]['tip'] = 'lib';
            
            if arr[i]['tip'] == 'lib': 
                arr[i]['path'] = self.__install_path + '/' + arr[i]['name'].replace('_soft','');
                arr[i]['config'] = os.path.exists(arr[i]['path'] + '/index.html');
            else:
                arr[i]['path'] = '/www/server/' + arr[i]['name'].replace('_soft','');
        arr.append(public.M('tasks').where("status!=?",('1',)).count());
        
        
        result['data'] = arr;
        result['type'] = self.GetType(None);
        return result;
    
    #保存插件排序
    def savePluginSort(self,get):
        ssort = get.ssort.split('|');
        data = self.GetList(None)
        l = len(data);
        for i in range(len(ssort)):
            if int(ssort[i]) > 1000: continue;
            for n in range(l):
                if data[n]['pid'] == int(ssort[i]): data[n]['sort'] = i;
        public.writeFile(self.__list,json.dumps(data));
        return public.returnMsg(True,'PLUGIN_SORT');
    
    #检查是否安装
    def checksSetup(self,name,checks,vers = ''):
        tmp = checks.split(',');
        versions = [];
        path = '/www/server/' + name + '/version.pl';
        if name == 'mysql':
            path = '/usr/local/mysql/version.pl'
        elif name == 'jenkins':
            path = '/www/server/tomcat/webapps/jenkins/version.pl'
        elif name == 'subversion':
            path = '/home/svnrepos/version.pl'
        v1 = '';            
        if os.path.exists(path): v1 = public.readFile(path).strip()
        # if name == 'nginx': v1 = v1.replace('1.10', '1.12');
        if not self.__tasks:
            self.__tasks = public.M('tasks').where("status!=?",('1',)).field('status,name').select()
        isStatus = 0;
        versArr = vers.split(',');
        for v in versArr:
            version = {}
            
            v2 = v;
            status = False;
            for tm in tmp:
                if os.path.exists(tm) and isStatus == 0:
                    if len(versArr) > 1:
                        im = v1.find(v)
                        if im != -1 and im < 3:
                            status = True
                            isStatus += 1;
                    else:
                        status = True
                        isStatus += 1;
            #处理任务标记
            isTask = '1';
            for task in self.__tasks:
                tmpt = public.getStrBetween('[',']',task['name'])
                if not tmpt:continue;
                tmp1 = tmpt.split('-');
                name1 = tmp1[0].lower();
                if name1 == 'pure': name1 = 'pure-ftpd';
                if name1 == name: isTask = task['status']; 
            
            infoFile = 'plugin/' + name + '/info.json'
            if os.path.exists(infoFile):
                try:
                    tmps = json.loads(public.readFile(infoFile));
                    if tmps: v1 = tmps['versions'];
                except:pass;
            
            # if name == 'memcached':
            #     if os.path.exists('/etc/init.d/memcached'):
            #         v1 = getattr(web.ctx.session,'memcachedv',False)
            #         if not v1:
            #             v1 = public.ExecShell("memcached -V|awk '{print $2}'")[0].strip();
            #             web.ctx.session.memcachedv = v1
            # if name == 'apache':
            #     if os.path.exists('/www/server/apache/bin/httpd'): 
            #         v1 = getattr(web.ctx.session,'httpdv',False)
            #         if not v1:
            #             v1 = public.ExecShell("/www/server/apache/bin/httpd -v|grep Apache|awk '{print $3}'|sed 's/Apache\///'")[0].strip();
            #             web.ctx.session.httpdv = v1;
            #if name == 'mysql':
            #    if os.path.exists('/www/server/mysql/bin/mysql'): v1 = public.ExecShell("mysql -V|awk '{print $5}'|sed 's/,//'")[0].strip();

            version['status'] = status
            version['version'] = v;
            version['task'] = isTask;
            version['no'] = v1
            versions.append(version);
        return self.checkRun(name,versions);
        
    #检查是否启动
    def checkRun(self,name,versions):
        # if name == 'nginx':
        #     status = False
        #     if os.path.exists('/etc/init.d/nginx'):
        #         pidf = '/www/server/nginx/logs/nginx.pid';
        #         if os.path.exists(pidf):
        #             try:
        #                 pid = public.readFile(pidf)
        #                 pname = self.checkProcess(pid);
        #                 if pname: status = True;
        #             except:
        #                 status = False
        #     for i in range(len(versions)):
        #         versions[i]['run'] = False
        #         if versions[i]['status']: versions[i]['run'] = status
        # elif name == 'apache':
        #     status = False
        #     if os.path.exists('/etc/init.d/httpd'):
        #         pidf = '/www/server/apache/logs/httpd.pid';
        #         if os.path.exists(pidf):
        #             pid = public.readFile(pidf)
        #             status = self.checkProcess(pid);
        #     for i in range(len(versions)):
        #         versions[i]['run'] = False
        #         if versions[i]['status']: versions[i]['run'] = status
        if name == 'mysql':
            status = os.path.exists('/tmp/mysql.sock')
            for i in range(len(versions)):
                versions[i]['run'] = False
                if versions[i]['status']: versions[i]['run'] = status
        elif name == 'tomcat':
            status = False
            if os.path.exists('/www/server/tomcat/logs/catalina-daemon.pid'):
                if self.getPid('jsvc'): status = True
            #if not status:
                #if self.getPid('java'): status = True
            for i in range(len(versions)):
                versions[i]['run'] = False
                if versions[i]['status']: versions[i]['run'] = status
        # elif name == 'pure-ftpd':
        #      for i in range(len(versions)):
        #         pidf = '/var/run/pure-ftpd.pid'
        #         if os.path.exists(pidf):
        #             pid = public.readFile(pidf)
        #             versions[i]['run'] = self.checkProcess(pid)
        #             if not versions[i]['run']: os.system('rm -f ' + pidf)
        elif name == 'redis':
            for i in range(len(versions)):
                process = public.ExecShell('ps -ef | grep redis-server | grep -v grep')[0].decode()
                if process and process != '':
                    versions[i]['run'] = True
        elif name == 'subversion':
            for i in range(len(versions)):
                if os.path.exists("/home/svnrepos"):
                    process = public.ExecShell('ps -ef | grep svn | grep -v grep')[0].decode()
                    if process and process != '':
                        versions[i]['run'] = True
        else:
            for i in range(len(versions)):
                if versions[i]['status']: versions[i]['run'] = True;
        return versions

    def checkSoft(self, get):
        if get.name == 'tomcat':
            if not os.path.exists('/www/server/tomcat'):
                return False
            else:
                return True
        #     return public.returnMsg(True,'检测到tomcat环境')
        # public.returnMsg(False,'为啥没进来')

    def checkSoftStart(selfl, get):
        if get.name == 'subversion':
            process = public.ExecShell('ps -ef | grep svn | grep -v grep')[0].decode()
            if process and process != '':
                return True

    #名取PID
    def getPid(self,pname):
        try:
            if not self.pids: self.pids = psutil.pids()
            for pid in self.pids:
                if psutil.Process(pid).name() == pname: return True;
            return False
        except: return True
    
    #检测指定进程是否存活
    def checkProcess(self,pid):
        try:
            if not self.pids: self.pids = psutil.pids()
            if int(pid) in self.pids: return True
            return False;
        except: return False
    
    #获取配置模板
    def getConfigHtml(self,get):
        filename = self.__install_path + '/' + get.name + '/index.html';
        if not os.path.exists(filename): return public.returnMsg(False,'PLUGIN_GET_HTML');
        
        srcBody = public.readFile(filename)
        
        data = {}
        if srcBody:
            import chardet
            char=chardet.detect(srcBody.encode())
            data['encoding'] = char['encoding']
            if char['encoding'] == 'ascii':data['encoding'] = 'utf-8'
            data['data'] = srcBody.decode(char['encoding']).encode('utf-8')
            data['data'] = srcBody.decode()
            data['encoding'] = 'utf-8'
        else:
            data['data'] = srcBody
            data['encoding'] = 'utf-8'
        
        data['status'] = True
        return data['data']
    
    #取插件信息
    def getPluginInfo(self,get):
        try:
            pluginInfo = self.GetFind(get.name)
            # apacheVersion = ""
            # try:
            #     apavFile = '/www/server/apache/version.pl';
            #     if os.path.exists(apavFile):
            #         apacheVersion = public.readFile(apavFile).strip();
            # except:
            #     pass;
            pluginInfo['versions'] = self.checksSetup(pluginInfo['name'],pluginInfo['checks'],pluginInfo['versions'])
            return pluginInfo
        except:
            return False
    
    #取插件状态
    def getPluginStatus(self,get):
        find = self.GetFind(get.name);
        versions = [];
        for version in find['versions'].split(','):
            tmp = {}
            tmp['version'] = version
            tmp['status'] = find['status'];
            versions.append(tmp);
        return versions
    
    #设置插件状态
    def setPluginStatus(self,get):
        self.SetField(get.name, 'display', int(get.status))
        return public.returnMsg(True,'SET_SUCCESS');
'''
    #从云端获取插件列表
    def getCloudPlugin(self,get):
        if hasattr(web.ctx.session,'getCloudPlugin') and get != None: return public.returnMsg(True,'您的插件列表已经是最新版本-1!');
        import json
        if not hasattr(web.ctx.session,'downloadUrl'): web.ctx.session.downloadUrl = 'http://download.bt.cn';
        
        #获取列表
        try:
            newUrl = public.get_url();
            if os.path.exists('plugin/beta/config.conf'):
                downloadUrl = newUrl + '/install/list.json'
            else:
                downloadUrl = newUrl + '/install/list_new.json'
            data = json.loads(public.httpGet(downloadUrl))
            web.ctx.session.downloadUrl = newUrl;
        except:
            downloadUrl = web.ctx.session.downloadUrl + '/install/list_new.json'
            data = json.loads(public.httpGet(downloadUrl))
        
        n = i = j = 0;
        
        lists = self.GetList(None);
        
        for i in range(len(data)):
            for pinfo in lists:
                if data[i]['name'] != pinfo['name']: continue;
                data[i]['display'] = pinfo['display'];
            if data[i]['default']: 
                get.name = data[i]['name'];
                self.install(get);
        
        public.writeFile(self.__list,json.dumps(data));
        
        #获取分类
        try:
            downloadUrl = web.ctx.session.downloadUrl + '/install/type.json'
            types = json.loads(public.httpGet(downloadUrl))
            public.writeFile(self.__type,json.dumps(types));
        except:
            pass;
        
        #self.getCloudPHPExt(get);
        self.GetCloudWarning(get);
        web.ctx.session.getCloudPlugin = True;
        return public.returnMsg(True,'PLUGIN_UPDATE');

    #刷新缓存
    def flush_cache(self,get):
        self.getCloudPlugin(None);
        return public.returnMsg(True,'软件列表已更新!');

    #获取警告列表
    def GetCloudWarning(self,get):
        import json
        if not hasattr(web.ctx.session,'downloadUrl'): web.ctx.session.downloadUrl = 'http://download.bt.cn';
        downloadUrl = web.ctx.session.downloadUrl + '/install/warning.json'
        tstr = public.httpGet(downloadUrl)
        data = json.loads(tstr);
        if not data: return False;
        wfile = 'data/warning.json';
        wlist = json.loads(public.readFile(wfile));
        for i in range(len(data['data'])):
            for w in wlist['data']:
                if data['data'][i]['name'] != w['name']: continue;
                data['data'][i]['ignore_count'] = w['ignore_count'];
                data['data'][i]['ignore_time'] = w['ignore_time'];                         
        public.writeFile(wfile,json.dumps(data));
        return data;
    
    #请求插件事件
    def a(self,get):
        if not hasattr(get,'name'): return public.returnMsg(False,'PLUGIN_INPUT_A');
        path = self.__install_path + '/' + get.name
        if not os.path.exists(path + '/'+get.name+'_main.py'): return public.returnMsg(False,'PLUGIN_INPUT_B');
        sys.path.append(path);
        plugin_main = __import__(get.name+'_main');
        reload(plugin_main)
        pluginObject = eval('plugin_main.' + get.name + '_main()');
        if not hasattr(pluginObject,get.s): return public.returnMsg(False,'PLUGIN_INPUT_C',(get.s,));
        execStr = 'pluginObject.' + get.s + '(get)'
        return eval(execStr);
'''

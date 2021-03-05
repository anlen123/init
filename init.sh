#!/bin/bash
cat <<-'EOF'
+-----------------------------------------+
|            基本配置                     |
|           2.换源并更新                  |
|           3.配置zsh                     |
|           4.配置neovim                  |
|           5.配置docker                  |
|           6.安装annie                   |
|           7.安装ffmpeg                  |
|           8.安装docker版-nextcloud      |
|           9.安装docker版-aria2          |
|          10.配置Python虚拟环境          |
|          11.安装docker版-mysql          |
|          14.测速                        |
|          15.解决libsodium not found问题 |
|          16.配置ranger                  |
|          17.配置fzf                     |
|          18.配置v2ray                   |
|          19.配置proxychains-ng          |
+-----------------------------------------+
EOF
one(){ #换源
	if [ ! "$USER" = "root" ];then
		echo "请用root命令执行!"
		exit
	fi
	if [ $P_M == "yum" ];then
		$P_M install -y wget
		cp /etc/P_M.repos.d/CentOS-Base.repo /etc/P_M.repos.d/CentOS-Base.repo.bak
		wget -O /etc/P_M.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
		cp /etc/P_M.repos.d/epel.repo /etc/P_M.repos.d/epel.repo.bak
		wget -O /etc/P_M.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
		$P_M  clean  all
		$P_M  makecache
		$P_M -y update
	elif [ $P_M == "apt-get" ];then
		sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup
		cat > /etc/apt/sources.list<<-'EOF'
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
	EOF
		sudo $P_M update -y
		sudo $P_M upgrade -y
	fi
	#换源
}

two(){ # 配置zsh的
	cd ~ 
    $P_M  -y install gcc perl-ExtUtils-MakeMaker
    $P_M -y install ncurses-devel
    $P_M -y install libncurses5-dev
	if ! command -v git&>/dev/null ;then 
		$P_M install -y git
	fi 

	if [ ! -d ~/my_zsh ];then
		git clone https://github.com/anlen123/my_zsh
        if ! command -v zsh&>/dev/null ;then 
            cd my_zsh 
            tar xvf zsh-5.8.tar.xz
            cd zsh-5.8
            ./configure
            make && make install
            echo "/usr/local/bin/zsh" >> /etc/shells # 添加：/usr/local/bin/zsh
        fi 
	fi
	if [ $? -eq 0 ];then
		cd 
		rm -rf .zshrc .oh-my-zsh .p10k.zsh 
		cd my_zsh 
		mv zshrc .zshrc 
		mv oh-my-zsh .oh-my-zsh 
		mv p10k.zsh .p10k.zsh 
		cp -r .zshrc ~
		cp -r .oh-my-zsh ~
		cp -r .p10k.zsh ~
		cd ~
		chsh -s /usr/local/bin/zsh
		if [ $? -eq 0 ];then 
			cd ~
			rm -rf -R my_zsh
		fi
	fi
    #git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	#以上是配置zsh的
}

three(){ #以下是配置nvim的
	cd ~ 
	if ! command -v nvim&>/dev/null ;then 
		if [[ $P_M == "yum" ]];then
            yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
            yum install -y neovim python3-neovim 
		else
			$P_M install -y neovim
		fi 
        cd ~
        ping -c1 -W1 google.com
        if [ $? -eq 0 ];then 
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        else
            wget https://gitee.com/anlen123/init_file/attach_files/535877/download/nvim.appimage
        fi
        mv nvim.appimage nvim 
        chmod u+x nvim 
        mv /usr/bin/nvim /usr/bin/nvim_back
        mv nvim /usr/bin/nvim
	fi 
	cd ~
	if [ ! -d ~/.config/nvim ];then 
		mkdir -p ~/.config 
		cd ~/.config  
		if [ $? -eq 0 ];then 
			git clone https://gitee.com/anlen123/nvim
		fi
		cd ~
	fi
	#以上是配置nvim的
}

four(){ #配置docker
	cd ~
	if ! command -v docker&>/dev/null ;then
		if [[ $P_M == "yum" ]];then
			#yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
			$P_M -y install docker
		else
			$P_M -y install docker.io
		fi
	fi
	sudo service docker start
	sudo systemctl daemon-reload
	sudo systemctl restart docker.service
	sudo systemctl enable docker
	sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json <<-'EOF'
	{
	  "registry-mirrors": ["https://gr51o72c.mirror.aliyuncs.com"]
	}
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker
	
	if [ "$(docker ps -a | awk '{print$2}'| grep portainer/portainer)" == "portainer/portainer" ] ;then
		echo "docker可视化已存在"
	else 
		docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --name prtainer-test portainer/portainer
	fi

	if [ $? -eq 0 ];then
		docker ps -a 
	fi
}

os_check() { #检查系统
    if [ -e /etc/redhat-release ] ; then
        REDHAT=`cat /etc/redhat-release | cut -d' '  -f1 `
    else
        DEBIAN=`cat /etc/issue | cut -d' '  -f1 `
    fi

    if [ "$REDHAT" == "CentOS" -o "$REDHAT" == "RED" ] ; then 
        P_M=yum
    elif [ "$DEBIAN" == "Ubuntu" -o "$DEBIAN" == "ubuntu" ] ; then 
        P_M=apt-get
    else
        Operating system does not support
        exit 1
    fi
	echo 工具是 "$P_M"
}
five(){  #安装annie
	if ! command -v wget&>/dev/null ;then 
        $P_M install -y wget 
    fi
	if ! command -v tar&>/dev/null ;then 
        $P_M install -y tar 
    fi
	if ! command -v annie&>/dev/null ;then 
        ping -c1 -W1 google.com
        if [ $? -eq 0 ];then 
            wget https://github.com/iawia002/annie/releases/download/0.10.3/annie_0.10.3_Linux_64-bit.tar.gz
        else
            wget https://gitee.com/anlen123/init_file/attach_files/535876/download/annie_0.10.3_Linux_64-bit.tar.gz
        fi
		if [ $? -eq 0 ];then
			tar xvzf annie_0.10.3_Linux_64-bit.tar.gz
            sudo mv annie /usr/bin/
            rm -rf annie_0.10.3_Linux_64-bit.tar.gz
		fi
    fi
}

six(){
	if ! command -v yasm&>/dev/null ;then 
        $P_M install -y yasm
    fi
	if ! command -v gcc&>/dev/null ;then 
        $P_M install -y gcc
    fi
	if ! command -v bzip2&>/dev/null ;then 
        $P_M install -y bzip2
    fi
    ping -c1 google.com
	if ! command -v ffmpeg&>/dev/null ;then 

        ping -c1 -W1 google.com
        if [ $? -eq 0 ];then 
            wget https://github.com/anlen123/init/releases/download/v1/ffmpeg-release-amd64-static.tar.xz
        else
            wget "https://gitee.com/anlen123/init_file/raw/master/ffmpeg-release-amd64-static.tar.xz" -O ffmpeg-release-amd64-static.tar.xz
        fi
		if [ $? -eq 0 ];then
			xz -d ffmpeg-release-amd64-static.tar.xz
			tar -xvf ffmpeg-release-amd64-static.tar
			rm -rf -R ffmpeg-release-amd64-static.tar
			mv ffmpeg-4.3.1-amd64-static/ ffmpeg
			mv ffmpeg /usr/
			echo "export PATH=/usr/ffmpeg:$PATH" >> /etc/profile
            if [ $? -eq 0 ];then 
			    source /etc/profile
            fi
		fi
	fi
}
seven(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号:" duan
		docker run -d -it --name nextcloud --restart=always -p $duan:80 -v /data/nextcloud:/var/www/html/data library/nextcloud
		echo -e "nextcloud 云盘部署成功,端口$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
}

eight(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号(推荐6800):" duan
		docker run -d --name aria2 --restart=always -e RPC_SECRET=123456 -p $duan:6800 -v ~/aria2-config:/config -v ~/aria2-downloads:/downloads p3terx/aria2-pro
		echo -e "aria2 的密码是123456,端口是$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
}

nine(){
	cat<<-'EOF'
+-----------------------------------------+
|           1.下载Miniconda               |
|           2.更新Miniconda下载源         |
|           3.更新pip安装源               |
+-----------------------------------------+
	EOF
	echo -en "Please input your number:"
	read op
	case "$op" in
	1)
	wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh
	chmod u+x Miniconda3-py38_4.8.3-Linux-x86_64.sh
	./Miniconda3-py38_4.8.3-Linux-x86_64.sh
	;;
	2)
    # 添加镜像
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda
    conda config --set show_channel_urls yes
	;;
	3)
	cd ~
    if [ ! -d ~/.pip ];then
        mkdir .pip
    fi 
    if [ ! -f ~/.pip/pip.conf ];then 
        cat >~/.pip/pip.conf <<-'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
    fi
	;;
	*)
	echo "输入参数错误"
	;;
	esac
}

ten(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号(推荐3306):" duan
		read -p "输入你的密码:" passwd
		docker run -d --name some-mysql -p $duan:3306 -e MYSQL_ROOT_PASSWORD=$passwd --restart=always mysql
		echo -e "mysql ,密码:$passwd,端口是$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
	
}
thirteen(){
    if ! command -v speedtest&>/dev/null ;then 
        if ! command -v git&>/dev/null ;then 
            $P_M install git
        fi 
        git clone https://github.com/sivel/speedtest-cli.git
        cd speedtest-cli
        python setup.py install
        speedtest
        rm -rf -R speedtest-cli
    else
        speedtest
    fi
}

fourteen(){
	if [[ $P_M == "yum" ]];then
		#yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
		$P_M groupinstall "Development Tools" -y
		yum install wget -y
	else
		sudo apt-get update
		sudo apt-get install build-essential wget -y
	fi
	wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
	tar xzvf LATEST.tar.gz
	cd libsodium*
	./configure
	make -j8 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
}
shiwu(){
	if ! command -v ranger&>/dev/null ;then 
        $P_M install ranger -y
    fi
    if [[ $P_M == "apt-get" ]];then 
        ranger --copy-config=all
        echo 'export EDITOR="/usr/bin/nvim"' >> ~/.zshrc
    fi
}
shiqi(){
    if ! command -v fzf&>/dev/null ;then 
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install 
    fi
    source ~/.zshrc
}
shiba(){
    if ! command -v unzip&>/dev/null ;then 
        yum install -y unzip zip
    fi
    cd 
     wget https://github.91chifun.workers.dev/https://github.com//v2ray/v2ray-core/releases/download/v4.28.2/v2ray-linux-64.zip
    mkdir v2 
    mv v2ray-linux-64.zip v2 
    cd v2 
    unzip v2ray-linux-64.zip
    rm -rf v2ray-linux-64.zip 
    mv config.json config_temp.json
    cat > run.sh <<-'EOF'
#!/bin/bash 
./kill.sh 
nohup ./v2ray -c ./config.json > ./v2.log 2>&1 &
EOF
    chmod 755 run.sh 
    cat >> kill.sh <<-'EOF' 
#!/bin/bash 
ps -ef | grep v2ray | grep -v grep  | awk '{print $2}' | xargs kill -9
EOF
chmod 755 kill.sh
cat >> switch_node.py <<-'EOF'
import json 
with open("config.json") as f :
    txt = f.read()
    config  = json.loads(txt)

with open("node.json") as f :
    txt = f.read()
    new_node  = json.loads(txt)['outbounds']
config['outbounds'] = new_node 
with open("config.json","w") as f :
    json.dump(config,f, ensure_ascii=False)
EOF
touch node.json
cat >> node.json <<-'EOF'
{
    "outbounds": [
        {
            "mux": {
            },
            "protocol": "vmess",
            "sendThrough": "0.0.0.0",
            "settings": {
                "vnext": [
                    {
                        "address": "flcnshu.com",
                        "port": 51521,
                        "users": [
                            {
                                "alterId": 2,
                                "id": "eca8d-a313-82187e15590b",
                                "level": 0,
                                "security": "auto"
                            }
                        ]
                    }
                ]
            },
            "streamSettings": {
                "dsSettings": {
                    "path": "/"
                },
                "httpSettings": {
                    "host": [
                    ],
                    "path": "/"
                },
                "kcpSettings": {
                    "congestion": false,
                    "downlinkCapacity": 20,
                    "header": {
                        "type": "none"
                    },
                    "mtu": 1350,
                    "readBufferSize": 1,
                    "seed": "",
                    "tti": 20,
                    "uplinkCapacity": 5,
                    "writeBufferSize": 1
                },
                "network": "ws",
                "quicSettings": {
                    "header": {
                        "type": "none"
                    },
                    "key": "",
                    "security": ""
                },
                "security": "tls",
                "sockopt": {
                    "mark": 255,
                    "tcpFastOpen": false,
                    "tproxy": "off"
                },
                "tcpSettings": {
                    "header": {
                        "request": {
                            "headers": {
                            },
                            "method": "GET",
                            "path": [
                            ],
                            "version": "1.1"
                        },
                        "response": {
                            "headers": {
                            },
                            "reason": "OK",
                            "status": "200",
                            "version": "1.1"
                        },
                        "type": "none"
                    }
                },
                "tlsSettings": {
                    "allowInsecure": false,
                    "allowInsecureCiphers": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                    ],
                    "disableSessionResumption": true,
                    "disableSystemRoot": false,
                    "serverName": ""
                },
                "wsSettings": {
                    "headers": {
                    },
                    "path": "/564dfa20/"
                },
                "xtlsSettings": {
                    "allowInsecure": false,
                    "allowInsecureCiphers": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                    ],
                    "disableSessionResumption": true,
                    "disableSystemRoot": false,
                    "serverName": ""
                }
            },
            "tag": "PROXY"
        }
    ]
}
EOF
cat >> parsev2.py <<-'EOF'
# -*- coding: utf-8 -*- 
import base64 
from urllib.parse import urlsplit
import os 
import json
class parsev2:
    def __init__(self,url):
        self.url = url
        self.share_links = []
        self.configs = []
    def downNode(self):
        if os.path.exists("v2nodes"):
            os.remove("v2nodes")
        os.system(f"wget -q {self.url} -O v2nodes")
    def getShareLinks(self):
        f = open("v2nodes")
        txt = f.read()
        f.close()
        share_links = base64.b64decode(txt).decode("utf-8").splitlines()
        self.share_links = share_links

    def base64StrFun(self,base64Str):
        try:
            base64Str=base64.urlsafe_b64decode(base64Str)
        except:
            lens = len(base64Str)
            lenx = lens - (lens % 4 if lens % 4 else 4)
            base64Str= base64.decodestring(base64Str[:lenx])
        return base64Str
    def parseVmess(self):
        configs = []
        for share_link in self.share_links:
            url=share_link.split("://")
            net=url[1]
            net=str.encode(net)
            nodeStr= self.base64StrFun(net)
            nodeStr=bytes.decode(nodeStr)
            configs.append(json.loads(nodeStr))
        self.configs = configs
    def swithNode(self):
        for index, x in enumerate(self.configs):
            print(f"{index+1}-->>{x['ps']}")
        num =int( input("输入你想用的节点: "))
        with open("config.json") as f :
            txt = f.read()
            config  = json.loads(txt)
        node = v2.configs[num-1]
        config['outbounds'][0]['settings']['vnext'][0]['address']=node['add']
        config['outbounds'][0]['settings']['vnext'][0]['port']=node['port']
        config['outbounds'][0]['settings']['vnext'][0]['users'][0]['alterId']=node['aid']
        config['outbounds'][0]['settings']['vnext'][0]['users'][0]['id']=node['id']
        config['outbounds'][0]['streamSettings']['kcpSettings']['header']['type']=node['headerType']
        config['outbounds'][0]['streamSettings']['network']=node['net']
        config['outbounds'][0]['streamSettings']['security']=node['tls']
        config['outbounds'][0]['streamSettings']['wsSettings']['path']=node['path']
        config['outbounds'][0]['streamSettings']['quicSettings']['header']['type']=node['type']
        if node['host']!="":
            config['outbounds'][0]['streamSettings']['httpSettings']['host'].append(node['host'])
        with open("config.json","w") as f :
            json.dump(config,f, ensure_ascii=False)
        print(node['ps'])
        os.system("./run.sh")

v2 = parsev2("你的机场订阅连接")
v2.downNode()
v2.getShareLinks()
v2.parseVmess()
v2.swithNode()
EOF
cat >> config.json <<-'EOF'
{
  "policy": {
    "system": {
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "log": {
    "access": "",
    "error": "",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "tag1",
      "port": 1080,
      "listen": "0.0.0.0",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "settings": {
        "auth": "noauth",
        "udp": true,
        "allowTransparent": false
      }
    },
    {
      "tag": "tag2",
      "port": 1081,
      "listen": "0.0.0.0",
      "protocol": "http",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "settings": {
        "udp": false,
        "allowTransparent": false
      }
    },
    {
      "tag": "api",
      "port": 55123,
      "listen": "127.0.0.1",
      "protocol": "dokodemo-door",
      "settings": {
        "udp": false,
        "address": "127.0.0.1",
        "allowTransparent": false
      }
    }
  ],
"outbounds": [
        {
            "mux": {
            },
            "protocol": "vmess",
            "sendThrough": "0.0.0.0",
            "settings": {
                "vnext": [
                    {
                        "address": "flzz.gom",
                        "port": 59981,
                        "users": [
                            {
                                "alterId": 2,
                                "id": "eca8d-a313-82187e15590b",
                                "level": 0,
                                "security": "auto"
                            }
                        ]
                    }
                ]
            },
            "streamSettings": {
                "dsSettings": {
                    "path": "/"
                },
                "httpSettings": {
                    "host": [
                    ],
                    "path": "/"
                },
                "kcpSettings": {
                    "congestion": false,
                    "downlinkCapacity": 20,
                    "header": {
                        "type": "none"
                    },
                    "mtu": 1350,
                    "readBufferSize": 1,
                    "seed": "",
                    "tti": 20,
                    "uplinkCapacity": 5,
                    "writeBufferSize": 1
                },
                "network": "ws",
                "quicSettings": {
                    "header": {
                        "type": "none"
                    },
                    "key": "",
                    "security": ""
                },
                "security": "tls",
                "sockopt": {
                    "mark": 255,
                    "tcpFastOpen": false,
                    "tproxy": "off"
                },
                "tcpSettings": {
                    "header": {
                        "request": {
                            "headers": {
                            },
                            "method": "GET",
                            "path": [
                            ],
                            "version": "1.1"
                        },
                        "response": {
                            "headers": {
                            },
                            "reason": "OK",
                            "status": "200",
                            "version": "1.1"
                        },
                        "type": "none"
                    }
                },
                "tlsSettings": {
                    "allowInsecure": false,
                    "allowInsecureCiphers": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                    ],
                    "disableSessionResumption": true,
                    "disableSystemRoot": false,
                    "serverName": ""
                },
                "wsSettings": {
                    "headers": {
                    },
                    "path": "/564dfa20/"
                },
                "xtlsSettings": {
                    "allowInsecure": false,
                    "allowInsecureCiphers": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                    ],
                    "disableSessionResumption": true,
                    "disableSystemRoot": false,
                    "serverName": ""
                }
            },
            "tag": "PROXY"
        }
    ],
  "stats": {},
  "api": {
    "tag": "api",
    "services": [
      "StatsService"
    ]
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api"
      }
    ]
  }
}
EOF
}

shijiu(){
	git clone https://github.com.cnpmjs.org/rofl0r/proxychains-ng.git
    cd proxychains-ng
	./configure --prefix=/usr --sysconfdir=/etc
	make
	make install make install-config 
    status=$(cat /etc/proxychains.conf | grep 'http 127.0.0.1 1081')
    if [ $status=="" ] ;then 
        echo "http 127.0.0.1 1081" >> /etc/proxychains.conf 
    fi
	mv /usr/bin/proxychains4 /usr/bin/v2
}



echo -en "Please input your number:"
read op
os_check
case "$op" in 
2)  
	one
	;;
3)  
	two
	;;
4)
	three
	;;
5) 
	four
	;;
6)
    five
    ;;
7)
    six
    ;;
8)
    seven
    ;;
9)
    eight
    ;;
10)
    nine
    ;;
11)
	ten
	;;
12)
	eleven
	;;
13)	
	twelve
	;;
14)	
	thirteen
	;;
15) 
	fourteen
	;;
16)
    shiwu 
    ;;
17)
    shiqi
    ;;
18)
    shiba
    ;;
19)
    shijiu
    ;;
*)
    echo "输入错误!!"
    ;;
esac

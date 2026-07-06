#!/bin/bash
#wget https://github.com/${GitUser}/
GitUser="jiwakentantal"
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
# Valid Script
VALIDITY () {
    today=`date -d "0 days" +"%Y-%m-%d"`
    Exp1=$(curl https://raw.githubusercontent.com/${GitUser}/allow/main/ipvps.conf | grep $MYIP | awk '{print $4}')
    if [[ $today < $Exp1 ]]; then
    echo -e "\e[32mYOUR SCRIPT ACTIVE..\e[0m"
    else
    echo -e "\e[31mYOUR SCRIPT HAS EXPIRED!\e[0m";
    echo -e "\e[31mPlease renew your ipvps first\e[0m"
    exit 0
fi
}
IZIN=$(curl https://raw.githubusercontent.com/${GitUser}/allow/main/ipvps.conf | awk '{print $5}' | grep $MYIP)
if [ $MYIP = $IZIN ]; then
echo -e "\e[32mPermission Accepted...\e[0m"
VALIDITY
else
echo -e "\e[31mPermission Denied!\e[0m";
echo -e "\e[31mPlease buy script first\e[0m"
rm -f setup.sh
exit 0
fi
clear
#Color
RED="\033[31m"
export NC='\e[0m'
export DEFBOLD='\e[39;1m'
export RB='\e[31;1m'
export GB='\e[32;1m'
export YB='\e[33;1m'
export BB='\e[34;1m'
export MB='\e[35;1m'
export CB='\e[35;1m'
export WB='\e[37;1m'

if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
clear

if [ -f "/usr/local/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 0
fi

#update
apt update -y
apt full-upgrade -y
apt dist-upgrade -y
apt install sudo -y
apt install zip -y
apt install unzip -y
apt install nano -y
apt install htop -y
apt install socat curl screen cron neofetch screenfetch netfilter-persistent vnstat fail2ban -y
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y
clear

echo -e "\e[0;32mINSTALLING RESOLVCONF...\e[0m"
sleep 1
apt install resolvconf -y
systemctl start resolvconf.service
systemctl enable resolvconf.service
echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/head
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
systemctl restart resolvconf.service
echo -e "\e[0;32mDONE INSTALLING RESOLVCONF\e[0m"
clear

# Make Folder Log XRAY
mkdir -p /var/log/xray
chmod +x /var/log/xray

# Make Folder XRAY
mkdir -p /usr/local/etc/xray
touch /usr/local/etc/xray/warp-domain.txt
#Download XRAY CORE
curl -L https://raw.githubusercontent.com/jiwakentantal/caliburn/main/xraycore/v25.10.15/xray.linux.zip > xray.linux.zip && unzip *.zip && mv xray /usr/local/bin && chmod +x /usr/local/bin/xray && rm *.zip *.dat LICENSE README.md


#Server Info
curl -s ipinfo.io/city >> /usr/local/etc/xray/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /usr/local/etc/xray/org
curl -s ipinfo.io/timezone >> /usr/local/etc/xray/timezone
clear

cd
clear

# Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
clear

# set time GMT +8 Kuala Lumpur
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# set login banner
wget -q -O /etc/issue.net "https://raw.githubusercontent.com/vinstechmy/VlessWebsocket/main/OTHERS/issues.net" && chmod +x /etc/issue.net
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config

# Install Nginx
apt install nginx -y
rm /var/www/html/*.html
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
systemctl restart nginx
clear
mkdir /var/lib/premium-script;
#Nama penyedia script
echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "   \e[1;32mPlease enter the name of Provider for Script."
read -p "   Name : " nm
echo $nm > /root/provided
echo ""
# Insert Domain Features
touch /usr/local/etc/xray/domain
echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "   .----------------------------------."
echo -e "   |\e[1;32mPlease select a domain type below \e[0m|"
echo -e "   '----------------------------------'"
echo " "
read -rp "Insert Domain : " -e dns
if [ -z $dns ]; then
echo -e "Please Insert Domain!"
else
echo "$dns" > /usr/local/etc/xray/domain
echo "DNS=$dns" > /var/lib/premium-script/ipvps.conf
fi
clear

# Install Cert Domain For XRAY 
systemctl stop nginx
domain=$(cat /usr/local/etc/xray/domain)
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc

# Nginx directory file download
mkdir -p /home/vps/public_html
cd
chown -R www-data:www-data /home/vps/public_html

# Random UUID For XRAY
uuid=$(cat /proc/sys/kernel/random/uuid)

#INSTALLING WEBSOCKET TLS
cat> /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#xray-vless-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vlessws-tls"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        }
      }
     }
  ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
		]
}
END

# // INSTALLING WEBSOCKET NONE-TLS
cat> /usr/local/etc/xray/none.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
     "port": "80",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#xray-vless-nontls
          }
        ],
        "decryption": "none"
      },
      "encryption": "none",
      "streamSettings": {
        "network": "ws",
	"security": "none",
        "wsSettings": {
          "path": "/vlessws-ntls",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ],
        "enabled": true
      },
      "tag": "pakyavpn"
    }
  ]
}
END

# // INSTALLING WEBSOCKET NONE-TLS
cat> /usr/local/etc/xray/outbounds.json << END
{
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
END

#Remove Old Service
rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service.d

#XRAY Service
cat> /etc/systemd/system/xray.service << END
[Unit]
Description=XRAY-MULTIPORT SERVICE
Documentation=https://t.me/anakjati567 https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

#XRAY Service
cat> /etc/systemd/system/xray@.service << END
[Unit]
Description=Xray Service
Documentation=https://t.me/anakjati567 https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run \
  -config /usr/local/etc/xray/%i.json \
  -config /usr/local/etc/xray/outbounds.json \
Restart=on-failure
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

# Set Nginx Conf
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 1;
pid /var/run/nginx.pid;
events {
	multi_accept on;
	worker_connections 1024;
}
http {
	gzip on;
	gzip_vary on;
	gzip_comp_level 5;
	gzip_types text/plain application/x-javascript text/xml text/css;
	autoindex on;
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	server_tokens off;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;
	fastcgi_buffer_size 8m;
	fastcgi_buffers 8 8m;
	fastcgi_read_timeout 600;
	#CloudFlare IPv4
	set_real_ip_from 199.27.128.0/21;
	set_real_ip_from 173.245.48.0/20;
	set_real_ip_from 103.21.244.0/22;
	set_real_ip_from 103.22.200.0/22;
	set_real_ip_from 103.31.4.0/22;
	set_real_ip_from 141.101.64.0/18;
	set_real_ip_from 108.162.192.0/18;
	set_real_ip_from 190.93.240.0/20;
	set_real_ip_from 188.114.96.0/20;
	set_real_ip_from 197.234.240.0/22;
	set_real_ip_from 198.41.128.0/17;
	set_real_ip_from 162.158.0.0/15;
	set_real_ip_from 104.16.0.0/12;
	#Incapsula
	set_real_ip_from 199.83.128.0/21;
	set_real_ip_from 198.143.32.0/19;
	set_real_ip_from 149.126.72.0/21;
	set_real_ip_from 103.28.248.0/22;
	set_real_ip_from 45.64.64.0/22;
	set_real_ip_from 185.11.124.0/22;
	set_real_ip_from 192.230.64.0/18;
	real_ip_header CF-Connecting-IP;
	include /etc/nginx/conf.d/*.conf;
}
EOF

#Nginx Webserver
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/vinstechmy/VlessWebsocket/main/OTHERS/vps.conf"

echo -e "[ ${YB}INFO${NC} ] Restart Daemon Service"
echo ""
systemctl daemon-reload
sleep 1

# enable xray ws tls
echo -e "[ ${GB}OK${NC} ] Restarting XRAY Core Service"
systemctl daemon-reload
systemctl enable xray.service
systemctl start xray.service
systemctl restart xray.service

# enable xray ws ntls
systemctl daemon-reload
systemctl enable xray@none.service
systemctl start xray@none.service
systemctl restart xray@none.service

# enable xray ws ntls
systemctl daemon-reload
systemctl enable xray@outbounds.service
systemctl start xray@outbounds.service
systemctl restart xray@outbounds.service

# enable nginx
echo -e "[ ${GB}OK${NC} ] Restarting Nginx Service"
systemctl restart nginx

sleep 1

# install
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof
echo "clear" >> .profile
echo "menu" >> .profile

# Blokir TORRENT
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Enable BBR
clear
echo -e "[ ${GB}INFO${NC} ] Installing TCP BBR Please Wait . . ."
echo ""
sleep 2
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo -e "[ ${GB}INFO${NC} ] TCP BBR Successfully Installed !"
echo ""
sleep 2
clear
cd /usr/local/bin

rm -rf /usr/local/bin/geoip.dat

rm -rf /usr/local/bin/geosite.dat

wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202602030418/geoip.dat && chmod 755 geoip.dat;

wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202602030418/geosite.dat && chmod 755 geosite.dat;

cd
sleep 2
clear

#XRAY
cd /usr/bin
wget -O autobackup "https://raw.githubusercontent.com/huaweipadu/script-lite/main/system/backupBot.sh"
wget -O port-xray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/change-port/port-xray.sh"
wget -O certv2ray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/cert.sh"
wget -O xraay "https://raw.githubusercontent.com/${GitUser}/caliburn/main/menu/xraay.sh"
wget -O add-xray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/add-user/add-xray.sh"
wget -O del-xray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/delete-user/del-xray.sh"
wget -O renew-xray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/renew-user/renew-xray.sh"
wget -O cek-xray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/cek-user/cek-xray.sh"
wget -O add-vless "https://raw.githubusercontent.com/${GitUser}/caliburn/main/add-user/add-vless.sh"
wget -O trial-vless "https://raw.githubusercontent.com/${GitUser}/caliburn/main/add-user/trial-vless.sh"
wget -O del-vless "https://raw.githubusercontent.com/${GitUser}/caliburn/main/delete-user/del-vless.sh"
wget -O renew-vless "https://raw.githubusercontent.com/${GitUser}/caliburn/main/renew-user/renew-vless.sh"
wget -O show-vless "https://raw.githubusercontent.com/${GitUser}/caliburn/main/add-user/show-vless.sh"
wget -O cek-vless "https://raw.githubusercontent.com/${GitUser}/caliburn/main/cek-user/cek-vless.sh"
chmod +x autobackup
chmod +x port-xray
chmod +x certv2ray
chmod +x xraay
chmod +x add-xray
chmod +x del-xray
chmod +x renew-xray
chmod +x cek-xray
chmod +x add-vless
chmod +x trial-vless
chmod +x del-vless
chmod +x renew-vless
chmod +x show-vless
chmod +x cek-vless


#OTHERS
cd /usr/bin
wget -O add-host "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/add-host.sh"
wget -O about "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/about.sh"
wget -O menu "https://raw.githubusercontent.com/${GitUser}/caliburn/main/menu.sh"
wget -O add-ssh "https://raw.githubusercontent.com/${GitUser}/caliburn/main/add-user/add-ssh.sh"
wget -O trial "https://raw.githubusercontent.com/${GitUser}/caliburn/main/add-user/trial.sh"
wget -O del-ssh "https://raw.githubusercontent.com/${GitUser}/caliburn/main/delete-user/del-ssh.sh"
wget -O member "https://raw.githubusercontent.com/${GitUser}/caliburn/main/member.sh"
wget -O delete "https://raw.githubusercontent.com/${GitUser}/caliburn/main/delete-user/delete.sh"
wget -O cek-ssh "https://raw.githubusercontent.com/${GitUser}/caliburn/main/cek-user/cek-ssh.sh"
wget -O restart "https://raw.githubusercontent.com/huaweipadu/vlessonly/main/restart.sh"
wget -O speedtest "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/info.sh"
wget -O ram "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/ram.sh"
wget -O renew-ssh "https://raw.githubusercontent.com/${GitUser}/caliburn/main/renew-user/renew-ssh.sh"
wget -O autokill "https://raw.githubusercontent.com/${GitUser}/caliburn/main/autokill.sh"
wget -O ceklim "https://raw.githubusercontent.com/${GitUser}/caliburn/main/cek-user/ceklim.sh"
wget -O tendang "https://raw.githubusercontent.com/${GitUser}/caliburn/main/tendang.sh"
wget -O clear-log "https://raw.githubusercontent.com/${GitUser}/caliburn/main/clear-log.sh"
wget -O change-port "https://raw.githubusercontent.com/${GitUser}/caliburn/main/change.sh"
wget -O port-websocket "https://raw.githubusercontent.com/${GitUser}/caliburn/main/change-port/port-websocket.sh"
wget -O wbmn "https://raw.githubusercontent.com/${GitUser}/caliburn/main/webmin.sh"
wget -O xp "https://raw.githubusercontent.com/${GitUser}/caliburn/main/xp.sh"
wget -O kernel-updt "https://raw.githubusercontent.com/${GitUser}/caliburn/main/kernel.sh"
wget -O user-list "https://raw.githubusercontent.com/${GitUser}/caliburn/main/more-option/user-list.sh"
wget -O user-lock "https://raw.githubusercontent.com/${GitUser}/caliburn/main/more-option/user-lock.sh"
wget -O user-unlock "https://raw.githubusercontent.com/${GitUser}/caliburn/main/more-option/user-unlock.sh"
wget -O user-password "https://raw.githubusercontent.com/${GitUser}/caliburn/main/more-option/user-password.sh"
wget -O antitorrent "https://raw.githubusercontent.com/${GitUser}/caliburn/main/more-option/antitorrent.sh"
wget -O swap "https://raw.githubusercontent.com/${GitUser}/caliburn/main/swapkvm.sh"
wget -O check-sc "https://raw.githubusercontent.com/basikal123/moto/main/running.sh"
wget -O ssh "https://raw.githubusercontent.com/${GitUser}/caliburn/main/menu/ssh.sh"
wget -O autoreboot "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/autoreboot.sh"
wget -O bbr "https://raw.githubusercontent.com/${GitUser}/caliburn/main/system/bbr.sh"
wget -O port-xray "https://raw.githubusercontent.com/${GitUser}/caliburn/main/change-port/port-xray.sh"
wget -O panel-domain "https://raw.githubusercontent.com/${GitUser}/caliburn/main/menu/panel-domain.sh"
wget -O system "https://raw.githubusercontent.com/${GitUser}/caliburn/main/menu/system.sh"
chmod +x add-host
chmod +x menu
chmod +x add-ssh
chmod +x trial
chmod +x del-ssh
chmod +x member
chmod +x delete
chmod +x cek-ssh
chmod +x restart
chmod +x speedtest
chmod +x info
chmod +x about
chmod +x autokill
chmod +x tendang
chmod +x ceklim
chmod +x ram
chmod +x renew-ssh
chmod +x clear-log
chmod +x change-port
chmod +x restore
chmod +x port-websocket
chmod +x wbmn
chmod +x xp
chmod +x kernel-updt
chmod +x user-list
chmod +x user-lock
chmod +x user-unlock
chmod +x user-password
chmod +x antitorrent
chmod +x swap
chmod +x check-sc
chmod +x ssh
chmod +x autoreboot
chmod +x bbr
chmod +x port-xray
chmod +x panel-domain
chmod +x system


# Installing RAM & CPU Monitor
curl https://raw.githubusercontent.com/xxxserxxx/gotop/master/scripts/download.sh | bash && chmod +x gotop && sudo mv gotop /usr/local/bin/

echo -e "[ ${GB}INFO${NC} ] Autoscript Files Successfully Download !"
echo ""
sleep 2
clear

echo "0 0 * * * root /usr/bin/delete" >> /etc/crontab
echo "*/2 * * * * root /usr/bin/clear-log" >> /etc/crontab
echo "0 5 * * * root reboot" >> /etc/crontab
echo "0 0 * * * root /usr/bin/xp" >> /etc/crontab

#Set Log Cleaner
if [ ! -f "/etc/cron.d/clear-log" ]; then
cat> /etc/cron.d/clear-log << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/2 * * * * root /usr/bin/clear-log
END
fi

systemctl restart cron
systemctl restart sshd

#Install Rclone
wget https://raw.githubusercontent.com/${GitUser}/caliburn/main/install/set-br.sh && chmod +x set-br.sh && ./set-br.sh

# remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

rm -f /root/set-br.sh

#Autoscript Version
echo "1.0" > /home/ver

clear
echo " "
echo "Installation has been completed!!"
echo " "
echo "=========================[SCRIPT PREMIUM]========================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "-----------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "    [INFORMASI SSH & OpenVPN]" | tee -a log-install.txt
echo "    -------------------------" | tee -a log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200"  | tee -a log-install.txt
echo "   - OpenVPN SSL             : 110"  | tee -a log-install.txt
echo "   - Stunnel4                : 222, 777"  | tee -a log-install.txt
echo "   - Dropbear                : 442, 109"  | tee -a log-install.txt
echo "   - OHP Dropbear            : 8585"  | tee -a log-install.txt
echo "   - OHP SSH                 : 8686"  | tee -a log-install.txt
echo "   - OHP OpenVPN             : 8787"  | tee -a log-install.txt
echo "   - Websocket SSH(HTTP)     : 8080"  | tee -a log-install.txt
echo "   - Websocket SSL(HTTPS)    : 222"  | tee -a log-install.txt
echo "   - Websocket OpenVPN       : 2084"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "    [INFORMASI Sqd, Bdvp, Ngnx]" | tee -a log-install.txt
echo "    ---------------------------" | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8000 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "    [INFORMASI XRAY]"  | tee -a log-install.txt
echo "    ----------------" | tee -a log-install.txt
echo "   - Xray Vless Ws Tls       : 443"  | tee -a log-install.txt
echo "   - Xray Vless Ws None Tls  : 80"  | tee -a log-install.txt
echo "   - Xray Vless Tcp Xtls     : 443"  | tee -a log-install.txt
echo "   --------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Kuala_Lumpur (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On 05.00 GMT +8" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo "   - White Label" | tee -a log-install.txt
echo "   - Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo "--------------------------Script By Pakyavpn------------------------" | tee -a log-install.txt
clear
echo ""
echo ""
echo -e "    \e[1;32m.------------------------------------------.\e[0m"
echo -e "    \e[1;32m|     SUCCESFULLY INSTALLED THE SCRIPT     |\e[0m"
echo -e "    \e[1;32m'------------------------------------------'\e[0m"
echo ""
echo -e "   \e[1;32mYour VPS Will Be Automatical Reboot In 5 seconds\e[0m"
rm -r setup.sh
sleep 5
reboot
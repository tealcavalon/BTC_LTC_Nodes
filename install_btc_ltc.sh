#!/bin/bash

echo "This HowTo will install a full bitcoin and litecoin node"
echo "For all Ubuntu versions, may work with Debian distro"
echo "This will also install nginx web server and php (vnstat & bitcoin control gui)"
echo "!!!!!!!!! IF YOU ALREADY HAVE A WEB SERVER RUNNING DO NOT EXECUTE THIS SCRIPT !!!!!!!!"
echo "Hit return to continue or Ctrl+C to STOP"
read dummy_variable
echo "########### Let's update the system ...."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
echo "########### We're going to install everything that we need to get things right the first time"
sudo apt-get install automake libtool autoconf build-essential python-software-properties git make g++ python-leveldb libboost-all-dev libssl-dev libdb++-dev pkg-config libminiupnpc-dev -y
cd ~
sudo adduser bitcoin --disabled-password
sudo adduser litecoin --disabled-password

#Install Bitcoin
sudo su - bitcoin
mkdir ~/bin ~/src
echo "PATH="$HOME/bin:$PATH"" >> .bashrc
cd ~/src && wget https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux64.tar.gz
tar xfz bitcoin-0.11.0-linux64.tar.gz
cd bitcoin-0.11.0/bin
cp -a bitcoin-cli bitcoind bitcoin-qt bitcoin-tx ~/bin
cd ~/bin
mkdir ~/.bitcoin
config="/home/bitcoin/.bitcoin/bitcoin.conf"
touch $config
echo "server=1" > $config
echo "daemon=1" >> $config
echo "txindex=1" >> $config
echo "connections=20" >> $config
randUser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
randPass=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
echo "rpcuser=$randUser" >> $config
echo "rpcpassword=$randPass" >> $config
exit

#Install Litecoin
sudo su - litecoin
mkdir ~/bin ~/src
echo "PATH="$HOME/bin:$PATH"" >> .bashrc
cd ~/src && git clone https://github.com/litecoin-project/litecoin.git -b master-0.10
cd litecoin
./autogen.sh
./configure --disable-wallet --without-miniupnpc
make
strip src/litecoind src/litecoin-cli src/litecoin-tx
cp -a src/litecoind src/litecoin-cli src/litecoin-tx ~/bin
mkdir ~/.litecoin
config="/home/litecoin/.litecoin/litecoin.conf"
touch $config
echo "server=1" > $config
echo "daemon=1" >> $config
echo "txindex=1" >> $config
echo "disablewallet=1" >> $config
echo "connections=20" >> $config
randUser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
randPass=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
echo "rpcuser=$randUser" >> $config
echo "rpcpassword=$randPass" >> $config
exit

#Install nginx and php
sudo apt-get install nginx
sudo apt-get install php5 php-apc php5-fpm php5-curl php5-cgi php5-gd php-pear php5-mcrypt php5-sqlite php5-tidy php5-xmlrpc php5-xsl
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default-backup
sudo su
echo "cgi.fix_pathinfo=0" >> /etc/php5/fpm/php.ini
rm -rf /etc/nginx/sites-available/default
cd /etc/nginx/sites-available
wget https://raw.githubusercontent.com/tealcavalon/BTC_LTC_Nodes/master/default
exit
echo "YOU NEED TO MANUALLY EDIT /etc/nginx/sites-available/default and add your FQDN"
echo "Press return to continue!"
read dummy_variable
sudo service php5-fpm reload
sudo service nginx reload

#Install craigwatson - bitcoind-status
sudo su
cd /usr/share/nginx/html
git clone https://github.com/craigwatson/bitcoind-status.git
mv bitcoind-status btc_status
cd /usr/share/nginx/html/btc_status/php/
wget https://raw.githubusercontent.com/tealcavalon/BTC_LTC_Nodes/master/config_btc.php
mv config_btc.php config.php
echo "YOU NEED TO MANUALLY EDIT /usr/share/nginx/html/btc_status/php/config.php and add info from /home/bitcoin/.bitcoin/bitcoin.conf"
echo "Press return to continue!"
read dummy_variable

#Install craigwatson - litecoin-status
sudo su
cd /usr/share/nginx/html
git clone https://github.com/craigwatson/bitcoind-status.git
mv bitcoind-status ltc_status
cd /usr/share/nginx/html/ltc_status/php
wget https://raw.githubusercontent.com/tealcavalon/BTC_LTC_Nodes/master/config_ltc.php
mv config_ltc.php config.php
cd /usr/share/nginx/html/ltc_status/html
##This two lines doesn't work anymore due to changes in the PHP main files
##rm -rf template.html
##wget https://raw.githubusercontent.com/tealcavalon/BTC_LTC_Nodes/master/template.html
echo "YOU NEED TO MANUALLY EDIT /usr/share/nginx/html/ltc_status/php/config.php and add info from ~/.litecoin/litecoin.conf"
echo "Press return to continue!"
read dummy_variable
exit
#Let's make sure Nginx can access the files we have created
cd /usr/share/nginx
sudo chown www-data:www-data /usr/share/nginx/html -R

#NEXT ON THE LINE IS THE VNSTAT & FIREWALL RULES :-D

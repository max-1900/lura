#!/usr/bin/env bash
GrepDuo='/' #key dump
BotH='td'
DOVVB() {
local flag=false c count cr=$'\r' nl=$'\n'
while IFS='' read -d '' -rn 1 c; do
 if $flag; then
 printf '%c' "$c"
  else
if [[ $c != $cr && $c != $nl ]]; then
  count=0
 else
((count++))
 if ((count > 1)); then
flag=true
fi
fi
fi
 done
}
function c() {
echo -e "\e[107m                              Configing....                          \e[00;37;40m"

if [ -d "$HOME/$BotH" ];then
if [ ! -f ./tg ]; then
wget --progress=bar:force https://valtman.name/files/telegram-bot-180329-nightly-linux 2>&1 | DOVVB
mv telegram-bot-180329-nightly-linux tg; chmod +x tg

echo -e "\e[1m\e[97m==> TD successfully downloaded "
fi
if [ -d "$HOME/.telegram-bot" ];then
echo -e "\e[1m\e[32m==> \e[97m The file is correct.. Telegram-Bot\e[0m"
else
mkdir $HOME/.telegram-bot; cat <<EOF > $HOME/.telegram-bot/config
default_profile = "MCP";
MCP = {
lua_script = "$HOME/$BotH/bot.lua";
};
EOF
echo -e "\e[1m\e[32m==> \e[97m The file NotFound .. Telegram-Bot\e[0m"
fi
echo -e "\e[1m\e[32m==> \e[97m The file is correct.. $BotH\e[0m"
else
echo -e "\e[1m\e[97m==> Source not found!,"
fi
if [ "$CerNerCompany" = "g" ];then
echo -e "\e[1m\e[97m==> Please choose the right one"
else
read -p "==> Do you want to install Packages??[y/n] "  -t 10 CerNerCompany
echo -e "\e[0m"
fi
if [ "$CerNerCompany" = "y" ]
then
sudo apt-get update 
sudo apt-get upgrade
sudo apt-get install git redis-server lua5.2 liblua5.2-dev lua-lgi libnotify-dev unzip tmux -y && add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update 
sudo apt-get upgrade 
sudo do-release-upgrade
sudo apt-get install libconfig++9v5 libstdc++6 
sudo apt autoremove
sudo apt-get install gcc-4.9
sudo apt-get --yes install wget libconfig9 libjansson4 lua5.2 liblua5.2 make unzip git redis-server g++ whois fortune fortunes
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get install g++-4.7 -y c++-4.7 -y
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install libreadline-dev -y libconfig-dev -y libssl-dev -y lua5.2 -y liblua5.2-dev -y lua-socket -y lua-sec -y lua-expat -y libevent-dev -y make unzip git redis-server autoconf g++ -y libjansson-dev -y libpython-dev -y expat libexpat1-dev -y
sudo apt-get install screen -y
sudo apt-get install tmux -y
sudo apt-get install libstdc++6 -y
sudo apt-get install lua-lgi -y
sudo apt-get install libnotify-dev -y
echo -e "\e[1m\e[32m==> \e[97mInstall Packages completed\e[0m"

fi

}

botstart() {
  echo -e "\e[101m                              Launching....                          \e[00;37;40m"

  if [ -f ./tg ]; then
echo -e "\e[1m\e[32m==> \e[97m The file is correct.. Telegram-Bot[TG]\e[0m"
else
echo -e "\e[1m\e[32m==> \e[97m The file NotFound .. Telegram-Bot[TG]\e[0m"
printf "\33[1;31mError Exiting..!
\33[m"
exit 1
fi
echo -e "\e[1m\e[32m==> \e[97mGood Lock\e[0m"
./tg | grep -v '{"' 
echo -e "\e[1m\e[32m==> \e[97m Good bye\e[0m" 
}
function loginCLI() {
./tg -p MCP --login --phone=${1}
} 

function loginAPI() {
./tg -p MCP --login --bot=${1}
}
case $1 in
l)
echo -e "\e[1m\e[36m==> \e[31m $BotH is runing.. \e[0m"
botstart
exit;;
lc)
echo -e "\e[1m\e[32m==> \e[97mPlease enter your phone number without interruption\e[0m"
read Num_MPC
loginCLI ${Num_MPC}
echo -e "\e[1m\e[32m==> \e[97mLogin completed\e[0m"
exit;;

c)
c
exit;;
la)
echo -e "\e[1m\e[32m==> \e[97mPlease enter Token  without interruption\e[0m"
read BotAPI_TOKEN
loginAPI ${BotAPI_TOKEN}
echo -e "\e[1m\e[32m==> \e[97mLogin completed\e[0m"
exit;;
esac
exit 0

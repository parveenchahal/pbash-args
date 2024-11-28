wget -O /usr/bin/pbash-args.sh https://raw.githubusercontent.com/parveenchahal/pbash-args/refs/heads/main/pbash-args.sh
if [ "$?" == "0" ]
then
  sudo chmod +x /usr/bin/pbash-args.sh
fi

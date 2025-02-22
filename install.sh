touch /usr/bin/pbash-args.sh
curl -o /usr/bin/pbash-args.sh https://pbash.pcapis.com/args/pbash-args.sh
if [ "$?" == "0" ]
then
  chmod +x /usr/bin/pbash-args.sh
fi

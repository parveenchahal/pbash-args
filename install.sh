installation_type=$1
installation_path=""
[ "$installation_type" == "--system" ] && installation_path="/usr/local/bin/pbash-args.sh"
[ "$installation_type" == "--user" ] && installation_path="$HOME/.local/bin/pbash-args.sh"
if [ -z "$installation_type" ]
then
  echo "Installation type is not provided. Either --user or --system argument is required."
  exit 1
fi
curl -sL -o /usr/local/bin/pbash-args.sh https://pbash.pcapis.com/args/pbash-args.sh
if [ "$?" == "0" ]
then
  chmod +x /usr/local/bin/pbash-args.sh
fi

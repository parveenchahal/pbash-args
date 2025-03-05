installation_type=$1
installation_path=""
[ "$installation_type" == "--system" ] && installation_path="/usr/local/bin/pbash-args.sh"
[ "$installation_type" == "--user" ] && installation_path="$HOME/.local/bin/pbash-args.sh"
if [ "$installation_type" == "--user" ] && [ ! -d $HOME/.local/bin ]
then
  mkdir -p $HOME/.local/bin
fi
if [ -z "$installation_path" ]
then
  echo "Installation type is not provided. Either --user or --system argument is required."
  exit 1
fi
curl -sL -o "$installation_path" https://pbash.pcapis.com/args/pbash-args.sh
if [ "$?" == "0" ]
then
  chmod +x "$installation_path"
fi

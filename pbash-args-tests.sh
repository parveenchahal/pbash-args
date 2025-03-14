#!/usr/bin/env bash

source <(wget -q -O - https://pbash.pcapis.com/args/pbash-args.sh)

result=()

pbash.args.extract -l regex: -o result -- --regex "x y" --xyz abc && [ "${result[@]}" == "x y" ] || pbash.args.errors.echo "Test 1 failed"

pbash.args.extract -l regex: -o result --default-value "Hey man, it's default!" -d "2nd one :)" -- --xyz "x y" --abc 2 && [[ "${result[0]}" == "Hey man, it's default!" && "${result[1]}" == "2nd one :)" ]] || pbash.args.errors.echo "Test 2 failed"

pbash.args.is_switch_arg_enabled -l 'in-current-bash-session' -- a b c --in-current-bash-session || pbash.args.errors.echo "Test 3 failed"

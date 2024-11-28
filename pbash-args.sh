#!/bin/bash

function pbash.args.__updates.need_update {
  local x="$(wget -q -O - https://raw.githubusercontent.com/parveenchahal/pbash-args/refs/heads/main/pbash-args.sh | sha256sum | head -c 64)"
  local e="$(echo -n | sha256sum | head -c 64)"
  [[ "$x" == "$e" ]] && return 0
  
  local y="$(cat /usr/bin/pbash-args.sh | sha256sum | head -c 64)"
  
  [ "$x" == "$y" ] || return 1
  return 0
}

pbash.args.__updates.need_update || echo "WARNING: pbash-args.sh has a version available. Run 'wget -q -O - https://raw.githubusercontent.com/parveenchahal/pbash-args/refs/heads/main/install.sh | sudo bash'"

PBASH_ARGS_SUCCESS=0
PBASH_ARGS_ERROR=1
PBASH_ARGS_ERROR_USAGE=2
PBASH_ARGS_ERROR_NOT_FOUND=40

function pbash.args.errors.get_error_code() {
  local err="$?"
  [ "$1" == "" ] || err="$1"
  printf "%s" "$err"
}

function pbash.args.errors.echo() {
  local err="$?"
  echo -e "\e[01;31m${@}\e[0m"
  return $err
}

function pbash.args.errors.is_not_found_error() {
  local err="$(pbash.args.errors.get_error_code "$@")"
  [ "$err" == "$PBASH_ARGS_ERROR_NOT_FOUND" ] || return $PBASH_ARGS_ERROR
  return $PBASH_ARGS_SUCCESS
}

function pbash.args.errors.is_error() {
  local err="$(pbash.args.errors.get_error_code "$@")"
  [ "$err" != "$PBASH_ARGS_SUCCESS" ] || return $PBASH_ARGS_ERROR
  return $PBASH_ARGS_SUCCESS
}

function pbash.args.errors.is_success() {
  pbash.args.errors.is_error "$@" || return $PBASH_ARGS_SUCCESS
  return $PBASH_ARGS_ERROR
}

complete -W "-s --short -l --long -d --default-value -o --out-values-var -r --remaining-args-var" pbash.args.extract
function pbash.args.extract() {
  local _____SPLITED_ARGS1_____=()
  local _____SPLITED_ARGS2_____=()
  ___pbash_split_args_by_double_hyphen___ "$@" || return $PBASH_ARGS_ERROR_USAGE
  local internal_args=( "${_____SPLITED_ARGS1_____[@]}" )
  local external_args=( "${_____SPLITED_ARGS2_____[@]}" )

  local _____REPLY_____=()
  local _____REMAINING_ARGS_____=()

  ___pbash_extract_arg___ 'o:' 'out-values-var:' "${internal_args[@]}" && local -n out_values="$_____REPLY_____" || local out_values

  ___pbash_extract_arg___ 'r:' 'remaining-args-var:' "${internal_args[@]}" && local -n out_remaining_args="$_____REPLY_____" || local out_remaining_args

  out_values=()
  out_remaining_args=( "${external_args[@]}" )

  _____REPLY_____=()

  ___pbash_extract_arg___ 's:' 'short:' "${internal_args[@]}"
  local short_keys=( "${_____REPLY_____[@]}" )
  [ ${#short_keys[@]} -lt 2 ] || echo "Multiple short args can not be handled" || return $PBASH_ARGS_ERROR_USAGE

  ___pbash_extract_arg___ 'l:' 'long:' "${internal_args[@]}"
  local long_keys=( "${_____REPLY_____[@]}" )
  [ ${#long_keys[@]} -lt 2 ] || pbash.args.errors.echo "Multiple long args can not be handled" || return $PBASH_ARGS_ERROR_USAGE

  ___pbash_extract_arg___ 'd:' 'default-value:' "${internal_args[@]}"
  local default_value=( "${_____REPLY_____[@]}" )

  ___pbash_extract_arg___ "$short_keys" "$long_keys" "${external_args[@]}"
  local err=$?
  out_values=( "${_____REPLY_____[@]}" )
  out_remaining_args=( "${_____REMAINING_ARGS_____[@]}" )

  pbash.args.errors.is_not_found_error "$err" || return $err
  [ "${#default_value[@]}" != "0" ] || return $err

  out_values=( "${default_value[@]}" )
  return 0
}

complete -W "-s --short -l --long -o --out-values-var" pbash.args.delete
function pbash.args.delete() {
  local _____SPLITED_ARGS1_____=()
  local _____SPLITED_ARGS2_____=()
  ___pbash_split_args_by_double_hyphen___ "$@" || return $PBASH_ARGS_ERROR_USAGE
  local internal_args=( "${_____SPLITED_ARGS1_____[@]}" )
  local external_args=( "${_____SPLITED_ARGS2_____[@]}" )

  local pbash_args_delete_out_values_var_name=()
  pbash.args.extract -s 'o:' -l 'out-values-var:' -o pbash_args_delete_out_values_var_name -- "${internal_args[@]}"
  local err=$?
  pbash.args.errors.is_not_found_error $err && pbash.args.errors.echo "-o/--out-values-var is required arg"
  pbash.args.errors.is_error $err && return $err

  pbash.args.extract -r $pbash_args_delete_out_values_var_name "${internal_args[@]}" -- "${external_args[@]}"
  local err=$?
  pbash.args.errors.is_not_found_error $err || return $err
  return 0
}

complete -W "-s --short -l --long -r --remaining-args-var" pbash.args.is_switch_arg_enabled
function pbash.args.is_switch_arg_enabled() {
  local _____SPLITED_ARGS1_____=()
  local _____SPLITED_ARGS2_____=()
  ___pbash_split_args_by_double_hyphen___ "$@" || return $PBASH_ARGS_ERROR_USAGE
  local internal_args=( "${_____SPLITED_ARGS1_____[@]}" )
  local external_args=( "${_____SPLITED_ARGS2_____[@]}" )

  local pbash_args_is_switch_arg_enabled_remaining_args=()
  pbash.args.delete -s d -l default-value -o pbash_args_is_switch_arg_enabled_remaining_args -- "${internal_args[@]}"
  internal_args=( "${pbash_args_is_switch_arg_enabled_remaining_args[@]}" )
  internal_args+=( -d false )

  local pbash_args_is_switch_arg_enabled_short_args=()
  pbash.args.extract -s "s:" -l "short:" -o pbash_args_is_switch_arg_enabled_short_args -- "${internal_args[@]}"

  local pbash_args_is_switch_arg_enabled_long_args=()
  pbash.args.extract -s "l:" -l "long:" -o pbash_args_is_switch_arg_enabled_long_args -- "${internal_args[@]}"

  local all_args=()
  all_args+=( "${pbash_args_is_switch_arg_enabled_short_args[@]}" )
  all_args+=( "${pbash_args_is_switch_arg_enabled_long_args[@]}" )

  local k
  for k in "${all_args[@]}"
  do
    [[ ! "$k" =~ .*:$ ]] || pbash.args.errors.echo "pbash.args.is_switch_arg_enabled can't take value args." || return $PBASH_ARGS_ERROR_USAGE
  done

  local pbash_args_is_switch_arg_enabled_value=()
  pbash.args.extract -o pbash_args_is_switch_arg_enabled_value "${internal_args[@]}" -- "${external_args[@]}"
  local err=$?

  pbash.args.errors.is_success $err || return $err

  [ "$pbash_args_is_switch_arg_enabled_value" == "false" ] && return 1
  [ "$pbash_args_is_switch_arg_enabled_value" == "true" ] && return 0
  return 1
}

complete -W "-s --short -l --long " pbash.args.any_switch_arg_enabled
function pbash.args.any_switch_arg_enabled() {
  local _____SPLITED_ARGS1_____=()
  local _____SPLITED_ARGS2_____=()
  ___pbash_split_args_by_double_hyphen___ "$@" || return $PBASH_ARGS_ERROR_USAGE
  local internal_args=( "${_____SPLITED_ARGS1_____[@]}" )
  local external_args=( "${_____SPLITED_ARGS2_____[@]}" )

  local pbash_args_any_switch_arg_enabled_remaining_args=()
  pbash.args.delete -s d -l default-value -o pbash_args_any_switch_arg_enabled_remaining_args -- "${internal_args[@]}"
  internal_args=( "${pbash_args_any_switch_arg_enabled_remaining_args[@]}" )
  internal_args+=( -d false )
  
  # declaring to avoid modifying variable from parent function.
  local remaining_args=()

  local pbash_args_any_switch_arg_enabled_short_args=()
  pbash.args.extract -s "s:" -l "short:" -o pbash_args_any_switch_arg_enabled_short_args -- "${internal_args[@]}"

  local pbash_args_any_switch_arg_enabled_long_args=()
  pbash.args.extract -s "l:" -l "long:" -o pbash_args_any_switch_arg_enabled_long_args -- "${internal_args[@]}"

  local k
  for k in "${pbash_args_any_switch_arg_enabled_short_args[@]}"
  do
    pbash.args.is_switch_arg_enabled -s "$k" -- "${external_args[@]}" && return 0
  done
  
  for k in "${pbash_args_any_switch_arg_enabled_long_args[@]}"
  do
    pbash.args.is_switch_arg_enabled -l "$k" -- "${external_args[@]}" && return 0
  done
  return 1
}

complete -W "-s --short -l --long" pbash.args.atleast_one_arg_present
function pbash.args.atleast_one_arg_present() {
  local _____SPLITED_ARGS1_____=()
  local _____SPLITED_ARGS2_____=()
  ___pbash_split_args_by_double_hyphen___ "$@" || return $PBASH_ARGS_ERROR_USAGE
  local internal_args=( "${_____SPLITED_ARGS1_____[@]}" )
  local external_args=( "${_____SPLITED_ARGS2_____[@]}" )

  local short_args=()
  pbash.args.extract -s 's:' -l 'short:' -o short_args -- "${internal_args[@]}"
  local err=$?
  pbash.args.errors.is_success $err || pbash.args.errors.is_not_found_error $err || return $err

  local long_args=()
  pbash.args.extract -s 'l:' -l 'long:' -o long_args -- "${internal_args[@]}"
  local err=$?
  pbash.args.errors.is_success $err || pbash.args.errors.is_not_found_error $err || return $err

  local k
  for k in "${short_args[@]}"
  do
    pbash.args.extract -s "$k" -- "${external_args[@]}"
    err=$?
    pbash.args.errors.is_success $err && return $PBASH_ARGS_SUCCESS
    pbash.args.errors.is_not_found_error $err || return $err
  done

  for k in "${long_args[@]}"
  do
    pbash.args.extract -l "$k" -- "${external_args[@]}"
    err=$?
    pbash.args.errors.is_success $err && return $PBASH_ARGS_SUCCESS
    pbash.args.errors.is_not_found_error $err || return $err
  done
  return $PBASH_ARGS_ERROR
}

complete -W "-s --short -l --long" pbash.args.all_args_present
function pbash.args.all_args_present() {
  local _____SPLITED_ARGS1_____=()
  local _____SPLITED_ARGS2_____=()
    ___pbash_split_args_by_double_hyphen___ "$@" || return $PBASH_ARGS_ERROR_USAGE
  local internal_args=( "${_____SPLITED_ARGS1_____[@]}" )
  local external_args=( "${_____SPLITED_ARGS2_____[@]}" )

  local short_args=()
  pbash.args.extract -s 's:' -l 'short:' -o short_args -- "${internal_args[@]}"
  local err=$?
  pbash.args.errors.is_success $err || pbash.args.errors.is_not_found_error $err || return $err

  local long_args=()
  pbash.args.extract -s 'l:' -l 'long:' -o long_args -- "${internal_args[@]}"
  local err=$?
  pbash.args.errors.is_success $err || pbash.args.errors.is_not_found_error $err || return $err

  local k
  for k in "${short_args[@]}"
  do
    pbash.args.extract -s "$k" -- "${external_args[@]}"
    err=$?
    pbash.args.errors.is_success $err || return $err
  done

  for k in "${long_args[@]}"
  do
    pbash.args.extract -l "$k" -- "${external_args[@]}"
    err=$?
    pbash.args.errors.is_success $err || return $err
  done

  return $PBASH_ARGS_SUCCESS
}


#============================================================================
# Below functions should be used in this file only.

function ___pbash_split_args_by_double_hyphen___() {
  local -n args1='_____SPLITED_ARGS1_____'
  local -n args2='_____SPLITED_ARGS2_____'

  local found_split=0

  while [ $# -gt 0 ]
  do
    if [ "$1" == "--" ]
    then
      found_split=1
      shift
      break
    fi
    args1+=( "$1" )
    shift
  done
  if [ $found_split == 0 ]
  then
    args1=()
    args2=()
    return 1
  fi
  args2=( "${@}" )
}

function ___pbash_extract_arg___() {
  local short_key="$1"
  shift
  local long_key="$1"
  shift

  local -n remaining_args='_____REMAINING_ARGS_____'
  local -n reply='_____REPLY_____'

  remaining_args=( "$@" )
  reply=()

  [ "$short_key" != "" ] ||
  [ "$long_key" != "" ] ||
  pbash.args.errors.echo "At least one of either short or long option is required" || return $PBASH_ARGS_ERROR_USAGE

  local short_is_switch_arg=0
  [ "$short_key" != "" ] && [[ ! "$short_key" =~ .*:$ ]] && short_is_switch_arg=1
  short_key="${short_key%:}"

  local long_is_switch_arg=0
  [ "$long_key" != "" ] && [[ ! "$long_key" =~ .*:$ ]] && long_is_switch_arg=1
  long_key="${long_key%:}"

  [ "$short_key" == "" ] ||
  [ "$long_key" == "" ] ||
  [ "$short_is_switch_arg" == "$long_is_switch_arg" ] ||
  pbash.args.errors.echo "Short and long args should be of same type either switch or key/value." || return $PBASH_ARGS_ERROR_USAGE

  local is_switch_arg=0
  [[ "$short_is_switch_arg" == "1" || "$long_is_switch_arg" == "1" ]] && is_switch_arg=1

  remaining_args=()

  local found=0
  while [ "${#@}" != "0" ] ; do
    if [[ "$1" == "--" || "$1" == "-" ]]
    then
      shift
      continue
    fi
    case "$1" in
      --$long_key|-$short_key)
          found=1 ;
          [ "$is_switch_arg" == "1" ] && reply+=( "true" ) ;
          [ "$is_switch_arg" == "0" ] && [[ ! "$2" =~ ^-.* ]] && reply+=( "$2" ) && shift ;
          ;;
      --$long_key=*)
          found=1 ;
          local val="${1#"--$long_key="}" ;
          [ "$is_switch_arg" == "0" ] ||
          [[ "$val" == "true" || "$val" == "false" ]] ||
          pbash.args.errors.echo "Invalid valid for --$long_key. Expected true or false." ||
          return $PBASH_ARGS_ERROR_USAGE ;

          reply+=( "$val" ) ;
          ;;
      -$short_key=*)
          found=1 ;
          local val="${1#"-$short_key="}" ;
          [ "$is_switch_arg" == "0" ] ||
          [[ "$val" == "true" || "$val" == "false" ]] ||
          pbash.args.errors.echo "Invalid valid for -$short_key. Expected true or false." ||
          return $PBASH_ARGS_ERROR_USAGE;

          reply+=( "$val" ) ;
          ;;
      *)
          remaining_args+=( "$1" );;
    esac
    shift
  done

  if [ "$found" == 0 ]
  then
    reply=()
    return $PBASH_ARGS_ERROR_NOT_FOUND
  fi
  return 0
}

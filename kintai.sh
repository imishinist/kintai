#!/bin/bash

set -e
dir=$(cd $(dirname $0)/../; pwd)
cd $dir

database="$HOME/.kintai"

usage() {
  echo "Usage: $PROGNAME [OPTIONS] action[in|out|show|status]"
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "  --database      database directory [default: $database]"
  exit 1
}


for OPT in "$@"
do
  case $OPT in
    -h | --help)
      usage
      ;;
    --database)
      database=$1
      shift 2
      ;;
    -*)
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
      ;;
  esac
done

action=$1
datafile="${database}/main.tsv"
mkdir -p $database
touch $datafile
[ -z "$action" ] && usage

[[ "$action" == "show" ]] && cat $datafile && exit
[[ "$action" == "status" ]] && tail -1 $datafile && exit
[[ "$action" != "in" && "$action" != "out" ]] && usage


result=$(tail -1 $datafile | egrep "^$action" || :)
if [ -n "$result" ]; then
    echo "error: last action is $action"
    exit
fi

now=$(date "+%Y-%m-%dT%H:%M:%S")
echo -e "${action}\t${now}" >> $datafile
echo "${action}: ${now}"

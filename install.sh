#!/bin/bash
source ./color.cfg
# source ./config.cfg

function  _msg_help() {
  printf "$BWhite[OPTIONS]$ResetCl\n"
  printf "Command usage) $BWhite$0 $ResetCl $UWhite-m(--mode=)$ResetCl [s|i|d] $UWhite<Config file name>$ResetCl\n\n"

  printf "$Green-m, --mode [s|i|d]$ResetCl\n"
  printf "  ${UWhite}s$ResetCl : Inital mode.\n"
  printf "  ${UWhite}i$ResetCl : Install mode.\n"
  printf "  ${UWhite}d$ResetCl : Delete mode.\n"
  printf "$Green-c, --config [File]$ResetCl\n"
  printf "  ${UWhite}File$ResetCl : Config file name\n"
}
function _msg_info() { printf "\n$IGreen[Info]$ResetCl $1\n" >&2 ; }
function _msg_err() { printf "\n$IRed[Error]$ResetCl $1\n" >&2 ; exit 1 ; }
function _msg_warr() { printf "\n$ICyan[Warring]$ResetCl $1\n" >&2 ; }
function _msg_logcmd() { 
  case $1 in
    m) printf "[CMD]: $Green$2$ResetCl\n" ;;
    o) printf "L----> Success!!\n" ;;
    x) printf "L----> Failed!!\n" >&2 ; exit 1 ;;
  esac
}

function _run_cmd() {
  _msg_logcmd "m" "$@"
  eval $@ >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    _msg_logcmd "o" "$@"
  else
    _msg_logcmd "x" "$@"  
  fi
}

function _setting() {
  _msg_info "inital mode start"

  if [ ! -d ${App_path} ]; then _run_cmd "mkdir $App_path" ; fi 

  _run_cmd "wget https://dl.influxdata.com/influxdb/releases/influxdb2-$Influxdb_version-linux-amd64.tar.gz -P $Influxdb_path"
  _run_cmd "tar -zxf $Influxdb_path/influxdb2-$Influxdb_version-linux-amd64.tar.gz -C $Influxdb_path/."

  _run_cmd "wget https://dl.influxdata.com/telegraf/releases/telegraf-${Telegraf_version}_linux_amd64.tar.gz  -P $Telegraf_path"
  _run_cmd "tar -zxf $Telegraf_path/telegraf-${Telegraf_version}_linux_amd64.tar.gz -C $Telegraf_path/."

  _run_cmd "wget https://dl.grafana.com/oss/release/grafana-$Grafana_version.linux-amd64.tar.gz -P $Grafana_path"
  _run_cmd "tar -zxf $Grafana_path/grafana-$Grafana_version.linux-amd64.tar.gz -C $Grafana_path/."
}


function _mode() {
  if [ $# -eq 1 ]; then
    case "$1" in
      Setting)
        _setting
      ;;

      Install)
        _msg_info "install mode start"
        # _run_cmd "wget https://dl.influxdata.com/influxdb/releases/influxdb2-$Influxdb_version-linux-amd64.tar.gz -P $Influxdb_path"
        # _run_cmd "tar -zxf $Influxdb_path/influxdb2-$Influxdb_version-linux-amd64.tar.gz -C $Influxdb_path/."

        # _run_cmd "wget https://dl.influxdata.com/telegraf/releases/telegraf-${Telegraf_version}_linux_amd64.tar.gz  -P $Telegraf_path"
        # _run_cmd "tar -zxf $Telegraf_path/telegraf-${Telegraf_version}_linux_amd64.tar.gz -C $Telegraf_path/."

        # _run_cmd "wget https://dl.grafana.com/oss/release/grafana-$Grafana_version.linux-amd64.tar.gz -P $Grafana_path"
        # _run_cmd "tar -zxf $Grafana_path/grafana-$Grafana_version.linux-amd64.tar.gz -C $Grafana_path/."        
      ;;

      Delete)
        _msg_info "delete mode start"
        while true; do
          printf "\n$ICyan[Warring]$ResetCl $App_path remove? [y|n] "
          read answer
          case $answer in
            y|yes|Y|YES|Yes) _run_cmd "rm -rf $App_path" ; break ;;
            n|no|N|NO|No) _msg_info "stop script" ; exit 0 ;;
            *) _msg_warr "Please check answoer." ;;
          esac
        done
      ;;

    esac
  else _msg_err "No input argument or Internal error";
  fi
}

function _select_options(){
  # SHORT=:m:f:s:h
  Short=:m:
  # LONG=mode:,file:,save:,help
  Long=mode:
  Opts=$(getopt --options $Short --long $Long --name "$0" -- "$@")

  if [ $? != 0 ]; then _msg_help; _msg_err "no parse opion." >&2 ; exit 1 ; fi
  eval set -- "$Opts"
  
  while true; do
    case "$1" in
      # -h|--help) echo _msg_help ;;
      -h|--help) _msg_help ;;
      -m|--mode)
        case "$2" in
          i) Mode="Install"; shift 2 ;;
          s) Mode="Setting"; shift 2 ;;
          d) Mode="Delete"; shift 2 ;;
          *) _msg_err "-m, --mode invalid arguemnt." ;;
        esac
      ;;

      -c|--config)
        FILE_NAME=$2
        if [ -n $FILE_NAME ]; then _msg_err "-c, --config invalid config file name" ; fi
      ;;

      --) shift; break ;;
      *) _msg_err "Internal error" ;;
    esac
  done

  shift $(( OPTIND - 1 ))
  FILE_NAME="$@"
  
  if [ -z $FILE_NAME ] ; then
    _msg_warr "No Config file argment ... default load filename [ config.cfg ]"
    source ./config.cfg
  else
    source $FILE_NAME
  fi

  #전달 받은 arg를 토대로 mode를 실행
  _mode $Mode
}

main () {
  #getopt parsing 전 arg 확인
  if [ $# -gt 0 ]; then
    printf "$IWhite[Grafana script. v1)2022-10-21]$ResetCl" 
    _select_options $@
  else
    _msg_help
    _msg_err "Please check usage."
  fi
}
main $*
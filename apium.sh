if [ ! "$COMMON_SOURCED" == true ]
then
  echo >&2 "apium:" "missing common code"
  exit 1
fi

function argParse()
{
  if [ $# -eq 0 ]
  then
    set -- "help"
  fi

  while [[ "$1" == "-"* ]]
  do
    if ! matchArg "$1"
    then
      fatal "$1:" "unknown argument"
    fi
    shift
  done

  if matchExt "$1"
  then
    shift
    while [ $# -ne 0 ]
    do
      if [[ "$1" == "-"* ]] && matchArg "$1"
      then
        shift
        continue
      fi
      addTarget "$1"
      shift
    done
  elif [[ "$1" == "-"* ]]
  then
    if ! matchArg "$1"
    then
      fatal "$1:" "unknown argument"
    fi
  fi

  if [ ${#fnTargets[@]} -gt 0 ] && [ ! "$takeTargets" == true ]
  then
    fatal "$ext:" "${fnTargets[@]}:" "does not take any targets"
  fi

  if [ "$targetOpt" == false ] && [ "$takeTargets" == true ] && [ ${#fnTargets[@]} -eq 0 ]
  then
    fatal "$ext:" "must provide at least one target"
  fi

  if [ -z "$ext" ]
  then
    fatal "must provide at least one operation (try '$sysName help')"
  fi
}

function main()
{
  if [ -z "$APIUM_ROOT" ]
  then
    case $EUID in
      0)
        if [ -f "/etc/apium.d/root.conf" ]
        then
          confDir="/etc/apium.d"
        fi
        cacheDir="/var/cache/apium"
        . /etc/apium.d/root.conf
        ;;
      *)
        if [ -f "$HOME/.config/apium/root.conf" ]
        then
          confDir="$HOME/.config/apium"
        fi
        cacheDir="$HOME/.cache/apium"
        ;;
    esac

    if [ ! "$FAKE_ROOT" == true ]
    then
      . "$confDir/root.conf"
    fi
  fi

  if [ "$FAKE_ROOT" == true ]
  then
    confDir="/etc/apium.d"
    . "$confDir/root.conf"
  fi

  mkdir -pm0755 "$cacheDir"

  if [ ! -d "$cacheDir" ]
  then
    fatal "$cacheDir:" "cannot access cache directory"
  fi

  if [ ! -d "$APIUM_ROOT" ]
  then
    if [ ! "$FAKE_ROOT" == true ]
    then
      mkdir "$APIUM_ROOT"
    fi
    warn "failed to locate apium root"
  fi

  if ! ls &>/dev/null -d "$APIUM_ROOT/.appdata/"*"/meta"
  then
    APP_TOTAL=0
  else
    APP_TOTAL=$(ls -1 -d "$APIUM_ROOT/.appdata/"*"/meta" | wc -l)
  fi
}

argParse "$@"
main

if [ "$VERBOSE" == true ]
then
  debugStd=/dev/stdout
  function debug()
  {
    echo >&2 "$sysName:" "$@"
  }
else
  debugStd=/dev/null
  function debug()
  {
    return $?
  }
fi

eval "${extExec[$ext]}" "${fnTargets[@]}"
exit 0


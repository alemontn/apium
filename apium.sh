if [ ! "$COMMON_SOURCED" == true ]
then
  echo >&2 "apium:" "missing common code"
  exit 1
fi

function main()
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
    if [ "$takeTargets" == true ]
    then
      while [ $# -ne 0 ]
      do
        if [[ "$1" == "-"* ]]
        then
          matchArg "$1" && continue || true
        fi
        addTarget "$1"
        shift
      done
    fi
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
main "$@"

if [ "$VERBOSE" == true ]
then
  function debug()
  {
    echo >&2 "$sysName:" "$@"
  }
else
  function debug()
  {
    return 0
  }
fi

if [ "$FAKE_ROOT" == true ]
then
  . "/etc/apium.d/root.conf"
fi

eval "${extExec[$ext]}" "${fnTargets[@]}"
exit 0


#
# enable.sh - control for enabling & disabling apps
#

extmeta "enable" "enable apps" "targets-opt"
extmeta "disable" "disable apps" "targets-opt"

function enable()
{
  if [ $# -eq 0 ]
  then
    for app in "$APIUM_ROOT"/*
    do
      appname="${app##*'/'}"

      if [ ! -f "$APIUM_ROOT/.appdata/$target/disabled" ]
      then
        echo "$appname"
      fi
    done
  fi

  for target in "$@"
  do
    appSource "$target"

    if [ -f "$APIUM_ROOT/.appdata/$target/disabled" ]
    then
      rm -f "$APIUM_ROOT/.appdata/$target/disabled"
    elif [ ! -f "$APIUM_ROOT/.appdata/$target/meta" ]
    then
      fatal "$target:" "app isn't installed"
    else
      fatal "$target:" "app isn't disabled"
    fi
  done
}

function disable()
{
  for target in "$@"
  do
    appSource "$target"

    touch "$APIUM_ROOT/.appdata/$target/disabled"
  done
}

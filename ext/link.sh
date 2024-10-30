#
# link.sh - interface for symlinking files to root
#

function rmlink()
{
  if [ $# -eq 0 ]
  then
    fatal "no app specified to unlink"
  fi

  appname="$1"

  cd "$APIUM_ROOT/$appname"

  for file in "$(<"$APIUM_ROOT/.appdata/$appname/links")"
  do
    rm -f "$file"
    sed -i "s|$file||" "$APIUM_ROOT/.appdata/$appname/links"
  done

  if [ -n "$(<$APIUM_ROOT/.appdata/$appname/links)" ]
  then
    fatal "$appname:" "failed to remove all symlinks"
  else
    rm -f "$APIUM_ROOT/.appdata/$appname/links"
  fi
}

function mklink()
{
  if [ -d "$confDir" ]
  then
    . "$confDir/dirs.conf" || fatal "failed to source directory config"
  else
    fatal "failed to find diretory config"
  fi

  # link all apps
  if [ $# -eq 0 ]
  then
    for target in "$APIUM_ROOT/"*
    do
      appname="${target##*'/'}"
      set -- "$@" "$appname"
    done
  fi

  for target in "$@"
  do
    while read from
    do
      to="${from#"$APIUM_ROOT/$target/"}"

      case "${to%%'/'*}" in
        "usr")
          # strip usr
          to="${to#"usr/"}"
          ;;
      esac

      case "${to%%'/'*}" in
        "bin")
          dirTo="$bin"
          ;;
        "sbin")
          dirTo="$sbin"
          ;;
        "lib")
          dirTo="$lib"
          ;;
        "etc")
          dirTo="$etc"
          ;;
        "share")
          dirTo="$share"
          ;;
        "var")
          dirTo="$var"
          ;;
        *)
          fatal "$from:" "cannot make symlink:" "failed to find directory type"
          ;;
      esac

      # strip the directory we just matched
      to="${to#*'/'}"

      # can't create symlink twice
      if [ "$UPDATE_APP" == true ] && [ -L "$dirTo/$to" ]
      then
        continue
      fi

      if [ ! -d "$(dirname "$dirTo/$to")" ]
      then
        mkdir -p "$(dirname "$dirTo/$to")"
      fi

      ln -s "$from" "$dirTo/$to" || fatal "$dirTo/$to:" "failed to make symlink"

      echo "$dirTo/$to" >>"$APIUM_ROOT/.appdata/$target/links"
    done \
      <<<"$(find "$APIUM_ROOT/$target" -type f)"
  done
}

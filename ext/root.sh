#
# root.sh - determine & setup the root directory to install to
#

function setupRoot()
{
  if [ ! -w "$APIUM_ROOT" ]
  then
    fatal "$APIUM_ROOT:" "cannot write to apium root path"
  fi

  cd "$APIUM_ROOT"

  mkdir -p "./.appdata"

  cd "$OLDPWD"
}

if [ -z "$APIUM_ROOT" ]
then
  case $EUID in
    0)
      if [ -f "/etc/apium.d/root.conf" ]
      then
        confDir="/etc/apium.d"
      fi
      . /etc/apium.d/root.conf
      ;;
    *)
      if [ -f "$HOME/.config/apium/root.conf" ]
      then
        confDir="$HOME/.config/apium"
      fi
      ;;
  esac
  . "$confDir/root.conf"
fi

if [ ! -d "$APIUM_ROOT" ]
then
  mkdir "$APIUM_ROOT" || warn "failed to locate apium root"
fi

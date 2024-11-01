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

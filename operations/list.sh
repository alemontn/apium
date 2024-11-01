#
# list.sh - list package(s) and package info
#

extmeta "list" "list apps" "targets-opt"

function list()
{
  if [ $APP_TOTAL -eq 0 ]
  then
    return 0
  fi

  for app in "$APIUM_ROOT"/.appdata/*/meta
  do
    appname="${app#"$APIUM_ROOT/.appdata/"}" appname="${appname%"/meta"}"

    . "$APIUM_ROOT/.appdata/$appname/meta"

    echo "$appname $version $arch"
  done
}

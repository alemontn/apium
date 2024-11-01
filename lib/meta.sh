#
# meta.sh - source meta config from stdin
#

function appSource()
{
  if [ -f "$APIUM_ROOT/.appdata/$1/meta" ]
  then
    . "$APIUM_ROOT/.appdata/$1/meta"
  else
    fatal "$1:" "app is not installed"
  fi
  metaCheck
}

function metaCheck()
{
  vars=("name" "version" "description" "arch" "depends" "license" "maintainer")

  # check required variables have been sourced
  for required in "$name" "$version" "$description" "$arch" "${depends[@]}" "$license" "$maintainer"
  do
    if [ -z "$required" ]
    then
      fatal "meta:" "${vars[@]::1}:" "required variable is missing, cannot continue"
    fi
    unset 'vars[0]'
  done
}

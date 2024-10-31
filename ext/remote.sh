#
# remote.sh - interface for downloading/updating apps
#

# the main array for the remote
declare -A pkgrelease

extmeta "remote-list" "list installed remotes" "notargets" "remoteList"
extmeta "remote-update" "refresh remotes" "notargets" "remoteUpdate"

function remoteSource()
{
  # strip to just filename, and remove '.conf'
  id="${remote##*'/'}" id="${id%'.conf'}"
  baseurl="$(<$remote)"

  if [[ ! "$baseurl" == *"://"*"."*"/"* ]]
  then
    fatal "$remote:" "$baseurl:" "provided url is not valid"
  fi

  if [ -n "${id//[a-zA-Z0-9]}" ]
  then
    fatal "$remote:" "$id:" "cannot contain non-alphanumeric characters"
  fi
}

function remoteList()
{
  for remote in "${remotes[@]}"
  do
    remoteSource

    echo $bold"$id"$none ": $baseurl"
  done
}

function remoteUpdate()
{
  echo "Updating remotes..."

  queueTotal=${#remotes[@]}

  for remote in "${remotes[@]}"
  do
    remoteSource

    content="$(curl -Lso- "$baseurl/apium.remote" || fatal "$id" "failed to download remote")"

    if ! ( eval "$content" && [ -n "$id" ] && [ -n "$baseurl" ] ) &>"$debugStd"
    then
      fatal "$id:" "saved remote file is invalid"
    fi

    if [ -f "$cacheDir/$id.remote" ] && [ "$(<$cacheDir/$id.remote)" == "$content" ]
    then
      remoteLatest=true
    fi

    if [ "$remoteLatest" == true ]
    then
      echo "$id:" "remote is up-to-date"
    fi

    # save it!
    echo "$content" >"$cacheDir/$id.remote"

    queue "Updated" "$id"

    unset id \
          baseurl \
          content
  done
}

# find available remotes
for remoteDir in "$confDir" /etc/apium.d
do
  if [ -d "$remoteDir/remote.d" ] && ls &>/dev/null -d "$remoteDir/remote.d/"*.conf
  then
    remotes+=("$remoteDir/remote.d/"*.conf)
  else
    continue
  fi
done

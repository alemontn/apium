#
# install.sh - install a package to root
#

extmeta "install" "install an app" "targets" "addPkg"
extmeta "update" "update apps" "targets-opt" "updatePkg"
extmeta "uninstall" "uninstall an app" "targets" "uninstallPkg"

function installApp()
{
  if [ ! "$UPDATE_APP" == true ]
  then
    if appExists "$1"
    then
      fatal "$1:" "app is already installed"
    elif appExistsGlobal "$1"
    then
      warn "$1:" "app is installed as root"
    fi
  fi

  queue "Verifying" "$1"

  # check integrity
  if [ ! "$(head -c3 "$1")" == "apm" ] || ! tail -c+4 "$1" | unzstd | tar -t >/dev/null
  then
    fatal "$1:" "input package is corrupted"
  fi

  # source metadata
  eval "$(tail -c+4 "$1" | unzstd | tar -xO "./.apm/meta")"
  metaCheck

  if [ "$UPDATE_APP" == true ] && ! appExists "$name"
  then
    fatal "$name:" "cannot update app since it isn't installed"
  fi

  if [ "$UPDATE_APP" == true ]
  then
    queue "Updating" "$name"
  else
    queue "Adding" "$name"

    mkdir "$APIUM_ROOT/$name"
  fi

  cd "$APIUM_ROOT/.appdata"

  # extract everything provided by apium to appdata
  tail -c+4 "$1" | unzstd | tar --wildcards \
                                --exclude="./.apm/script*.sh" \
                                -x "./.apm/"

  if [ "$UPDATE_APP" == true ] && [ -d "$name" ]
  then
    rm -rf "$name"
  fi

  mv "./.apm/" "$name"

  if [ ! "$UPDATE_APP" == true ]
  then
    queue "Installing" "$name"
  fi

  cd "$APIUM_ROOT/$name"

  if [ "$GNU_TAR" == true ]
  then
    tail -c+4 "$1" | unzstd | tar --wildcards --exclude='./.apm/*' -x
    rmdir "$APIUM_ROOT/$name/.apm/"
  else
    # we can't be sure whether this tar supports
    # `exclude` since it isn't GNU
    tail -c+4 "$1" | unzstd | tar -x
    rm -rf "$APIUM_ROOT/$name/.apm/"
  fi

  mklink "$name"
}

function updatePkg()
{
  setupRoot

  if [ $# -eq 0 ]
  then
    unset targets

    if [ $APP_TOTAL -eq 0 ]
    then
      fatal "no apps are available to update"
    fi

    for appname in "$APIUM_ROOT/.appdata/"*"/meta"
    do
      appname="${appname%'/meta'}" appname="${appname##*'/'}"

      targets+=("$appname")
    done
  else
    targets=($@)
    queueTotal=$#
  fi

  for target in "${targets[@]}"
  do
    if appExists "$target"
    then
      updateApp "$target"
    elif [ -f "$target" ] && validPkg "$target"
    then
      UPDATE_APP=true installApp "$target"
    else
      fatal "$target:" "target does not match an installed app or package"
    fi
  done
}

function updateApp()
{
  appname="$1"

  if [ ! "$REMOTE_UPDATED" == true ]
  then
    remoteUpdate
  fi

  if ! appExists "$1"
  then
    fatal "$appname:" "cannot update app as it is not installed"
  fi

  if [ ! -f "$cacheDir/$appname.remote" ]
  then
    fatal "$appname:" "app does not have a remote - you must update it manually"
  fi

  # source the remote
  . "$cacheDir/$appname.remote"
  # source app meta
  appSource "$appname"

  if [ -z "$latest" ]
  then
    # assume last version is latest
    latest="${versions[@]: -1}"
  fi

  if [ -z "${pkgrelease[$latest]}" ]
  then
    fatal "$latest:" "specified latest version is not available"
  fi

  if [ "$latest" == "$version" ]
  then
    echo "$name:" "app is up-to-date"
  else
    makeTmp "$name-update-$latest"
    # save our package
    curl -Lso "$tmpfile" "${pkgrelease[$latest]}"
    UPDATE_APP=true installApp "$tmpfile"
  fi

  unset pkgrelease \
        versions \
        latest
}

function uninstallApp()
{
  appname="$1"

  # source metadata
  . "$APIUM_ROOT/.appdata/$appname/meta"

  # remove our symlinks
  rmlink "$appname"

  # remove apium data
  rm -rf "$APIUM_ROOT/.appdata/$appname"
  # remove the actual app
  rm -rf "$APIUM_ROOT/$appname"
}

function uninstallPkg()
{
  for target in "$@"
  do
    uninstallApp "$target"
  done
}

function addPkg()
{
  setupRoot

  queueTotal=$#

  ask "Installing $queueTotal new app(s), continue?"

  for target in "$@"
  do
    installApp "$target"
  done
}

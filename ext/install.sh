#
# install.sh - install a package to root
#

extmeta "install" "install an app" "targets" "addPkg"
extmeta "update" "update apps" "targets" "updatePkg"
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

  queueTotal=$#

  for target in "$@"
  do
    UPDATE_APP=true installApp "$target"
  done
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

  for target in "$@"
  do
    installApp "$target"
  done
}

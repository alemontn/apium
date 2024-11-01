#
# create.sh - make an apium package
#

extmeta "package" "create a new package" "notargets" "mkpkg"

function mkpkg()
{
  function _paths()
  {
    while read line
    do
      # directory only
      if [ "${line: -1}" == / ]
      then
        mkdir -p "$line"
        continue
      fi

      # get filename from before '->'
      from="${line%%" -> "*}"
      owner="${line##*" "}" line="${line%" "*}"
      perm="${line##*" "}" line="${line%" "*}"
      to="${line##"$from -> "}"

      if [ "${from::1}" == / ]
      then
        copy="$from"
      else
        copy="$src/$from"
      fi

      # make sure directory where file is located exists
      if [ ! -d "${to%'/'*}" ]
      then
        mkdir -p "${to%'/'*}"
      fi

      case "$owner" in
        "root"|"root:root")
          sudoEsculate

          if [[ ! "$copy" == *"/" ]]
          then
            cat "$copy" >"$to"
          else
            cp -r "$copy" "$to"
          fi

          sudo chown -R "$owner" "$to"
          sudo chmod -R "$perm" "$to"
          ;;
        *)
          if [ ! -d "$copy" ]
          then
            cat "$copy" >"$to"
          else
            cp -r "$copy" "$to"
          fi

          chown -R "$owner" "$to"
          chmod -R "$perm" "$to"
          ;;
      esac
    done
  }

  src="$PWD"/..

  if [ ! -f "./apm/meta" ]
  then
    fatal "missing metadata file"
  fi

  # source package metadata
  . "./apm/meta"
  metaCheck

  build=".build-$name-$version-$(date +%s)"
  mkdir "$build"
  cd "$build"

  # add current directory to cleanups
  CLEAN+=("$PWD")

  cp -r "../apm" ".apm"

  if [ -f "./.apm/paths" ]
  then
    _paths <"./.apm/paths"
  else
    warn "paths:" "skipping paths"
  fi

  if ls &>/dev/null -d "./.apm/script"*.sh
  then
    for script in "./.apm/script"*.sh
    do
      if ! grep -q "^scriptDesc=" "$script"
      then
        fatal "$script:" "script is invalid:" "missing 'scriptDesc' variable"
      else
        headnum="$(grep -n "scriptDesc=" "$script" | cut -d':' -f1)"
      fi
  
      eval "$(head -n$headnum "$script")"
  
      echo "executing ${script##*'/'}: $scriptDesc"
      . "$script"
    done
  fi

  # GNU tar is prefered because it has the '-H' (format) option,
  # BUT others (like busybox) are supported
  if [ "$GNU_TAR" == true ]
  then
    tarOpts="-H ustar"
  fi

  if [ ! -d "../out" ]
  then
    mkdir ../out
  fi

  # create & compress it
  (
    echo -n "apm"
    tar $tarOpts -c . | zstd
  ) \
   >"../out/$name-$version-$arch.apm"

  echo "generated package $name-$version-$arch"
}

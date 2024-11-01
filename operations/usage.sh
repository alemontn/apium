extmeta "help" "print this help prompt" "notargets" "usage"

function usage()
{
  declare -i maxSpace=0 \
             argMaxSpace=0

  function _spacer()
  {
    declare -i spaces=$1

    while [ $spaces -lt $maxSpace ]
    do
      echo -n " "
      spaces+=1
    done
  }

  for ext in "${exts[@]}"
  do
    ext
    prevCount=$count
    count=${#ext}

    if [ $count -gt $maxSpace ]
    then
      maxSpace=$count
    fi
  done

  for arg in "${args[@]}"
  do
    prevCount=$count
    count=${#arg}

    if [ $count -gt $argMaxSpace ]
    then
      argMaxSpace=$count
    fi
  done

  echo "Usage: $sysName [ARGUMENTs] <OPERATION>"
  echo "a containerised app manager"
  echo
  echo "Operations:"

  for ext in "${exts[@]}"
  do
    ext
    echo " $ext $(_spacer ${#ext}) $help"
  done

  echo
  echo "Arguments:"

  for arg in "${args[@]}"
  do
    sarg="${shortArgs[$arg]}"
    larg="${longArgs[$arg]}"
    help="${argsHelp[$arg]}"

    if [ -z "$sarg" ]
    then
      echo "     $larg $(_spacer ${#larg}) $help"
    else
      echo " $sarg, $larg $(_spacer $((${#larg}+${#sarg}))) $help"
    fi
  done

  echo
}

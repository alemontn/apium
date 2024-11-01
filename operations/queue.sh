#
# queue.sh - interface to queue packages to install, uninstall, etc..
#

declare -A queueCurrent

function queue()
{
  action="$1"
  info="$2"
  queueCurrent["$action"]=$((${queueCurrent[$action]}+1))

  echo "(${queueCurrent[$action]}/$queueTotal) $action: $info "
}

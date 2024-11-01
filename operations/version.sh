#
# version.sh - print apium's version
#

extmeta "version" "show apium version" "notargets"

function version()
{
  # get the / directory for the root user
  . "/etc/apium.d/root.conf"

  appSource "apium"

  echo $bold"apium"$none "version $version"
  exit 0
}

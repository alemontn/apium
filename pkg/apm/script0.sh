
scriptDesc="make the apium executable"

cat "$src"/head.in "$src"/common.sh.in "$src"/args.in "$src"/lib/*.sh "$src"/operations/*.sh "$src"/apium.sh | sudo tee usr/bin/apium > /dev/null

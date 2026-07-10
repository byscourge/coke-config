#!/bin/sh

mimetype="$(file --mime-type -Lb "$1")"

case "$mimetype" in
  image/*)
    chafa "$1"
    exit 0
    ;;
esac

exit 1

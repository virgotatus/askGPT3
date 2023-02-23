#!/bin/bash

case "$1" in
    "")
        echo -n "please provide a parameter (start, stop, reload)."
        ;;
    start)
        echo -n "starting puma..."
        puma
        ;;
    stop)
        echo "stoping puma..."
        kill `cat "tmp/pids/puma.pid"`
        ;;
    reload)
        echo "reloading puma..."
        kill `cat "tmp/pids/puma.pid"`
        puma
        ;;
esac

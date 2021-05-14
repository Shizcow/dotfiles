#!/bin/bash

s=$(date +@%s)
d=$(date -d $s +%e)

case $d in
    1?) d=${d}th ;;
    *1) d=${d}st ;;
    *2) d=${d}nd ;;
    *3) d=${d}rd ;;
    *)  d=${d}th ;;
esac

date -d $s "+%a %b(%m) $d %T"

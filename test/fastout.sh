#!/bin/sh
set -e

cc -o fastout fastout.c

socat -d -d tcp-l:25232,fork,reuseaddr system:"./fastout"

#!/bin/sh
set -e

cc -o slowout slowout.c

socat -d -d tcp-l:25232,fork,reuseaddr system:"./slowout"

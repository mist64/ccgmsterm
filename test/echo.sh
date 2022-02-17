#!/bin/sh
set -e

cc -o echo echo.c

socat -d -d tcp-l:25232,fork,reuseaddr system:"./echo"

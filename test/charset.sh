#!/bin/sh
set -e

cc -o charset charset.c

socat -d -d tcp-l:25232,fork,reuseaddr system:"./charset"

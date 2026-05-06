#!/bin/sh
echo "============================================"
echo "Hello from inside the container."
echo "  hostname : $(hostname)"
echo "  date     : $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  os       : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
echo "  whoami   : $(whoami)"
echo "  args     : $*"
echo "============================================"

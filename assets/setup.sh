#!/bin/bash
set -e

echo "setup is finished"
source /opt/ros/humble/setup.bash
source ~/.bashrc
exec "$@"

#!/usr/bin/env bash
if [ -f /opt/ros/humble/setup.bash ]; then
  source /opt/ros/humble/setup.bash
elif [ -f /opt/ros/jazzy/setup.bash ]; then
  source /opt/ros/jazzy/setup.bash
else
  echo "ROS 2 not found under /opt/ros" >&2
  return 1 2>/dev/null || exit 1
fi

export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-42}"

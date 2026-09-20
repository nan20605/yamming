#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT/scripts/source_ros_base.sh"
source "$ROOT/.venv_ros/bin/activate"

cd "$ROOT/ros2_ws"
rosdep install --from-paths src --ignore-src -r -y || true
colcon build --symlink-install

echo
echo "Built. Source with:"
echo "  source $ROOT/scripts/source_ros.sh"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v ros2 >/dev/null 2>&1; then
  # ros2 may simply not be sourced yet.
  if [ -f /opt/ros/humble/setup.bash ]; then
    source /opt/ros/humble/setup.bash
  elif [ -f /opt/ros/jazzy/setup.bash ]; then
    source /opt/ros/jazzy/setup.bash
  else
    echo "ROS 2 not found. Run scripts/08_install_ros2.sh first."
    exit 1
  fi
fi

python3 -m venv --system-site-packages "$ROOT/.venv_ros"
source "$ROOT/.venv_ros/bin/activate"
python -m pip install --upgrade pip wheel

if [ ! -d "$ROOT/third_party/i2rt/.git" ]; then
  echo "I2RT repo missing. Run scripts/01_bootstrap_i2rt.sh first."
  exit 1
fi

python -m pip install -e "$ROOT/third_party/i2rt"

python - <<'PY'
import rclpy
import i2rt
print("rclpy + i2rt import OK in ROS bridge environment")
PY

#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release
case "${VERSION_ID}" in
  "22.04") DISTRO="humble" ;;
  "24.04") DISTRO="jazzy" ;;
  *)
    echo "Unsupported Ubuntu version for this scripted path: ${VERSION_ID}"
    echo "Use the official ROS 2 installation docs for this OS."
    exit 1
    ;;
esac

echo "Installing ROS 2 ${DISTRO} for Ubuntu ${VERSION_ID}"

sudo apt update
sudo apt install -y locales software-properties-common curl
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo add-apt-repository universe -y
sudo apt update
sudo apt install -y curl

ROS_APT_SOURCE_VERSION="$(
  curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest \
  | grep -F '"tag_name"' | awk -F'"' '{print $4}'
)"
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME}}"
curl -L -o /tmp/ros2-apt-source.deb \
  "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${CODENAME}_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

sudo apt update
sudo apt upgrade -y
sudo apt install -y \
  "ros-${DISTRO}-ros-base" \
  python3-colcon-common-extensions \
  python3-rosdep \
  python3-vcstool \
  python3-venv

if ! sudo rosdep init 2>/dev/null; then
  echo "rosdep already initialized (or init returned non-zero); continuing."
fi
rosdep update

echo
echo "ROS 2 ${DISTRO} installed."
echo "Source with: source /opt/ros/${DISTRO}/setup.bash"

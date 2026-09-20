# ROS 2 notes

## Distribution choice

This repository's installer maps:
- Ubuntu 22.04 → ROS 2 Humble
- Ubuntu 24.04 → ROS 2 Jazzy

This is based on supported Ubuntu platforms, not "latest is always better."

## Why ROS is not first

The I2RT SDK already provides direct CAN control and MuJoCo tooling. If CAN bring-up fails, ROS will
not fix it. First prove:
1. adapter;
2. bus;
3. SDK;
4. arm.

Then expose state/commands to ROS.

## Python environment warning

ROS apt packages are built against the Ubuntu system Python. Do not casually run a different Python
ABI and expect `rclpy` to import.

`09_setup_ros_bridge_env.sh` creates a venv using the system interpreter with
`--system-site-packages`, so ROS Python packages remain visible while I2RT can be installed into the
same environment.

## Multi-machine ROS

Campus / enterprise Wi-Fi may block multicast discovery. The reliable bring-up workflow is therefore
SSH into the Jetson and keep the ROS graph local.

If you later need laptop-native ROS:
- test basic talker/listener across machines;
- then configure DDS peers / a discovery server / Zenoh if multicast is unreliable.

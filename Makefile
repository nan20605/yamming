.PHONY: diagnose i2rt can-inventory ros-install ros-env ros-build model-snapshot

diagnose:
	bash scripts/00_diagnose.sh

i2rt:
	bash scripts/01_bootstrap_i2rt.sh

can-inventory:
	bash scripts/02_can_inventory.sh

ros-install:
	bash scripts/08_install_ros2.sh

ros-env:
	bash scripts/09_setup_ros_bridge_env.sh

ros-build:
	bash scripts/10_build_ros_ws.sh

model-snapshot:
	bash scripts/11_snapshot_vendor_model.sh

from setuptools import find_packages, setup

package_name = "yam_ros_bridge"

setup(
    name=package_name,
    version="0.1.0",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="YAMMING",
    maintainer_email="noreply@example.com",
    description="Safety-gated ROS 2 bridge for I2RT YAM hardware.",
    license="MIT",
    entry_points={
        "console_scripts": [
            "hardware_node = yam_ros_bridge.hardware_node:main",
        ],
    },
)

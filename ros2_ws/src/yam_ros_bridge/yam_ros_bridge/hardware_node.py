from __future__ import annotations

import threading
from typing import Optional

import numpy as np
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import JointState
from std_srvs.srv import SetBool
from trajectory_msgs.msg import JointTrajectory

from i2rt.robots.get_robot import get_yam_robot
from i2rt.robots.utils import ArmType, GripperType


class YamHardwareNode(Node):
    """ROS 2 state bridge with an explicit command-enable gate.

    State publishing is always available.
    Motion commands are ignored unless:
      1. node parameter allow_commands is true, AND
      2. /yam/<side>/enable_commands service has been set true.

    This node deliberately avoids exposing torque control.
    """

    def __init__(self) -> None:
        super().__init__("yam_hardware")

        self.declare_parameter("channel", "can_left")
        self.declare_parameter("side", "left")
        self.declare_parameter("arm_type", "yam")
        self.declare_parameter("gripper_type", "linear_4310")
        self.declare_parameter("allow_commands", False)
        self.declare_parameter("publish_hz", 50.0)
        self.declare_parameter("max_command_step_rad", 0.08)

        channel = str(self.get_parameter("channel").value)
        side = str(self.get_parameter("side").value)
        arm_type = str(self.get_parameter("arm_type").value)
        gripper_type = str(self.get_parameter("gripper_type").value)
        self.allow_commands = bool(self.get_parameter("allow_commands").value)
        self.max_step = float(self.get_parameter("max_command_step_rad").value)
        publish_hz = float(self.get_parameter("publish_hz").value)

        self.side = side
        self.ns = f"/yam/{side}"
        self.command_enabled = False
        self.lock = threading.Lock()

        self.get_logger().info(
            f"Connecting to {side} arm on {channel}; allow_commands={self.allow_commands}"
        )

        self.robot = get_yam_robot(
            channel=channel,
            arm_type=ArmType.from_string_name(arm_type),
            gripper_type=GripperType.from_string_name(gripper_type),
            zero_gravity_mode=False,
        )

        self.joint_names = [f"{side}_joint{i}" for i in range(1, 7)]
        self.pub = self.create_publisher(JointState, f"{self.ns}/joint_states", 10)

        self.srv = self.create_service(
            SetBool, f"{self.ns}/enable_commands", self._enable_cb
        )

        self.sub = self.create_subscription(
            JointTrajectory,
            f"{self.ns}/joint_command",
            self._command_cb,
            10,
        )

        self.timer = self.create_timer(1.0 / publish_hz, self._publish_state)

    def _enable_cb(self, request: SetBool.Request, response: SetBool.Response):
        if request.data and not self.allow_commands:
            response.success = False
            response.message = (
                "Node started with allow_commands:=false. Restart explicitly with "
                "allow_commands:=true."
            )
            return response

        self.command_enabled = bool(request.data)
        response.success = True
        response.message = f"command_enabled={self.command_enabled}"
        self.get_logger().warning(response.message)
        return response

    def _publish_state(self) -> None:
        obs = self.robot.get_observations()
        msg = JointState()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.name = list(self.joint_names)
        msg.position = [float(x) for x in obs["joint_pos"]]
        msg.velocity = [float(x) for x in obs["joint_vel"]]
        msg.effort = [float(x) for x in obs["joint_eff"]]
        self.pub.publish(msg)

    def _command_cb(self, msg: JointTrajectory) -> None:
        if not (self.allow_commands and self.command_enabled):
            return
        if not msg.points:
            return

        point = msg.points[0]
        requested = np.asarray(point.positions, dtype=float)
        if requested.shape != (6,):
            self.get_logger().error(
                f"Expected exactly 6 arm joint positions, received {requested.shape}"
            )
            return

        with self.lock:
            q_full = self.robot.get_joint_pos().copy()
            q_arm = q_full[:6]
            delta = requested - q_arm

            if np.any(np.abs(delta) > self.max_step):
                self.get_logger().error(
                    f"Command rejected: per-message step exceeds {self.max_step:.3f} rad."
                )
                return

            q_full[:6] = requested
            self.robot.command_joint_pos(q_full)

    def destroy_node(self):
        try:
            self.command_enabled = False
            self.robot.close()
        finally:
            super().destroy_node()


def main(args: Optional[list[str]] = None) -> None:
    rclpy.init(args=args)
    node = YamHardwareNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()

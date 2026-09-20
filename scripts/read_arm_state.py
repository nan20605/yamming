#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

from i2rt.robots.get_robot import get_yam_robot
from i2rt.robots.utils import ArmType, GripperType


def arr(x):
    return [float(v) for v in x]


p = argparse.ArgumentParser()
p.add_argument("--channel", required=True)
p.add_argument("--arm", default="yam")
p.add_argument("--gripper", default="linear_4310")
p.add_argument("--output", required=True)
args = p.parse_args()

robot = get_yam_robot(
    channel=args.channel,
    arm_type=ArmType.from_string_name(args.arm),
    gripper_type=GripperType.from_string_name(args.gripper),
    zero_gravity_mode=False,
)
try:
    time.sleep(0.25)
    obs = robot.get_observations()
    info = robot.get_robot_info()
    record = {
        "timestamp_unix": time.time(),
        "channel": args.channel,
        "arm": args.arm,
        "gripper": args.gripper,
        "joint_pos": arr(obs["joint_pos"]),
        "joint_vel": arr(obs["joint_vel"]),
        "joint_eff": arr(obs["joint_eff"]),
        "gripper_pos": arr(obs.get("gripper_pos", [])),
        "joint_limits": [[float(a), float(b)] for a, b in info["joint_limits"]],
    }
    Path(args.output).write_text(json.dumps(record, indent=2))
    print(json.dumps(record, indent=2))
finally:
    robot.close()

#!/usr/bin/env python3
"""Tiny reversible first-motion test for a YAM arm.

Safety properties:
- never commands q=0 as an initial target;
- starts from the measured current configuration;
- checks vendor joint limits;
- limits the requested first nudge to <= 5 degrees;
- linearly interpolates out and back;
- requires explicit typed confirmation.

Use only after the official read-state and gravity-compensation tests pass.
"""

from __future__ import annotations

import argparse
import math
import sys
import time

import numpy as np

from i2rt.robots.get_robot import get_yam_robot
from i2rt.robots.utils import ArmType, GripperType


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--channel", required=True)
    p.add_argument("--arm", default="yam")
    p.add_argument("--gripper", default="linear_4310")
    p.add_argument("--joint", type=int, default=6, help="1-based arm joint index")
    p.add_argument("--degrees", type=float, default=2.0)
    p.add_argument("--seconds", type=float, default=2.0)
    args = p.parse_args()

    if not (1 <= args.joint <= 6):
        raise SystemExit("--joint must be 1..6")
    if not (0 < abs(args.degrees) <= 5.0):
        raise SystemExit("First-motion test is intentionally limited to <= 5 degrees.")
    if args.seconds < 1.0:
        raise SystemExit("Use --seconds >= 1.0 for first motion.")

    arm_type = ArmType.from_string_name(args.arm)
    gripper_type = GripperType.from_string_name(args.gripper)

    print("\nPHYSICAL CHECK:")
    print("  - arm base is bolted/clamped")
    print("  - workspace is clear")
    print("  - no person is in the swept volume")
    print("  - 24 V power cutoff is immediately reachable")
    print("  - this arm already passed read-state + gravity-comp tests")
    print("  - gripper is clear; some grippers calibrate during initialization")
    answer = input("\nType exactly MOVE to continue: ").strip()
    if answer != "MOVE":
        print("Cancelled.")
        return 1

    robot = None
    try:
        # Position-hold startup: the SDK initializes the target to current qpos rather than home.
        robot = get_yam_robot(
            channel=args.channel,
            arm_type=arm_type,
            gripper_type=gripper_type,
            zero_gravity_mode=False,
        )
        time.sleep(0.5)

        q0 = robot.get_joint_pos().copy()
        info = robot.get_robot_info()
        limits = np.asarray(info["joint_limits"], dtype=float)

        print("Current q:", np.array2string(q0, precision=4))
        print("Arm limits:\n", limits)

        idx = args.joint - 1
        delta = math.radians(args.degrees)

        target = q0.copy()
        candidate = target[idx] + delta

        lo, hi = limits[idx]
        # Respect an extra software margin for this test.
        margin = math.radians(3.0)
        if candidate > hi - margin or candidate < lo + margin:
            candidate = target[idx] - delta

        if candidate > hi - margin or candidate < lo + margin:
            raise RuntimeError(
                f"Joint {args.joint} is too close to its limit for a {args.degrees}° nudge."
            )

        target[idx] = candidate

        print(
            f"\nMoving joint {args.joint}: "
            f"{math.degrees(q0[idx]):.2f}° -> {math.degrees(target[idx]):.2f}°"
        )
        robot.move_joints(target, time_interval_s=args.seconds)
        time.sleep(0.75)

        print("Returning to measured start pose.")
        robot.move_joints(q0, time_interval_s=args.seconds)
        time.sleep(0.5)

        q1 = robot.get_joint_pos().copy()
        print("Final q:", np.array2string(q1, precision=4))
        print("First-motion test complete.")
        return 0
    except KeyboardInterrupt:
        print("\nInterrupted.")
        return 130
    finally:
        if robot is not None:
            robot.close()


if __name__ == "__main__":
    raise SystemExit(main())

# Architecture

## Layer 0 — electrical / transport

YAM motors communicate over CAN at 1 Mbit/s through USB-CAN adapters.

For two arms, use one dedicated CAN interface per arm.

Persistent interface names:
- `can_left`
- `can_right`

Do not use raw `can0` / `can1` in permanent launch files because enumeration order can change.

## Layer 1 — vendor hardware driver

Use the upstream I2RT Python SDK as the source of truth for:
- motor communication;
- joint remapping;
- motor model configuration;
- PD gains;
- joint limits;
- gravity compensation;
- gripper calibration;
- low-level error handling.

Do not duplicate those constants into this repository unless a measured calibration intentionally
overrides them.

## Layer 2 — robot process boundary

The Jetson owns the robot hardware and CAN interfaces.

Laptop interaction is initially:
- SSH;
- Git;
- logs;
- high-level launch commands.

Later, if a cross-machine ROS graph is genuinely useful, add it after local ROS works. Do not make
Wi-Fi reliability a precondition for holding a robot safely.

## Layer 3 — ROS 2 integration

ROS is a coordination and observability layer, not a replacement for the vendor low-level control
loop.

Initial ROS topics:
- `/yam/left/joint_states`
- `/yam/right/joint_states`

Command topics stay disabled by default.

## Layer 4 — simulation

The first model baseline is the exact I2RT MJCF/URDF revision used by the driver.

Build the bimanual scene around those models:
- measured arm-base transforms;
- table;
- rail/extrusion;
- camera frames;
- collision objects;
- grasp objects.

## Layer 5 — real→sim system identification

Estimate rather than guess:
- joint zero offsets;
- base transform;
- camera extrinsics;
- actuator latency;
- command filtering;
- Coulomb friction;
- viscous damping;
- static friction/deadband;
- payload / end-effector mass;
- compliant effects / backlash where observable.

## Layer 6 — domain randomization

Randomization distributions come from:
1. manufacturer tolerances;
2. repeated calibration variance;
3. system-ID confidence intervals;
4. residual error between replayed hardware and sim trajectories.

## Layer 7 — sim→real validation

A sim-trained or sim-tuned controller is not "transferred" merely because it runs on hardware.

Validate:
- trajectory tracking RMSE;
- endpoint error;
- overshoot;
- settling time;
- action latency;
- collision / limit violations;
- success rate over repeated trials.

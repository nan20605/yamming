# YAMMING

A reproducible bring-up, control, simulation, calibration, and real→sim→real workspace for the
I2RT bimanual YAM + NVIDIA Jetson research rig.

## Tonight's hard gates

Do **not** jump ahead because a later layer looks more exciting.

1. `G0` — physical rig is bolted down, 1 m arm clearance, power switch reachable.
2. `G1` — Jetson boots headless and is reachable by SSH.
3. `G2` — official I2RT SDK installs and the vendor MuJoCo viewer loads.
4. `G3` — both CAN adapters are detected and mapped deterministically to left/right.
5. `G4` — each arm's joint state can be read.
6. `G5` — each arm passes the official gravity-compensation test individually.
7. `G6` — each arm executes one tiny, reversible, rate-limited joint motion.
8. `G7` — both arms can be controlled reproducibly from the Jetson.
9. `G8` — ROS 2 is installed and can mirror live joint states.
10. `G9` — live real→sim state mirroring works using the official YAM model.
11. `G10` — calibration data layout exists for base transforms, camera intrinsics/extrinsics,
   joint zero offsets, friction/damping, latency, and system-ID trials.
12. `G11` — only after identification: domain-randomization ranges are generated from measured
   residuals, not guessed.
13. `G12` — sim→real validation compares the same command/trajectory in sim and on hardware.

A real, validated real→sim→real pipeline is more than "the XML opens in MuJoCo." This repository
keeps those claims separate so we do not fool ourselves.

## Architecture

```text
Laptop
  │
  │ SSH / high-level commands
  ▼
NVIDIA Jetson  ─────────── ROS 2 / logging / cameras / policy interface
  │
  ├── CAN adapter ── can_left  ── YAM left
  │
  └── CAN adapter ── can_right ── YAM right

Hardware control stays local to the Jetson.
Do not put campus Wi-Fi inside the motor-control loop.
```

The YAM arm itself uses **CAN**, not I2C, for motor communication. I2C can still appear elsewhere
in the robot for small sensors/peripherals, but it is not required to make the YAM arms move.

## First commands

```bash
cd ~/yamming
bash scripts/00_diagnose.sh
bash scripts/01_bootstrap_i2rt.sh
bash scripts/02_can_inventory.sh
```

Then follow `docs/NIGHT_RUNBOOK.md` exactly.

## Vendor sources

This repository deliberately does not fork or rewrite I2RT's robot model. It treats the vendor
model as the baseline and records the exact upstream commit used.

- I2RT SDK: https://github.com/i2rt-robotics/i2rt
- I2RT setup docs: https://doc.i2rt.com/getting-started/sw-setup
- YAM docs: https://doc.i2rt.com/products/yam
- MolmoAct2: https://github.com/allenai/molmoact2

## Repository layout

```text
yamming/
├── config/                  machine + robot configuration
├── data/
│   ├── calibration/         measured transforms / calibration artifacts
│   ├── raw/                 immutable raw logs
│   ├── processed/           derived aligned datasets
│   └── trajectories/        recorded hardware / sim trajectories
├── docs/                    runbooks and engineering notes
├── logs/                    bring-up + diagnostics logs
├── ros2_ws/src/             ROS 2 packages
├── scripts/                 reproducible setup + bring-up commands
├── sim/
│   ├── calibration/         real→sim parameter estimation
│   ├── domain_randomization/
│   ├── experiments/
│   └── model/               model metadata + scene construction
├── third_party/             cloned upstream repositories
└── tests/                   sanity and model-validation checks
```

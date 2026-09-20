# YAMMING

Bring-up, control, simulation, calibration, and real→sim→real workspace for the
I2RT bimanual YAM + NVIDIA Jetson research rig. 

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

# Night runbook: from fresh Jetson to first bimanual motion

This is the order. Do not debug three layers simultaneously.

## Gate 0 — physical safety

Before software:

- Bolt/clamp the rail and both YAM bases securely.
- Clear approximately one metre around each arm.
- Route CAN and power cables so neither arm can snag them.
- Keep the 24 V supply switch / emergency power cutoff reachable.
- Run first tests one arm at a time.
- Nobody's hand, face, laptop, cable bundle, or camera mast is inside the swept volume.
- Do not disable the YAM motor timeout during bring-up.

The I2RT stack has a configurable motor timeout; leave the factory safety behaviour intact.

## Gate 1 — make the Jetson headless

Run:

```bash
bash scripts/03_setup_headless_ssh.sh
hostname
hostname -I
```

From the laptop:

```bash
ssh <jetson-user>@yam-jetson.local
```

If `.local` discovery is blocked by the network, use the IP from `hostname -I`.

This is the normal workflow. The monitor is only for recovery when networking is broken.

## Gate 2 — official I2RT software

```bash
bash scripts/01_bootstrap_i2rt.sh
```

Then:

```bash
cd ~/yamming/third_party/i2rt
source .venv/bin/activate
python -c "import i2rt; print('i2rt OK')"
python examples/minimum_gello/minimum_gello.py --mode visualizer_local
```

If the Jetson is headless and no display is attached, the GUI viewer can be tested later on a
machine with a display. The import must still work.

## Gate 3 — identify the two CAN adapters

Power OFF the arms first if you are moving USB/CAN cabling around.

```bash
cd ~/yamming
bash scripts/02_can_inventory.sh
```

Plug one adapter at a time and record which arm it belongs to.

Install persistent names using USB serials:

```bash
sudo bash scripts/04_install_can_names.sh <LEFT_SERIAL> <RIGHT_SERIAL>
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Unplug/replug both CAN adapters, then:

```bash
ip link show can_left
ip link show can_right
```

Bring them up:

```bash
sudo bash scripts/05_can_up.sh can_left
sudo bash scripts/05_can_up.sh can_right
```

Expected bitrate: `1000000`.

## Gate 4 — prove state communication

With ONLY the left arm powered:

```bash
cd ~/yamming/third_party/i2rt
source .venv/bin/activate
python i2rt/robots/motor_chain_robot.py \
  --arm yam \
  --gripper linear_4310 \
  --channel can_left \
  --operation_mode stay_current_qpos \
  --log
```

You should see live joint data. `Ctrl+C` to exit.

Repeat on `can_right`.

Important: a linear gripper may perform its calibration motion on initialization. Keep the fingers
clear and unobstructed.

## Gate 5 — official gravity-compensation test

One arm at a time:

```bash
python i2rt/robots/motor_chain_robot.py \
  --arm yam \
  --gripper linear_4310 \
  --channel can_left \
  --operation_mode gravity_comp \
  --log
```

Gently support the arm before launching. It should become gravity compensated. Move it slowly by
hand. `Ctrl+C` to exit.

Repeat for the right arm.

## Gate 6 — first commanded motion

Do not command home (`q = 0`) as a first hardware test.

Use the repository nudge tool. It:

- starts in position-hold mode at the measured current pose;
- reads current joint limits from the SDK;
- picks joint 6 by default;
- moves only a tiny requested angle;
- interpolates over time;
- returns to the starting pose;
- requires a literal confirmation string.

Left:

```bash
cd ~/yamming/third_party/i2rt
source .venv/bin/activate
python ~/yamming/scripts/06_safe_nudge.py \
  --channel can_left \
  --arm yam \
  --gripper linear_4310 \
  --joint 6 \
  --degrees 2
```

Right:

```bash
python ~/yamming/scripts/06_safe_nudge.py \
  --channel can_right \
  --arm yam \
  --gripper linear_4310 \
  --joint 6 \
  --degrees 2
```

**Gate 6 passing means the arms moved under software control.**

## Gate 7 — bimanual state + reproducible motion

Once both arms independently pass:

```bash
bash ~/yamming/scripts/07_snapshot_bimanual_state.sh
```

Then use the official record/replay example to hand-guide a tiny trajectory and replay it. This is
a better early bimanual validation than inventing a large target pose.

## Gate 8 — ROS 2

ROS is deliberately after hardware validation.

```bash
cd ~/yamming
bash scripts/08_install_ros2.sh
bash scripts/09_setup_ros_bridge_env.sh
bash scripts/10_build_ros_ws.sh
```

Start a read-only bridge first:

```bash
source scripts/source_ros.sh
ros2 run yam_ros_bridge hardware_node --ros-args \
  -p channel:=can_left \
  -p side:=left \
  -p allow_commands:=false
```

In another Jetson shell:

```bash
source scripts/source_ros.sh
ros2 topic echo /yam/left/joint_states
```

Only after read-only state publishing works should command subscription be enabled.

## Gate 9 — real → sim

The vendor already provides URDF, MJCF, meshes, inertials, joint limits, and gravity computation.
Do **not** redraw the arm from screenshots.

Freeze the exact upstream model version:

```bash
bash scripts/11_snapshot_vendor_model.sh
```

Then log real joint states and mirror them into MuJoCo. The first digital-twin target is:

> Same measured `q` in hardware and simulation produces the same visible robot pose.

That is kinematic real→sim, not yet dynamic identification.

## Gate 10 — calibration + identification

Populate:

- `data/calibration/base_transforms/`
- `data/calibration/cameras/`
- `data/calibration/joints/`
- `data/calibration/dynamics/`
- `data/calibration/timing/`

See `docs/REAL2SIM2REAL.md`.

## "Done tonight" definition

A strong night is:

- both arms independently moved under a tiny controlled command;
- persistent CAN names survive reconnect/reboot;
- Jetson is reachable headlessly;
- official I2RT simulator/model is frozen to a known git commit;
- ROS 2 can publish live YAM joint states;
- real hardware state can be logged into the same coordinate convention as MuJoCo;
- the calibration + system-ID pipeline is ready for measured data.

Do not call domain-randomized sim→real "done" until you have actual identification residuals and a
hardware validation trajectory.

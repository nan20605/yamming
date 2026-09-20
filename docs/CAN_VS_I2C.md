# CAN vs I2C on this robot

## CAN

CAN is the important bus for the YAM arms.

Why:
- robust differential physical layer;
- multi-node bus;
- arbitration;
- error detection;
- intended for electrically noisy embedded/vehicle environments;
- long enough reach for robot wiring;
- YAM's DM-series motors are driven over it.

On this rig:

```text
Jetson USB
   │
USB-CAN adapter
   │
CAN_H / CAN_L
   │
YAM motor chain
```

The host sees a Linux network-style interface such as `can_left`.

## I2C

I2C is a short-distance board-level bus using SDA + SCL. It is common for IMUs, temperature
sensors, EEPROMs, GPIO expanders, etc.

It is **not required for basic YAM arm motion**.

If later the rig gains an I2C sensor, treat that as its own peripheral subsystem rather than
mixing it into CAN bring-up.

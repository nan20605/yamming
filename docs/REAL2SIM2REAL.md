# Real → Sim → Real methodology

The baseline YAM model is already unusually valuable: the vendor provides MJCF/URDF geometry,
inertials, joint limits, gripper composition, and gravity-compensation tooling. Start there.

## Phase A — kinematic real→sim

### A1. Freeze the exact model version
Record:
- I2RT git commit;
- arm variant;
- gripper variant;
- model XML hash;
- mesh hashes.

### A2. Joint convention check
At multiple safe poses:
1. read real joint vector;
2. set the same vector in MuJoCo;
3. compare the orientation and position of every link;
4. verify joint signs and zero conventions.

### A3. Base transforms
Measure each arm's base pose in a common world frame.

Best options:
- carefully surveyed fixture dimensions;
- fiducial board + calibrated camera;
- external tracker if available.

Store `T_world_left_base` and `T_world_right_base` with uncertainty.

### A4. Camera calibration
For every camera:
- intrinsics;
- distortion;
- depth scale;
- `T_world_camera`;
- timestamp source and clock offset.

If using RealSense, preserve its factory intrinsics but still estimate the camera extrinsic pose in
the robot world.

### A5. Visual overlay test
Project simulated geometry into the real camera image. Overlay edges / keypoints. Misalignment is
an immediate diagnostic for base transform, camera transform, or joint-zero errors.

## Phase B — dynamic identification

Excite one joint at a time first, at low amplitude and safe speed.

Log at high rate:
- command position;
- measured position;
- velocity;
- effort / torque proxy;
- timestamps;
- motor temperatures;
- control-loop frequency.

Estimate:
- effective latency;
- position-loop response;
- damping;
- Coulomb friction;
- deadband;
- payload effects.

Then run multi-joint trajectories to catch coupling.

## Phase C — model fitting

Fit parameters against held-out trajectories, not the same trajectories used for identification.

Objective examples:
- joint position RMSE;
- velocity RMSE;
- torque residual;
- end-effector pose RMSE.

Keep:
- nominal parameter estimate;
- covariance / confidence interval;
- residual distributions.

## Phase D — domain randomization

Randomize what is uncertain, not everything.

Candidates:
- base transform around measured covariance;
- camera extrinsics around calibration covariance;
- latency;
- friction;
- damping;
- payload;
- actuator gain;
- observation noise;
- depth noise;
- object mass/friction.

Do **not** use enormous arbitrary ranges. That usually teaches a policy to survive a universe that
does not resemble the real robot and can reduce performance.

## Phase E — sim→real

Use identical observation/action conventions in sim and real.

Before learned policies:
1. replay a deterministic trajectory in both;
2. compare state traces;
3. compare endpoint pose;
4. compare timing;
5. validate safety gating.

Then transfer the controller/policy.

## Phase F — closed loop of truth

Every real failure becomes data:
1. preserve raw episode;
2. label failure mode;
3. ask whether it is perception, dynamics, timing, control, or task distribution;
4. update identification/model only when evidence supports it;
5. retrain/re-evaluate;
6. hold out a validation set of real trajectories.

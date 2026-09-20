# Domain randomization

Do not pick randomization ranges by vibes.

Generate them from measured uncertainty and held-out residuals.

Suggested parameters:
- joint zero offset;
- camera extrinsic translation/rotation;
- command latency;
- observation latency;
- Coulomb friction;
- viscous damping;
- motor gain;
- payload mass and COM;
- object mass;
- object/table friction;
- RGB exposure/white balance;
- depth noise.

For each parameter record:
- nominal;
- distribution family;
- fitted spread;
- source measurement;
- date;
- confidence.

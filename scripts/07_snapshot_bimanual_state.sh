#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
I2RT="$ROOT/third_party/i2rt"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$ROOT/data/raw/bimanual_state_${STAMP}"

mkdir -p "$OUT"
cd "$I2RT"
source .venv/bin/activate

python "$ROOT/scripts/read_arm_state.py" --channel can_left  --output "$OUT/left.json"
python "$ROOT/scripts/read_arm_state.py" --channel can_right --output "$OUT/right.json"

echo "Saved state snapshot: $OUT"

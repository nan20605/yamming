#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
I2RT="$ROOT/third_party/i2rt"
OUT="$ROOT/sim/model/vendor_snapshot"

if [ ! -d "$I2RT/.git" ]; then
  echo "Missing $I2RT. Run scripts/01_bootstrap_i2rt.sh first."
  exit 1
fi

mkdir -p "$OUT"

cd "$I2RT"
COMMIT="$(git rev-parse HEAD)"
DATE="$(git show -s --format=%cI HEAD)"

cat > "$OUT/manifest.txt" <<EOF
source=https://github.com/i2rt-robotics/i2rt
commit=$COMMIT
commit_date=$DATE
captured=$(date -Is)
arm=yam
gripper=linear_4310
EOF

cp -a i2rt/robot_models/arm/yam "$OUT/"
cp -a i2rt/robot_models/gripper/linear_4310 "$OUT/" 2>/dev/null || true

find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/SHA256SUMS.txt"

echo "Frozen model metadata and source files at: $OUT"
echo "I2RT commit: $COMMIT"

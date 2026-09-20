#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THIRD="$ROOT/third_party"
REPO="$THIRD/i2rt"

mkdir -p "$THIRD"

sudo apt update
sudo apt install -y git curl build-essential python3-dev "linux-headers-$(uname -r)"

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ ! -d "$REPO/.git" ]; then
  git clone https://github.com/i2rt-robotics/i2rt.git "$REPO"
fi

cd "$REPO"
git fetch --all --tags
echo "Using I2RT commit: $(git rev-parse HEAD)"

if [ ! -d .venv ]; then
  uv venv --python 3.11
fi

source .venv/bin/activate
uv pip install -e .

python - <<'PY'
import i2rt
print("i2rt import OK")
PY

echo
echo "I2RT ready at: $REPO"
echo "Activate with: source $REPO/.venv/bin/activate"

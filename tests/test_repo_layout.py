from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_critical_files_exist():
    critical = [
        "README.md",
        "docs/NIGHT_RUNBOOK.md",
        "docs/REAL2SIM2REAL.md",
        "scripts/06_safe_nudge.py",
        "ros2_ws/src/yam_ros_bridge/yam_ros_bridge/hardware_node.py",
        "sim/calibration/calibration_schema.yaml",
    ]
    for rel in critical:
        assert (ROOT / rel).exists(), rel

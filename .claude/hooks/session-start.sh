#!/bin/bash
set -euo pipefail

# Only run in remote (web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install Python dependencies for tests and linting.
# Excludes: wmi (Windows-only), pyarmor/pyinstaller (packaging tools),
# face_recognition (mocked in tests, requires dlib build), ultralytics (mocked in tests).
pip install --quiet \
  pytest \
  pytest-asyncio \
  flake8 \
  pandas \
  numpy \
  pillow \
  matplotlib \
  seaborn \
  customtkinter \
  openpyxl \
  shapely \
  psutil \
  pycryptodome \
  tkcalendar \
  opencv-python-headless \
  supervision

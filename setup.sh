#!/bin/bash
# Builds the venv for this project (in ~/.venvs) and
# symlinks it back in as .venv. Safe to re-run any time the venv breaks.
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_NAME="$(basename "$PROJECT_DIR")"
EXTERNAL_VENV="$HOME/.venvs/$VENV_NAME"

rm -rf "$EXTERNAL_VENV"
python3 -m venv "$EXTERNAL_VENV"
"$EXTERNAL_VENV/bin/pip" install --upgrade pip -q
"$EXTERNAL_VENV/bin/pip" install -r "$PROJECT_DIR/requirements.txt"

rm -rf "$PROJECT_DIR/.venv"
ln -s "$EXTERNAL_VENV" "$PROJECT_DIR/.venv"

echo "Venv rebuilt at $EXTERNAL_VENV (symlinked as $PROJECT_DIR/.venv)"

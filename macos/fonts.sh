#!/usr/bin/env zsh
set -euo pipefail


if ! command -v age >/dev/null 2>&1; then
  echo "❌ Error: 'age' is not installed. Install it with 'brew install age'"
  exit 1
fi

DEST_DIR="$HOME/Library/Fonts"
mkdir -p "$DEST_DIR"

FONT_FILENAME="TX-02-Regular.ttf"
INPUT_FILEPATH="fonts/$FONT_FILENAME.age"
OUTPUT_FILEPATH="$DEST_DIR/$FONT_FILENAME"
echo "🔐 $INPUT_FILEPATH is encrypted"
age --decrypt "$INPUT_FILEPATH" > "$OUTPUT_FILEPATH"
echo "✅ Font installed to $OUTPUT_FILEPATH"

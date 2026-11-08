#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "Usage: $0 /path/to/Word.Setup-linux.1.0.0.AppImage" >&2
  exit 2
fi

source_appimage="$(realpath "$1")"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
app_dir="$HOME/.local/opt/open-docx"
appimage="$app_dir/open-docx.AppImage"
applications_dir="$data_home/applications"
icons_home="$data_home/icons"
desktop_file="$applications_dir/open-docx.desktop"

install -D -m 0755 "$source_appimage" "$appimage"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
(
  cd "$tmp_dir"
  "$appimage" --appimage-extract >/dev/null
)

icon_root="$tmp_dir/squashfs-root/usr/share/icons/hicolor"
icon="$(find "$icon_root" -type f \( -name '*.png' -o -name '*.svg' \) -path '*/apps/*' -print -quit 2>/dev/null || true)"
if [[ -z "$icon" ]]; then
  echo "Could not find the application icon inside the AppImage." >&2
  exit 1
fi

relative_icon="${icon#"$icon_root"/}"
icon_size="${relative_icon%%/*}"
icon_extension="${icon##*.}"
install -D -m 0644 "$icon" "$icons_home/hicolor/$icon_size/apps/open-docx.$icon_extension"
mkdir -p "$applications_dir"

cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=open docx
Comment=Edit Word document properties
Exec="$appimage" %F
Icon=open-docx
Terminal=false
Categories=Office;WordProcessor;
Keywords=Word;DOCX;Office;
StartupWMClass=open-docx
MimeType=application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/vnd.openxmlformats-officedocument.wordprocessingml.template;application/vnd.ms-word.document.macroEnabled.12;
EOF
chmod 0755 "$desktop_file"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
fi

echo 'Installed. Search for "open docx" in your applications menu.'

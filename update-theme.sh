#!/bin/sh
WALLPAPER=$(swww query | grep -oE '/[^ ]+\.(jpg|jpeg|png|webp|gif)' | head -n1)
if [ -z "$WALLPAPER" ]; then
   echo "⚠️  Could not detect wallpaper. Using fallback mode."
   WALLPAPER="/home/h4rsh/Pictures/Wallpapers/default.jpg"
fi
echo "🎨 Extracting colors from: $WALLPAPER"
nix run nixpkgs#matugen -- image "$WALLPAPER" --json hex | jq -r '
  .colors.light | to_entries | map("@define-color md-sys-color-\(.key | gsub("_";"-")) \(.value);") | .[]
' > ags/colors.css
echo "🔄 Reloading AGS..."
pkill -9 ags
ags & disown

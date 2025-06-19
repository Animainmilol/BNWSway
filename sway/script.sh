#!/bin/bash

function notification_with_bar() {
  notify-send -t 1000 \
    -h string:synchronous:volume \
    -h int:value:$PERCENTAGE \
    -h string:hlcolor:#FFFFFF \
    "$MESSAGE"
}

function volume() {
  case "$1" in
    up)
      pactl set-sink-volume @DEFAULT_SINK@ +5%
      VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
      MESSAGE="Volume: $VOLUME"
      PERCENTAGE=$VOLUME
      ;;
    down)
      pactl set-sink-volume @DEFAULT_SINK@ -5%
      VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
      MESSAGE="Volume: $VOLUME"
      PERCENTAGE=$VOLUME
      ;;
    mute)
      pactl set-sink-mute @DEFAULT_SINK@ toggle
      MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
      if [ "$MUTED" = "yes" ]; then
        MESSAGE="Muted"
        PERCENTAGE=0
      else
        VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
        MESSAGE="Unmuted ($VOLUME%)"
        PERCENTAGE=$VOLUME
      fi
      ;;
  esac
  notification_with_bar
}

function brightness() {
  case "$1" in
    up)
      brightnessctl set 5%+
      BRIGHTNESS=$(brightnessctl -m | sed 's/.*,\([0-9]*\)%.*/\1/')
      MESSAGE="Brightness: $BRIGHTNESS"
      PERCENTAGE=$BRIGHTNESS
      ;;
    down)
      brightnessctl set 5%-
      BRIGHTNESS=$(brightnessctl -m | sed 's/.*,\([0-9]*\)%.*/\1/')
      MESSAGE="Brightness: $BRIGHTNESS"
      PERCENTAGE=$BRIGHTNESS
      ;;
  esac
  notification_with_bar
}

function screenshot() {
  mkdir -p ~/Pictures/Screenshots

  timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
  filename="$HOME/Pictures/Screenshots/Screenshot_$timestamp.png"

  grim -g "$(slurp)" - | tee "$filename" | wl-copy

  notify-send "Screenshot saved!" "$filename" -i "$filename"
}

function color() {
  case "$1" in
    red)
      export REDSWAYCOLOR="FF4D4D"
      sed -i 's/4D4DFF/FF4D4D/g' ~/Pictures/background3.svg
      sed -i 's/4DFF4D/FF4D4D/g' ~/Pictures/background3.svg
      swaymsg reload
      ;;
    green)
      sed -i 's/4D4DFF/4DFF4D/g' ~/Pictures/background3.svg
      sed -i 's/FF4D4D/4DFF4D/g' ~/Pictures/background3.svg
      swaymsg reload
      ;;
    blue)
      sed -i 's/FF4D4D/4D4DFF/g' ~/Pictures/background3.svg
      sed -i 's/4DFF4D/4D4DFF/g' ~/Pictures/background3.svg
      swaymsg reload
      ;;
  esac
  
}

case "$1" in
  volume)
    volume "$2"
    ;;
  brightness)
    brightness "$2"
    ;;
  screenshot)
    screenshot
    ;;
  color)
    color "$2"
    ;;
esac

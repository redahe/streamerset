#!/bin/bash

FULLSCREEN_WIDTH=640
FULLSCREEN_HEIGHT=480
_endx=$(($FULLSCREEN_WIDTH-1))
_endy=$(($FULLSCREEN_HEIGHT-1))

ENCODER1=(
  x264enc
  bitrate=768
  speed-preset=faster # CPU/quality tradeoff
  qp-min=30 # quality/VBV-underflow tradeoff
  tune=zerolatency # rtmpsink crashes due to SIGPIPE if there is latency
)

MUXER="flvmux streamable=true name=mux"

gst-launch-1.0 \
${MUXER} ! filesink location=debug.flv \
ximagesrc use-damage=0 endx=${_endx} endy=${_endy} !\
video/x-raw, framerate=30/1 !\
videoscale method=0 add-borders=false ! \
video/x-raw,width=${FULLSCREEN_WIDTH},height=${FULLSCREEN_HEIGHT} !\
videoconvert ! \
queue leaky=downstream ! ${ENCODER1[@]} ! mux. \
alsasrc ! audioconvert ! \
queue leaky=downstream ! voaacenc ! mux.


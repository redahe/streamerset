#!/bin/bash

FULLSCREEN_WIDTH=640
FULLSCREEN_HEIGHT=480
_endx=$(($FULLSCREEN_WIDTH-1))
_endy=$(($FULLSCREEN_HEIGHT-1))

CAMERA_WIDTH=160
CAMERA_HEIGHT=90

_cam_xpos=$(($FULLSCREEN_WIDTH-$CAMERA_WIDTH-1))
_cam_ypos=0


# See 'pacmd list-sources' to find proper values
PULSE_AUDIO_MIC="cras-source"
PULSE_AUDIO_MON="cras-sink.monitor"


ENCODER1=(
  x264enc
  bitrate=768
  speed-preset=faster # CPU/quality tradeoff
  qp-min=30 # quality/VBV-underflow tradeoff
  tune=zerolatency
)

MUXER="flvmux streamable=true name=mux"

gst-launch-1.0 -v \
videomixer name=vmix sink_1::xpos=${_cam_xpos} sink_1::ypos=${_cam_ypos} !\
queue leaky=downstream ! ${ENCODER1[@]} ! \
${MUXER} ! filesink location=debug.flv \
audiomixer name=amix ! queue leaky=downstream ! voaacenc ! mux. \
ximagesrc use-damage=0 endx=${_endx} endy=${_endy} ! \
video/x-raw, framerate=30/1 ! \
videoscale method=0 add-borders=false ! \
video/x-raw,width=${FULLSCREEN_WIDTH},height=${FULLSCREEN_HEIGHT} !\
videoconvert ! \
vmix. \
v4l2src ! \
video/x-raw, framerate=30/1 ! \
videoscale method=0 add-borders=false ! \
video/x-raw,width=${CAMERA_WIDTH},height=${CAMERA_HEIGHT} !\
videoconvert ! \
vmix. \
pulsesrc device=${PULSE_AUDIO_MON} ! \
audioconvert ! \
audio/x-raw,channels=1 ! amix. \
pulsesrc device=${PULSE_AUDIO_MIC} ! \
audioconvert ! \
audio/x-raw,channels=1 ! amix.


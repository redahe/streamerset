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

TWITCH_KEY=$(cat ~/.twitchkey)
STREAM_DESTINATION="rtmpsink location=rtmp://live-ams.twitch.tv/app/${TWITCH_KEY}"

echo $STREAM_DESTINATION

FILE_DESTINATION="filesink location=data.flv"

ENCODER="x264enc bitrate=700 speed-preset=faster qp-min=30 tune=zerolatency"

gst-launch-1.0 \
videomixer name=vmix sink_1::xpos=${_cam_xpos} sink_1::ypos=${_cam_ypos} !\
queue leaky=downstream ! ${ENCODER} ! \
flvmux streamable=true name=mux ! ${STREAM_DESTINATION} \
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

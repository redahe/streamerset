#!/bin/bash

##############################################################
# Streams from a TV-connected board to Twitch                #
##############################################################

DEST_WIDTH=720
DEST_HEIGHT=405

TWITCH_KEY=$(cat ~/.twitchkey)
STREAM_DESTINATION="rtmpsink location=rtmp://live-ams.twitch.tv/app/${TWITCH_KEY}"

echo $STREAM_DESTINATION

FILE_DESTINATION="filesink location=data.flv"

# See 'pacmd list-sources' to find proper values
PULSE_AUDIO_MON="alsa_output.platform-tegra30-hda.hdmi-stereo.monitor"
ENCODER="omxh264enc control-rate=2 bitrate=700000" 
QUEUE="queue leaky=downstream "

DISPLAY=:0 gst-launch-1.0 \
pulsesrc device=${PULSE_AUDIO_MON} ! \
${QUEUE} ! \
audioconvert ! \
audio/x-raw,channels=1 ! ${QUEUE} ! voaacenc ! \
flvmux streamable=true name=mux ! \
${QUEUE} ! \
${FILE_DESTINATION} \
ximagesrc use-damage=0 endx=1920 endy=1080 ! \
nvvidconv ! 'video/x-raw(memory:NVMM), width='${DEST_WIDTH}', height='${DEST_HEIGHT}', framerate=60/1' ! \
${ENCODER} ! mux.

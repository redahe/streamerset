#!/bin/bash

##############################################################
# Streams from a TV-connected board to Twitch                #
##############################################################

FULLSCREEN_WIDTH=1920
FULLSCREEN_HEIGHT=1080
_endx=$(($FULLSCREEN_WIDTH-1))
_endy=$(($FULLSCREEN_HEIGHT-1))

DEST_WIDTH=960
DEST_HEIGHT=540

TWITCH_KEY=$(cat ~/.twitchkey)
STREAM_DESTINATION="rtmpsink location=rtmp://live-ams.twitch.tv/app/${TWITCH_KEY}"

echo $STREAM_DESTINATION

FILE_DESTINATION="filesink location=data.flv"


# See 'pacmd list-sources' to find proper values
PULSE_AUDIO_MON="cras-sink.monitor"
STREAM_DESTINATION="filesink location=ag.flv"
ENCODER="x264enc bitrate=700 speed-preset=faster qp-min=30 tune=zerolatency"
QUEUE="queue leaky=downstream "

gst-launch-1.0 \
ximagesrc use-damage=0 endx=${_endx} endy=${_endy} ! \
video/x-raw, framerate=30/1 ! \
videoscale method=0 add-borders=false ! \
video/x-raw,width=${DEST_WIDTH},height=${DEST_HEIGHT} !\
videoconvert ! \
${QUEUE} ! ${ENCODER} !\
flvmux streamable=true name=mux ! ${STREAM_DESTINATION} \
pulsesrc device=${PULSE_AUDIO_MON} ! \
audioconvert ! \
audio/x-raw,channels=1 ! ${QUEUE} ! voaacenc ! mux. \

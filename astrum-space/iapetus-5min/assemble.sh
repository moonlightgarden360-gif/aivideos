#!/usr/bin/env bash
# Builds final.mp4 (1920x1080, 5:00) from 20 Seedance clips + 20 narration takes.
# Expects clips.txt and vo.txt ("NN url" per line) in the working directory.
# Optional: UPLOAD_URL env var -> PUTs final.mp4 there when done.
set -euo pipefail

while read -r n u; do [ -s "c$n.mp4" ] || curl -fsSL --retry 3 "$u" -o "c$n.mp4"; done < clips.txt
while read -r n u; do [ -s "v$n.mp3" ] || curl -fsSL --retry 3 "$u" -o "v$n.mp3"; done < vo.txt
echo "downloaded"

BLOCK=15
LEAD=0.6
: > list.txt
for i in $(seq 1 20); do
  n=$(printf '%02d' "$i")
  fade=""
  [ "$i" = 1 ] && fade=",fade=t=in:st=0:d=1.5"
  [ "$i" = 20 ] && fade=",fade=t=out:st=$((BLOCK-3)):d=3"
  [ -s "b$n.mp4" ] || ffmpeg -y -v error -i "c$n.mp4" \
    -vf "tpad=stop_mode=clone:stop_duration=1,scale=1920:1080:flags=lanczos,fps=24,format=yuv420p,setsar=1${fade}" \
    -t "$BLOCK" -an -c:v libx264 -preset veryfast -crf 18 -r 24 "b$n.mp4"
  echo "file 'b$n.mp4'" >> list.txt

  ffmpeg -y -v error -i "v$n.mp3" \
    -af "silenceremove=start_periods=1:start_threshold=-45dB,adelay=600|600,apad,atrim=0:$BLOCK,aformat=sample_rates=48000:channel_layouts=stereo" \
    "a$n.wav"
  echo "block $n done"
done

ffmpeg -y -v error -f concat -safe 0 -i list.txt -c copy video.mp4
for i in $(seq 1 20); do printf "file 'a%02d.wav'\n" "$i"; done > alist.txt
ffmpeg -y -v error -f concat -safe 0 -i alist.txt -c pcm_s16le vo.wav

# Ambient drone bed (A minor-ish, slow swells), rendered at 48 kHz
ffmpeg -y -v error -f lavfi -i "aevalsrc='0.22*sin(2*PI*55*t)*(0.6+0.4*sin(2*PI*0.05*t))+0.16*sin(2*PI*110*t)*(0.6+0.4*sin(2*PI*0.07*t+1))+0.11*sin(2*PI*164.81*t)*(0.5+0.5*sin(2*PI*0.03*t+2))+0.07*sin(2*PI*220*t)*(0.5+0.5*sin(2*PI*0.04*t+3))+0.05*sin(2*PI*261.63*t)*(0.5+0.5*sin(2*PI*0.025*t+4))+0.04*sin(2*PI*329.63*t)*(0.5+0.5*sin(2*PI*0.035*t+5))|0.22*sin(2*PI*55.15*t)*(0.6+0.4*sin(2*PI*0.045*t+0.5))+0.16*sin(2*PI*110.2*t)*(0.6+0.4*sin(2*PI*0.065*t+1.5))+0.11*sin(2*PI*165.1*t)*(0.5+0.5*sin(2*PI*0.033*t+2.5))+0.07*sin(2*PI*220.3*t)*(0.5+0.5*sin(2*PI*0.042*t+3.5))+0.05*sin(2*PI*262*t)*(0.5+0.5*sin(2*PI*0.028*t+4.5))+0.04*sin(2*PI*330*t)*(0.5+0.5*sin(2*PI*0.031*t+5.5))':s=48000:d=300" \
  -af "aecho=0.8:0.6:900|1700:0.35|0.25,lowpass=f=1800,afade=t=in:d=4,afade=t=out:st=294:d=6,loudnorm=I=-30:TP=-6,aresample=48000" pad.wav

ffmpeg -y -v error -i vo.wav -i pad.wav -filter_complex \
  "[0:a]loudnorm=I=-15:TP=-1.5:LRA=11,aresample=48000[v];[1:a]aresample=48000[m];[v][m]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.95[out]" \
  -map "[out]" -c:a pcm_s16le mix.wav

ffmpeg -y -v error -i video.mp4 -i mix.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -t 300 -movflags +faststart final.mp4
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height,r_frame_rate -of compact final.mp4
ffmpeg -v info -i final.mp4 -map 0:a -af ebur128 -f null - 2>&1 | grep -E '^\s+I:' | tail -1

if [ -n "${UPLOAD_URL:-}" ]; then
  [ -s final.mp4 ]
  code=$(curl -s -o up.log -w '%{http_code}' -X PUT -H 'Content-Type: video/mp4' -H 'If-None-Match: *' --upload-file final.mp4 "$UPLOAD_URL")
  if [ "$code" != 200 ]; then
    head -c 400 up.log; echo
    code=$(curl -s -o up.log -w '%{http_code}' -X PUT -H 'Content-Type: video/mp4' --upload-file final.mp4 "$UPLOAD_URL")
  fi
  echo "UPLOAD_HTTP=$code"
fi
echo "ALL_DONE"

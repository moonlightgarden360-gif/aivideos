#!/usr/bin/env bash
# Builds the vertical Short: 6 Seedance 9:16 clips + 6 narration takes -> 1080x1920,
# ambient bed, loudness -14 LUFS, then TikTok-style burned captions via the subtitles workflow.
# Expects clips.txt and vo.txt ("N url" per line) and script.json in the working dir.
# Optional env: UP_SUB / UP_CLEAN = presigned PUT urls for the captioned / clean outputs.
set -euo pipefail

while read -r n u; do [ -s "c$n.mp4" ] || curl -fsSL --retry 3 "$u" -o "c$n.mp4"; done < clips.txt
while read -r n u; do [ -s "v$n.mp3" ] || curl -fsSL --retry 3 "$u" -o "v$n.mp3"; done < vo.txt

# Trim silence from each take and measure it
for n in 1 2 3 4 5 6; do
  ffmpeg -y -v error -i "v$n.mp3" -af "silenceremove=start_periods=1:start_threshold=-45dB,areverse,silenceremove=start_periods=1:start_threshold=-45dB,areverse,aformat=sample_rates=48000:channel_layouts=stereo" "t$n.wav"
done

# Timeline: lines start 0.15 s in, 0.25 s gaps; cuts fall mid-gap; 0.6 s tail after the last line
python3 - <<'EOF' > timeline.txt
import subprocess
d=[float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',f't{n}.wav']).decode()) for n in range(1,7)]
s=[0.15]
for i in range(5): s.append(s[-1]+d[i]+0.25)
b=[0.0]+[s[i]+d[i]+0.125 for i in range(5)]+[s[5]+d[5]+0.6]
for i in range(6): print(i+1, f"{s[i]:.3f}", f"{b[i+1]-b[i]:.3f}")
print('TOTAL', f"{b[-1]:.3f}")
EOF
cat timeline.txt
TOTAL=$(awk '/TOTAL/{print $2}' timeline.txt)

: > list.txt
while read -r n start seg; do
  [ "$n" = TOTAL ] && continue
  ffmpeg -nostdin -y -v error -i "c$n.mp4" \
    -vf "tpad=stop_mode=clone:stop_duration=3,scale=1080:1920:flags=lanczos:force_original_aspect_ratio=increase,crop=1080:1920,fps=24,format=yuv420p,setsar=1" \
    -t "$seg" -an -c:v libx264 -preset veryfast -crf 18 -r 24 "b$n.mp4"
  echo "file 'b$n.mp4'" >> list.txt
done < timeline.txt
ffmpeg -y -v error -f concat -safe 0 -i list.txt -c copy video.mp4

# Narration track: each take placed at its start time
inputs=""; filt=""; i=0
while read -r n start seg; do
  [ "$n" = TOTAL ] && continue
  ms=$(python3 -c "print(int(round($start*1000)))")
  inputs="$inputs -i t$n.wav"; filt="$filt[$i:a]adelay=${ms}|${ms}[a$i];"; i=$((i+1))
done < timeline.txt
ffmpeg -y -v error $inputs -filter_complex "${filt}[a0][a1][a2][a3][a4][a5]amix=inputs=6:normalize=0,apad,atrim=0:${TOTAL}[o]" -map "[o]" -ar 48000 narration.wav

# Ambient bed, a touch more present than the long-form mix
ffmpeg -y -v error -f lavfi -i "aevalsrc='0.22*sin(2*PI*55*t)*(0.6+0.4*sin(2*PI*0.25*t))+0.16*sin(2*PI*110*t)*(0.6+0.4*sin(2*PI*0.3*t+1))+0.11*sin(2*PI*164.81*t)*(0.5+0.5*sin(2*PI*0.2*t+2))+0.07*sin(2*PI*220*t)*(0.5+0.5*sin(2*PI*0.35*t+3))+0.05*sin(2*PI*329.63*t)*(0.5+0.5*sin(2*PI*0.15*t+4))|0.22*sin(2*PI*55.15*t)*(0.6+0.4*sin(2*PI*0.22*t+0.5))+0.16*sin(2*PI*110.2*t)*(0.6+0.4*sin(2*PI*0.28*t+1.5))+0.11*sin(2*PI*165.1*t)*(0.5+0.5*sin(2*PI*0.18*t+2.5))+0.07*sin(2*PI*220.3*t)*(0.5+0.5*sin(2*PI*0.33*t+3.5))+0.05*sin(2*PI*330*t)*(0.5+0.5*sin(2*PI*0.12*t+4.5))':s=48000:d=${TOTAL}" \
  -af "aecho=0.8:0.6:900|1700:0.35|0.25,lowpass=f=2200,afade=t=in:d=0.5,afade=t=out:st=$(python3 -c "print($TOTAL-1.5)"):d=1.5,loudnorm=I=-27:TP=-6,aresample=48000" pad.wav
ffmpeg -y -v error -i narration.wav -i pad.wav -filter_complex \
  "[0:a]loudnorm=I=-14:TP=-1.5:LRA=9,aresample=48000[v];[1:a]aresample=48000[m];[v][m]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.95[out]" \
  -map "[out]" -c:a pcm_s16le mix.wav
ffmpeg -y -v error -i video.mp4 -i mix.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -t "$TOTAL" -movflags +faststart short_clean.mp4

# Captions: Whisper clocks the clean narration, the authored script supplies the words
bash "$HF_WORKFLOWS/subtitles/scripts/fetch_fonts.sh" >/dev/null 2>&1 || true
python3 "$HF_WORKFLOWS/subtitles/scripts/audio_to_captions.py" narration.wav --srt caps.srt --script script.json --language en
python3 "$HF_WORKFLOWS/subtitles/scripts/subtitle_paper_burn.py" --in short_clean.mp4 --srt caps.srt --out short_subbed.mp4 --style bold --font-key tiktok

for f in short_clean.mp4 short_subbed.mp4; do
  echo "$f: $(ffprobe -v error -show_entries format=duration,size -of compact=p=0 $f)"
  ffprobe -v error -show_entries stream=codec_type,width,height,duration -of compact=p=0 $f
done
ffmpeg -v info -i short_subbed.mp4 -map 0:a -af ebur128 -f null - 2>&1 | grep -E '^\s+I:' | tail -1
echo "CUES $(grep -c -- '-->' caps.srt)"

put() { # file url
  [ -s "$1" ] && [ -n "$2" ] || return 0
  code=$(curl -s -o /dev/null -w '%{http_code}' -X PUT -H 'Content-Type: video/mp4' -H 'If-None-Match: *' --upload-file "$1" "$2")
  [ "$code" = 200 ] || code=$(curl -s -o /dev/null -w '%{http_code}' -X PUT -H 'Content-Type: video/mp4' --upload-file "$1" "$2")
  echo "UPLOAD $1 $code"
}
put short_subbed.mp4 "${UP_SUB:-}"
put short_clean.mp4 "${UP_CLEAN:-}"

# QC contact sheet: frame at each line's midpoint
i=0; while read -r n start seg; do [ "$n" = TOTAL ] && continue
  t=$(python3 -c "print($start+1.2)"); ffmpeg -y -v error -ss "$t" -i short_subbed.mp4 -frames:v 1 -vf scale=96:-1 "q$n.png"; done < timeline.txt
convert q1.png q2.png q3.png q4.png q5.png q6.png +append -strip -quality 45 qc.jpg
echo "QC $(base64 -w0 qc.jpg)"
echo ALL_DONE

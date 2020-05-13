#!/usr/bin/env bash
# fires up an xscreensaver hack and records it to an .mp4 video
# thx to Albert Veli for a hint and Jamie Zawinski for XScreenSaver
set -eu

##########
# defaults
debug=${debug:-""}
duration=${duration:-300}
fps=${fps:-30}  # decent values are 24,25,30,60

##########
# init
die() { >&2 echo "$*"; exit 1; }
quack() { if [ "${debug}" ];then echo "$*"; fi; }

command -v xwininfo >/dev/null || die "install xwininfo first"
command -v ffmpeg >/dev/null || die "install ffmpeg first"
ffmpeg -formats 2>/dev/null | grep -q '^ D. x11grab ' \
  || die "Fatal: ffmpeg cannot do x11grab; try another version or compile your own?"
ffmpeg -codecs 2>/dev/null | grep -q '^ .EV... h264 ' \
  || die "Fatal: ffmpeg cannot do libx264; I really want to use libx264"

##########
# main
arg1="$1"
shift
if [ -x "${arg1}" ]; then
  hackname="${arg1}"
elif [ -x "/usr/local/lib/xscreensaver/${arg1}" ]; then
  hackname="/usr/local/lib/xscreensaver/${arg1}"
elif [ -x "/usr/lib/xscreensaver/${arg1}" ]; then
  hackname="/usr/lib/xscreensaver/${arg1}"
else
  die "no xscreensaver hack found named \"${arg1}\""
fi
outfile="$(basename "${hackname}").mp4"

"$hackname" "$@" &
cpid=$!
txt=$(xwininfo -id "$(xdotool search --sync --all --onlyvisible --limit 1 --name "from the XScreenSaver" )")
[ "$txt" ] || die "Error getting window information."
x=$(<<<"$txt" awk '/^ *Absolute upper-left X:/{print $4}')
y=$(<<<"$txt" awk '/^ *Absolute upper-left Y:/{print $4}')
h=$(<<<"$txt" awk '/^ *Height:/{print $2}')
h=$(( h - ( h % 2 ) ))  # h264 codec chokes unless h%2 == 0
w=$(<<<"$txt" awk '/^ *Width:/{print $2}')
w=$(( w - ( w % 2 ) ))  # h264 codec chokes unless w%2 == 0
quack "found window ${w}x${h}+${x}+${y}"

tempfile=$(mktemp ./tmp.XXXXXXXX.mkv)
ffmpeg -hide_banner -v warning -threads 0 \
  -f x11grab -r "${fps}" -t "${duration}" \
  -s "${w}x${h}" -i ":0.0+${x},${y}" \
  -c:v h264 -preset ultrafast -qp 0 \
  -an -y "${tempfile}"
kill "$cpid"
echo ""
quack "$(ls -lh "${tempfile}")"
ffmpeg -hide_banner -v warning -threads 0 -i "${tempfile}" \
  -an -c:v h264 -pix_fmt yuv420p -preset slow "${outfile}" \
  && rm "${tempfile}"
ls -lh "${outfile}"

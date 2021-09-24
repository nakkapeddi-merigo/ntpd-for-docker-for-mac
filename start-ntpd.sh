#! /bin/sh

log() {
    echo "[start-ntpd.sh]" "$@" >&2
}

get_offset() {
    sntpc -n time.cloudflare.com 2>&1 | sed -n 's/.* offset=\(-\?[0-9]\+\([.][0-9]\+\)\?*\), .*/\1/p'
}

set -eu -o pipefail

# Use sntpc to estimate drift
log "measuring drift..."
adjtimex -q -f 0
o1="$(get_offset)"
sleep 10
o2="$(get_offset)"
drift="$(echo "scale=7; o1=${o1}; o2=${o2}; (o2-o1)/10*2^20" | bc)"
log "measured drift: ${drift}"

# Get current tick
tick="$(adjtimex | sed -n 's/.* tick: *\([0-9]\+\) us/\1/p')"
log "current tick: ${tick}"

# Compute new tick
newtick="$(echo "scale=7; tick=${tick}; drift=${drift}; t=tick*(1+drift/2^20)+0.5; scale=0; t/1" | bc)"
log "new tick: ${newtick}"

# Set tick
adjtimex -q -t "${newtick}"

# Start ntpd
log "starting ntpd"
exec ntpd -d -s

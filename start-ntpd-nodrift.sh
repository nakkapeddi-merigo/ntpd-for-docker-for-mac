#! /bin/sh

set -euxo pipefail

exec ntpd -d -s

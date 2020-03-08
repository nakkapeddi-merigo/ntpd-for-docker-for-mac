# ntpd-for-docker-for-mac

This project is a proof-of-concept for using openntpd to keep the Docker for
Mac VM in sync with the host time.

## Usage

First, build the Docker image.

    docker build -t ntpd-poc .

To try it out, stop the existing LinuxKit sntpc container.

    docker run --rm --privileged --pid=host justincormack/nsenter1 \
        /usr/bin/ctr -n services.linuxkit task pause sntpc

Then, start the ntpd container.

    docker run --rm --privileged --name ntpd ntpd-poc

## Monitoring

Use `ntpctl` to get information about ntpd.

    docker exec ntpd ntpctl -s all

You can use `sntpc` to monitor the offset.

    docker exec ntpd sntpc -i 5 -n gateway.docker.internal

The container will adjust the tick on startup. After about 15 minutes, `ntpd`
will adjust the frequency offset to keep the VM clock more precisely in sync
with the host. You can use the `adjtimex` command to obtain the current time
parameters.

    docker exec ntpd adjtimex

## References

* https://www.docker.com/blog/addressing-time-drift-in-docker-desktop-for-mac/
* https://www.eecis.udel.edu/~ntp/ntpfaq/NTP-s-trouble.htm
* https://rachelbythebay.com/w/2014/06/14/time/

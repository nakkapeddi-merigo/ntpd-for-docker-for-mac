# ntpd-for-docker-for-mac

This repository is a proof-of-concept for using openntpd to keep the Docker for
Mac VM in sync with the host time.

This approach could be used as a replacement for the existing sntpc container
to fix issues with monotonicity and improve the smoothness of the VM clock. See
https://github.com/docker/for-mac/issues/4347 for further details.

## Implementation
The Docker for Mac VM has access to a local ntp server at
gateway.docker.internal. Openntpd can use this information to smoothly adjust
the VM clock to stay in sync with the host. However this adjustment is limited
to 500 ppm which is not sufficient to combat observed clock drift values.

As a workaround, we perform a crude measurement of clock drift on startup and
adjust the tick value, then rely on openntpd for fine-grained frequency
adjustment on an ongoing basis.

A possible improvement to this implementation would be to periodically check
the drift value measured by ntpd and re-adjust the tick as needed. This could
help if the drift rate changes over time in excess of 500 ppm.

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

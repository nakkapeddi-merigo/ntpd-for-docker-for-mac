# Based on linuxkit/openntpd:0.7
# https://github.com/linuxkit/linuxkit/blob/v0.7/pkg/openntpd/Dockerfile

FROM linuxkit/alpine:86cd4f51b49fb9a078b50201d892a3c7973d48ec AS mirror

RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/
RUN apk add --no-cache --initdb -p /out \
    alpine-baselayout \
    bc \
    busybox \
    musl \
    openntpd \
    sntpc \
    && true
RUN rm -rf /out/etc/apk /out/lib/apk /out/var/cache

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=mirror /out/ /
COPY ntpd.conf /etc/ntpd.conf
COPY start-ntpd.sh /usr/sbin/start-ntpd.sh
COPY start-ntpd-nodrift.sh /usr/sbin/start-ntpd-nodrift.sh
CMD [ "/usr/sbin/start-ntpd-nodrift.sh" ]

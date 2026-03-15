FROM archlinux:base AS builder

ARG TZDB_VERSION
ARG TZDB_SOURCE=https://data.iana.org/time-zones/releases/tzdb-${TZDB_VERSION}.tar.lz
ARG CA_SCRIPT=https://github.com/curl/curl/raw/refs/heads/master/scripts/mk-ca-bundle.pl
ARG GLIBC_VERSION
ARG GLIBC_SOURCE=https://ftp.gnu.org/gnu/glibc/glibc-${GLIBC_VERSION}.tar.xz

RUN pacman -Sy --needed --noconfirm base-devel linux-api-headers python lzip >/dev/null

RUN mkdir -p \
 /base/{dev,etc,proc,run,sys,tmp,usr} \
 /base/usr/{bin,include,lib} \
 /base/usr/share/zoneinfo \
 /base/var/{cache,lib,lock,log,run,spool,tmp} \
 /base/etc/ssl/certs \
 && ln -s usr/bin /base/bin \
 && ln -s usr/bin /base/sbin \
 && ln -s usr/lib /base/lib \
 && ln -s usr/lib /base/lib64 \
 && ln -s lib /base/usr/lib64 \
 && ln -s bin /base/usr/sbin \
 && chmod a+rwx /base/tmp

RUN mkdir -p /build/timezone \
  && cd /build/timezone \
  && curl --silent --show-error --location --output tzdb.tar.lz ${TZDB_SOURCE} \
  && tar xf tzdb.tar.lz --strip-components=1 \
  && make -s zones DESTDIR=/base \
  && ln -sf /usr/share/zoneinfo/UTC /base/etc/localtime

RUN mkdir -p /build/ca \
  && cd /build/ca \
  && curl --silent --show-error --location --output mk-ca-bundle.pl ${CA_SCRIPT} \
  && perl mk-ca-bundle.pl /base/etc/ssl/certs/ca-certificates.crt

RUN mkdir -p /build/glibc \
  && cd /build/glibc \
  && curl --silent --show-error --location --output glibc.tar.xz ${GLIBC_SOURCE} \
  && tar xf glibc.tar.xz --strip-components=1 \
  && mkdir build && cd build \
  && ../configure --prefix=/usr --libdir=/usr/lib --sysconfdir=/etc \
    --enable-kernel=4.4 --with-bugurl=none --disable-static \
    --disable-selinux --disable-nscd --disable-obsolete-rpc \
    --disable-werror --quiet \
  && make -s -j$(nproc) \
  && make install DESTDIR=/base

# Generate all UTF-8 locales
RUN mkdir -p /base/usr/lib/locale && \
    ls /usr/share/i18n/locales \
      | grep -v -E '^(C|POSIX|i18n|iso14651_|translit_|.*\.deprecated$)' \
      | xargs -P"$(nproc)" -I{} \
          sh -c 'localedef \
                    --prefix=/base \
                    -i {} -f UTF-8 {}.UTF-8 2>/dev/null || true'

# Cleanup base dir
RUN find /base/usr -name '*.h' -o -name '*.a' -o -name '*.o' -delete \
  && find /base/usr/bin -type f ! -name 'locale' -delete \
  && rm -fr /base/usr/include \
  && rm -fr /base/usr/lib/audit \
  && rm -fr /base/usr/share/{info,i18n} \
  && rm -fr /base/usr/libexec/getconf \
  && rm -fr /base/var/cache/ldconfig \
  && rm -fr /base/var/db \
  && rm -f /base/etc/rpc /base/etc/ld.so.cache \
    /base/usr/lib/libc_malloc_debug.* /base/usr/lib/libthread_db.* \
    /base/usr/lib/libnss_compat.* /base/usr/lib/libnss_hesiod.* \
    /base/usr/lib/libnss_db.* /base/usr/lib/libnsl.* \
    /base/usr/lib/libanl.* /base/usr/libBrokenLocale.* \
    /base/usr/lib/libmemusage.* /base/usr/lib/libpcprofile.*

FROM scratch

ARG TZDB_VERSION
ARG GLIBC_VERSION

COPY --from=builder /base /
COPY ./etc/ /base/etc/

LABEL org.opencontainers.image.title="distroless"
LABEL org.opencontainers.image.description="distroless base image with glibc, tzdb, and mozilla ca certs"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-glibc"
LABEL org.opencontainers.image.version="${GLIBC_VERSION}"
LABEL build.glibc.version="${GLIBC_VERSION}"
LABEL build.tzdb.version="${TZDB_VERSION}"
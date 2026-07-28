FROM cgr.dev/chainguard/gcc-glibc:latest-dev AS builder

ARG TZDB_VERSION
ARG TZDB_SOURCE
ARG GLIBC_VERSION
ARG GLIBC_SOURCE
ARG CA_SCRIPT=https://github.com/curl/curl/raw/refs/heads/master/scripts/mk-ca-bundle.pl

RUN apk update && apk add curl lzip perl python-3.14 patch gawk bison texinfo grep

RUN bash -c 'mkdir -p \
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
 && chmod a+rwx /base/tmp'

WORKDIR /build/tzdb
RUN curl --silent --show-error --location --output tzdb.tar.lz ${TZDB_SOURCE} \
  && lzip -dc tzdb.tar.lz | tar x --strip-components=1 \
  && make -s zones DESTDIR=/base \
  && ln -sf /usr/share/zoneinfo/UTC /base/etc/localtime

WORKDIR /build/ca
RUN curl --silent --show-error --location --output mk-ca-bundle.pl ${CA_SCRIPT} \
  && perl mk-ca-bundle.pl /base/etc/ssl/certs/ca-certificates.crt

WORKDIR /build/glibc
RUN curl --silent --show-error --location --output glibc.tar.xz ${GLIBC_SOURCE} \
  && tar xf glibc.tar.xz --strip-components=1 \
  && mkdir build && cd build \
  && export CFLAGS="-O2 -fstack-protector-strong -D_FORTIFY_SOURCE=2 -fpie -fPIC -fno-plt -UENABLE_LOCK_ELISION -U__HAVE_ELISION" \
  && export LDFLAGS="-Wl,-z,relro,-z,now,-z,noexecstack" \
  && ../configure --prefix=/usr --libdir=/usr/lib --sysconfdir=/etc \
    --enable-kernel=4.4 --with-bugurl=none --disable-static \
    --disable-selinux --disable-nscd --disable-obsolete-rpc \
    --enable-stackguard-randomization \
    --enable-bind-now \
    --disable-werror --quiet \
  && make -s -j$(nproc) \
  && make install DESTDIR=/base

# Generate en_US.UTF-8, common, and all UTF-8 locales
ENV I18NPATH=/base/usr/share/i18n
RUN mkdir -p /base/usr/lib/locale \
  && ./build/locale/localedef --prefix=/base -i en_US -f UTF-8 en_US.UTF-8
RUN mkdir -p /tmp/common-locales/usr/lib/locale \
  && printf '%s\n' en_US zh_CN ja_JP de_DE fr_FR es_ES pt_BR ko_KR ru_RU it_IT nl_NL \
  | xargs -n1 -P$(nproc) -I{} ./build/locale/localedef \
    --prefix=/tmp/common-locales -i {} -f UTF-8 {}.UTF-8
RUN mkdir -p /tmp/all-locales/usr/lib/locale && \
    ls /base/usr/share/i18n/locales \
      | grep -v -E '^(C|POSIX|i18n|iso14651_|translit_|.*\.deprecated$)' \
      | xargs -P"$(nproc)" -I{} \
          sh -c './build/locale/localedef --prefix=/tmp/all-locales \
                    -i {} -f UTF-8 {}.UTF-8 2>/dev/null || true'

# Cleanup base dir
RUN find /base/usr \( -name '*.h' -o -name '*.a' -o -name '*.o' \) -delete \
  && find /base/usr/bin -type f ! -name 'locale' -delete
RUN bash -c 'rm -fr /base/usr/include \
  && rm -fr /base/usr/lib/{audit,gconv} \
  && rm -fr /base/usr/bin/iconv \
  && rm -fr /base/usr/share/{info,i18n} \
  && rm -fr /base/usr/libexec/getconf \
  && rm -fr /base/var/cache/ldconfig \
  && rm -fr /base/var/db \
  && rm -f /base/etc/rpc /base/etc/ld.so.{cache,conf} \
    /base/usr/lib/libc_malloc_debug.* /base/usr/lib/libthread_db.* \
    /base/usr/lib/libnss_compat.* /base/usr/lib/libnss_hesiod.* \
    /base/usr/lib/libnss_db.* /base/usr/lib/libnsl.* \
    /base/usr/lib/libanl.* /base/usr/lib/libBrokenLocale.* \
    /base/usr/lib/libmemusage.* /base/usr/lib/libpcprofile.* '

FROM scratch AS common-locales

ARG TZDB_VERSION
ARG GLIBC_VERSION

COPY --from=builder /base /
COPY --from=builder /tmp/common-locales/usr/lib/locale/locale-archive /usr/lib/locale/locale-archive
COPY ./etc /etc

LABEL org.opencontainers.image.title="distroless glibc"
LABEL org.opencontainers.image.description="distroless base image with glibc, tzdb, mozilla ca certs, and common locales"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-glibc"
LABEL org.opencontainers.image.version="${GLIBC_VERSION}"
LABEL org.opencontainers.image.base.libs="glibc@${GLIBC_VERSION},tzdb@${TZDB_VERSION}"

FROM scratch AS all-locales

ARG TZDB_VERSION
ARG GLIBC_VERSION

COPY --from=builder /base /
COPY --from=builder /tmp/all-locales/usr/lib/locale/locale-archive /usr/lib/locale/locale-archive
COPY ./etc /etc

LABEL org.opencontainers.image.title="distroless glibc"
LABEL org.opencontainers.image.description="distroless base image with glibc, tzdb, mozilla ca certs, and common locales"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-glibc"
LABEL org.opencontainers.image.version="${GLIBC_VERSION}"
LABEL org.opencontainers.image.base.libs="glibc@${GLIBC_VERSION},tzdb@${TZDB_VERSION}"

FROM scratch

ARG TZDB_VERSION
ARG GLIBC_VERSION

COPY --from=builder /base /
COPY ./etc /etc

LABEL org.opencontainers.image.title="distroless glibc"
LABEL org.opencontainers.image.description="distroless base image with glibc, tzdb, and mozilla ca certs"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-glibc"
LABEL org.opencontainers.image.version="${GLIBC_VERSION}"
LABEL org.opencontainers.image.base.libs="glibc@${GLIBC_VERSION},tzdb@${TZDB_VERSION}"

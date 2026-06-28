[![Current Version](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/release.svg)](https://github.com/simons-containers/distroless-glibc/pkgs/container/distroless-glibc)
[![Current Size](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/size.svg)](https://github.com/simons-containers/distroless-glibc/pkgs/container/distroless-glibc)
[![Tags](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/tags.svg)](https://github.com/simons-containers/distroless-glibc/pkgs/container/distroless-glibc)   
[![status](https://github.com/simons-containers/distroless-glibc/actions/workflows/deploy.yaml/badge.svg)](https://github.com/simons-containers/distroless-glibc/actions/workflows/deploy.yaml)
[![status](https://github.com/simons-containers/distroless-glibc/actions/workflows/update-versions.yaml/badge.svg)](https://github.com/simons-containers/distroless-glibc/actions/workflows/update-versions.yaml)  

# Distroless glibc container base

Bare-bones distroless container image base that contains glibc, tzdata, and mozilla CA certificates.

## License

Repository contents (e.g., `Containerfile`, build scripts, and configuration) are licensed under the **MIT License**.

Software included in built container images (such as **glibc**, **tzdata**, and **Mozilla CA Certificates**) are provided under their respective upstream licenses and is not covered by the MIT license for this repository.

## Acknowledgements

This project depends on a number of upstream components and data sources:

- **glibc** – GNU C Library providing the standard C runtime and POSIX interfaces used by most Linux systems.  
  https://www.gnu.org/software/libc/

- **tzdata** – The IANA Time Zone Database, which provides the canonical global timezone definitions used for correct time handling.  
  https://www.iana.org/time-zones

- **Mozilla CA Certificates** – The curated set of trusted root Certificate Authorities maintained by Mozilla and used by many systems for TLS verification.  
  https://wiki.mozilla.org/CA

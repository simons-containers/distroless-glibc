[![Current Version](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/release.svg)](https://github.com/simons-containers/distroless-glibc/pkgs/container/distroless-glibc) [![Tags](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/tags.svg)](https://github.com/simons-containers/distroless-glibc/pkgs/container/distroless-glibc) <br> ![Current Size](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/size.svg) ![Wasted Size](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/wasted.svg) ![Efficiency](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/efficiency.svg) <br> ![Critical](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/critical.svg) ![High](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/high.svg) ![Medium](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/medium.svg) ![Low](https://raw.githubusercontent.com/simons-containers/distroless-glibc/badges/.badges/main/low.svg) <br> [![Publish Workflow](https://img.shields.io/github/actions/workflow/status/simons-containers/distroless-glibc/deploy.yaml?label=Publish%20Workflow&logo=github)](https://github.com/simons-containers/distroless-glibc/actions/workflows/deploy.yaml) [![Update Workflow](https://img.shields.io/github/actions/workflow/status/simons-containers/distroless-glibc/update-versions.yaml?label=Update%20Workflow&logo=github)](https://github.com/simons-containers/distroless-glibc/actions/workflows/update-versions.yaml)  

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

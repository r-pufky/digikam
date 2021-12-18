# TODO(debian-11): Debian 11 has not been released yet for baseimage-gui.
#     This is currently being worked on in the v4 release branch:
#
#     https://github.com/jlesage/docker-baseimage-gui/tree/v4
#
#     Digikam 7.4.0 requires libraries present in Debian 11, as well as
#     mitigating any potential issues with CVE-2021-44228 (log4j) from any
#     dependencies. See: https://nvd.nist.gov/vuln/detail/CVE-2021-44228
#
#     It has been decided to build a pre-release debian-11 image to mitigate
#     this potential vulnerability as well as release digikam 7.4.0. It will
#     **NOT** be considered stable until debian-11 is released for
#     baseimage-gui.
#
#     Currently, this means the the build **IS NOT** reproducible without
#     patches. These are included in patches/ to manually reproduce (with some
#     docker user changes).
#
#     Manual build reproduction:
#       git clone https://github.com/jlesage/docker-baseimage-gui
#       cd docker-baseimage-gui
#       git checkout remotes/origin/v4
#       git apply ../digikam/patches/docker-baseimage-gui.3077e2c.patch
#       docker build -t rpufky/baseimage-gui:debian-11 .
#

# TODO(debian-11): revert when debian-11 jlesage image is released.
#FROM jlesage/baseimage-gui:debian-10
FROM rpufky/baseimage-gui:debian-11
ARG digikam_version=unknown

ENV APP_NAME=$digikam_version \
  USER_ID=1000 \
  GROUP_ID=1000 \
  UMASK=022 \
  TZ=Etc/UTC \
  KEEP_APP_RUNNING=1 \
  TAKE_CONFIG_OWNERSHIP=1 \
  CLEAN_TMP_DIR=1 \
  DISPLAY_WIDTH=1920 \
  DISPLAY_HEIGHT=1080 \
  ENABLE_CJK_FONT=1 \
  LANG=POSIX \
  LC_ALL=POSIX \
  LANGUAGE=POSIX \
  FULLSCREEN=1

# Install all locales for use.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales locales-all

# FUSE not supported in docker, pre-extract
# image to squashfs-root for copying.
#./digikam.appimage --appimage-extract

COPY startapp.sh /startapp.sh
COPY squashfs-root/ /digikam/

# Additional libraries needed for digikam:
# asound                 - 6.1.0+ needed for audio.
# udev                   - 6.1.0+ needed for devices.
# dbus                   - 6.1.0+ needed for machine id generation.
# libusb                 - 6.2.0 needed for 6.2.0 usb support.
# p11-ki                 - 6.2.0 needed for pkcs#11 support.
# libjack0               - 6.2.0 needed for audio connections.
# libz.so.1.2.9          - 6.2.0 (only) needed for libpng16-16.
# libgssapi-krb5-2       - 7.2.0 needed for digikam base.
# libnss3                - 7.2.0 needed for digikam base.
# libimage-exiftool-perl - 7.3.0 needed for digikam base.
# firefox-esr            - 7.3.0 needed for smugmug auth.   
# firefox-esr-l10n-all   - 7.3.0 needed for smugmug auth.
# libgl1-mesa-glx        - 7.4.0 needed for digikam base.
# Ensure en.UTF-8 set for locale.
RUN \
  update-locale LANG=${LANG} && \
  apt-get --quiet update && add-pkg \
  libusb-1.0 \
  p11-kit \
  libjack0 \
  libudev1 \
  libasound2 \
  pulseaudio \
  libgl1-mesa-dri \
  libgssapi-krb5-2 \
  libnss3 \
  libimage-exiftool-perl \
  firefox-esr \ 
  firefox-esr-l10n-all \
  libgl1-mesa-glx \
  dbus && \
  apt-get clean autoclean && \
  apt-get autoremove --yes && \
  sed-patch 's/^load-module\ module-native-protocol-unix/#&/' /etc/pulse/default.pa && \
  sed-patch 's/^#load-module\ module-native-protocol-tcp/load-module\ module-native-protocol-tcp auth-anonymous=1/' /etc/pulse/default.pa && \
  # Tag Metadata is a zippy window and cannot be closed without app border.
  sed-patch 's/<application type="normal">/<application type="normal" title="digikam">/' /etc/xdg/openbox/rc.xml && \
  rm -rfv /var/lib/{apt,dpkg,cache,log}

volume ["/data"]

FROM jlesage/baseimage-gui:debian-9
ARG digikam_version=unknown

# FUSE not supported in docker, pre-extract
# image to squashfs-root for copying.
#./digikam.appimage --appimage-extract

COPY startapp.sh /startapp.sh
COPY squashfs-root/ /digikam/

# Additional libraries needed for digikam:
# asound        - 6.1.0+ needed for audio.
# udev          - 6.1.0+ needed for devices.
# dbus          - 6.1.0+ needed for machine id generation.
# libusb        - 6.2.0 needed for 6.2.0 usb support.
# p11-ki        - 6.2.0 needed for pkcs#11 support.
# libjack0      - 6.2.0 needed for audio connections.
# libz.so.1.2.9 - 6.2.0 (only) needed for libpng16-16.

RUN apt-get -q update && add-pkg \
  libusb-1.0 \
  p11-kit \
  libjack0 \
  libudev1 \
  libasound2 \
  pulseaudio \
  libgl1-mesa-dri \
  dbus && \
  apt-get clean autoclean && \
  apt-get autoremove --yes && \
  sed-patch 's/^load-module\ module-native-protocol-unix/#&/' /etc/pulse/default.pa && \
  sed-patch 's/^#load-module\ module-native-protocol-tcp/load-module\ module-native-protocol-tcp auth-anonymous=1/' /etc/pulse/default.pa && \
  rm -rfv /var/lib/{apt,dpkg,cache,log}

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
  FULLSCREEN=1

# Tag Metadata is a zippy window and cannot be closed without app border.
RUN sed-patch 's/<application type="normal">/<application type="normal" title="digikam">/' /etc/xdg/openbox/rc.xml

volume ["/data"]

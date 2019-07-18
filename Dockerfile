FROM jlesage/baseimage-gui:debian-9

ARG digikam_version=unknown

# FUSE not supported in docker, pre-extract
# image to squashfs-root for copying.
#./digikam.appimage --appimage-extract

COPY startapp.sh /startapp.sh
COPY squashfs-root/ /digikam/

# Additional libraries needed for digikam.
# asound needed for audio.
# udev needed for devices.
# dbus needed for machine id generation.
RUN apt-get -q update && add-pkg \
  libudev1 \
  libasound2 \
  dbus && \
  apt-get clean autoclean && \
  apt-get autoremove -y && \
  rm -rfv /var/lib/{apt,dpkg,cache,log} && \
  chmod o=u -Rv /digikam

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
  ENABLE_CJK_FONT=1

volume ['/data']
# [Changelog][3g]
Uses semantic versioning, with an additional container version number:

`MAJOR.MINOR.PATCH.CONTAINER`

## Unreleased

## 7.5.0
Digikam [7.5.0 relase][9f].

Changes:
* update baseimage-gui to ubuntu-20.04 due to digikam changes.

## 7.4.0
Digikam [7.4.0 release][9f].

Changes:
* update baseimage-gui to ubuntu-20.04 due to digikam changes.

## 7.3.0
Digikam [7.3.0 release][9f].

Changes:
* Update defaults for 7.3.0 release.
* Add exiftool dependency.
* Add Firefox Extended Support Release (ESR) w/ all language support for smugmug
  authentication support.

Fixes:
* #11
* #12

## 7.2.0
Digikam [7.2.0 release][9f].

Changes:
* Added facial recognition training data configuration.
* Update dependencies for facial recognition.
* DB 10 to 11 stored functions troubleshooting.

Fixes:
* #8
 
## 7.1.0
Digikam [7.1.0 release][9f].

## 7.0.0
Digikam [7.0.0 release][9f].
Digikam [7.0.0-rc release][9f] from 2020-06-14 build.
Digikam [7.0.0-beta3 release][9f] from 2020-04-22T062854 build.
Digikam [7.0.0-beta2 release][9f] from 2020-01-27 build.
Digikam [7.0.0-beta1 release][9f] from 2019-12-22 build.

## 6.4.0
Digikam [6.4.0 release][7b].

## 6.4.0.1

Changes:
* Add libgl1-mesa-dri to resolve libEGL warning message.

Fixed:
* #2

## 6.4.0.0

Release digikam 6.4.0 from 2019-11-02 build:
https://download.kde.org/stable/digikam/6.4.0/.

## 6.3.0
Digikam [6.3.0 release][9d].

## 6.3.0.2

Changes:
* Removed manual zlib dependency, only needed for 6.2.0 version.

## 6.3.0.1

Changes:
* Include corrected 2019-09-04T22:22 6.3.0 build.
* Include release signature within container `/digikam/digikam-*.sig`
* Add `stable` and `major` tracks for releases.

## 6.3.0.0

Release digikam 6.3.0 from 2019-09-04 build:
https://download.kde.org/stable/digikam/6.3.0/.

# Deprecated Releases
All releases below are no longer maintained.

## 6.2.0
Digikam [6.2.0 release][8v].

### 6.2.0.1

Changes:
* Include release signature within container `/digikam/digikam-*.sig`
* Add `stable` and `major` tracks for releases.

### 6.2.0.0

Changes:
* AppImage and zlib packages are now verified against GPG signatures before
  extracting.
* 6.2.0 requires libz.so.1.2.9, debian stretch ships with 1.2.8. Build now
  includes zlib-1.2.9 source and builds a 1.2.9 shared object for use.
* Added libusb, p11-ki, libjack0 packages to base install to support 6.2.0.

## 6.1.0
Digikam 6.1.0 release.

### 6.1.0.3

Changes:
* Include release signature within container `/digikam/digikam-*.sig`
* Add `stable` and `major` tracks for releases.
* AppImage and zlib packages are now verified against GPG signatures before
  extracting.
* Build now includes zlib-1.2.9 source and builds a 1.2.9 shared object for use.

### 6.1.0.2
Set application permissions before add to docker layer; resulting in original
deployment size (552MB) instead of 1GB.

### 6.1.0.1
Address non-default permissions issue and tweak build settings for versioning
change.

Fixes:
* #1 Setting USER_ID does not properly propagate permissions inside container.

[9f]: https://www.digikam.org/documentation/releaseplan/
[7b]: https://cgit.kde.org/digikam.git/tree/project/NEWS.6.4.0
[9d]: https://cgit.kde.org/digikam.git/tree/project/NEWS.6.3.0
[8v]: https://cgit.kde.org/digikam.git/tree/project/NEWS.6.2.0
[3g]: https://keepachangelog.com/en/1.0.0/
[7g]: https://nvd.nist.gov/vuln/detail/CVE-2021-44228

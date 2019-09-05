# [Changelog][3g]
Uses semantic versioning, with an additional container version number:

`MAJOR.MINOR.PATCH.CONTAINER`

## Unreleased

## 6.3.0.0
Digikam [6.3.0 release][9d].

Release digikam 6.3.0 from 2019-09-04 build:
https://download.kde.org/stable/digikam/6.3.0/.

## 6.2.0.0
Digikam [6.2.0 release][8v].

Changes:
* AppImage and zlib packages are now verified against GPG signatures before
  extracting.
* 6.2.0 requires libz.so.1.2.9, debian stretch ships with 1.2.8. Build now
  includes zlib-1.2.9 source and builds a 1.2.9 shared object for use.
* Added libusb, p11-ki, libjack0 packages to base install to support 6.2.0.

## 6.1.0.2
Set application permissions before add to docker layer; resulting in original
deployment size (552MB) instead of 1GB.

## 6.1.0.1
Address non-default permissions issue and tweak build settings for versioning
change.

Fixes:
* #1 Setting USER_ID does not properly propagate permissions inside container.

## 6.1.0 (6.1.0.0)
Initial Digikam 6.1.0 container release.

* Note: Original release did not include the extra versioning (6.1.0).

[9d]: https://cgit.kde.org/digikam.git/tree/project/NEWS.6.3.0
[8v]: https://cgit.kde.org/digikam.git/tree/project/NEWS.6.2.0
[3g]: https://keepachangelog.com/en/1.0.0/

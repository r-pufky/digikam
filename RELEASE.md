# [Changelog][3g]
Uses semantic versioning, with an additional container version number:

`MAJOR.MINOR.PATCH.CONTAINER`

## Unreleased

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

[3g]: https://keepachangelog.com/en/1.0.0/
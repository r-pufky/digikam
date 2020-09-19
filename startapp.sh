#!/bin/sh
export HOME=/config
export LC_ALL=${LC_ALL}
export LANGUAGE=${LANGUAGE}
export LANG=${LANG}
update-locale LANG=${LANG}
exec /digikam/AppRun

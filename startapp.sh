#!/bin/sh
export HOME=/config
export LC_ALL=${LC_ALL}
export LANGUAGE=${LANGUAGE}
export LANG=${LANG}
update-locale LANG=${LANG}

echo
echo "-------------------------------------------------------------------------"
echo "|                              DEPRECATION WARNING                      |"
echo "-------------------------------------------------------------------------"
echo "|                                                                       |"
echo "| Support will end on the next major release (8.0). See migration link. |"
echo "|                                                                       |"
echo "| https://github.com/r-pufky/digikam/blob/master/migration.md           |"
echo "|                                                                       |"
echo "-------------------------------------------------------------------------"
echo "|                              DEPRECATION WARNING                      |"
echo "-------------------------------------------------------------------------"
echo

exec /digikam/AppRun

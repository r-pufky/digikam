[![digikam][f8]]https://www.digikam.org/documentation/)

DigiKam is an advanced open-source digital photo management application that
runs on Linux, Windows, and MacOS. The application provides a comprehensive set
of tools for importing, managing, editing, and sharing photos and raw files.

This is a docker image that uses the [Digikam AppImage][f9] combined with
[jlesage/baseimage-gui:debian9][5t] to enable dockerized digikam usage with all
plugins via any modern web browser without additional client configuration.

Please read documentation on [jlesage/baseimage-gui][5t] for detailed baseimage
usage.

## Version Tags
This image provides various versions that are available via tags. `latest` tag
usually provides the latest offical release with any new docker image changes
and should not be considered stable. Use an explicit version.

All binaries are based on the [jlesage/baseimage-gui:debian9][5t] base image.

| Tag    | Description                                                 | Size                                                                                                                                                                           |
|--------|-------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| latest | Lastest official release with image changes (current 6.1.0) | [![](https://images.microbadger.com/badges/image/rpufky/digikam.svg)](https://microbadger.com/images/rpufky/digikam "Get your own image badge on microbadger.com")             |
| 6.1.0  | Digikam version 6.1.0                                       | [![](https://images.microbadger.com/badges/image/rpufky/digikam:6.1.0.svg)](https://microbadger.com/images/rpufky/digikam:6.1.0 "Get your own image badge on microbadger.com") |

### docker
```
docker create \
  --name=digikam \
  -e USER_ID=1000 \
  -e GROUP_ID=1000 \
  -e TZ=America/Los_Angeles \
  -p 5800:5800 \
  -v /my/docker/service/config:/config \
  -v /my/photo/location:/data \
  -v /etc/localtime:/etc/localtime:ro \
  --restart unless-stopped \
  rpufky/digikam:6.1.0
```

### docker-compose
```
---
version: "3"
services:
  digikam:
    image: rpufky/digikam:6.1.0
    environment:
      - USER_ID=1000
      - GROUP_ID=1000
      - UMASK=022
      - TZ=America/Los_Angeles
      - KEEP_APP_RUNNING=1
      - DISPLAY_WIDTH=1920
      - DISPLAY_HEIGHT=1080
      - ENABLE_CJK_FONT=1
    volumes:
      - /my/docker/service/config:/config
      - /my/photo/location:/data
      - /etc/localtime:/etc/localtime:ro
```

## Parameters
Please read documentation on [jlesage/baseimage-gui][5t] for detailed baseimage
parameters. Only used and new default settings are listed here.

| Parameter             | Function                                                                                                                                                                                                                                                         | Default   |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
|`USER_ID`              | ID of the user the application runs as.                                                                                                                                                                                                                          | `1000`    |
|`GROUP_ID`             | ID of the group the application runs as.                                                                                                                                                                                                                         | `1000`    |
|`UMASK`                | Octal mask that controls how file permissions are set for newly created files. Default of `022` mean newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl | 022       |
|`TZ`                   | [TimeZone] of the container. Timezone can also be set by mapping `/etc/localtime` between the host and the container.                                                                                                                                            | `Etc/UTC` |
|`KEEP_APP_RUNNING`     | When set to `1`, the application will be automatically restarted if it crashes or if user quits it.                                                                                                                                                              | `1`       |
|`TAKE_CONFIG_OWNERSHIP`| When set to `1`, owner and group of `/config` (including all its files and subfolders) are automatically set during container startup to `USER_ID` and `GROUP_ID` respectively.                                                                                  | `1`       |
|`CLEAN_TMP_DIR`        | When set to `1`, all files in the `/tmp` directory are delete during the container startup.                                                                                                                                                                      | `1`       |
|`DISPLAY_WIDTH`        | Width (in pixels) of the application's window.                                                                                                                                                                                                                   | `1920`    |
|`DISPLAY_HEIGHT`       | Height (in pixels) of the application's window.                                                                                                                                                                                                                  | `1080`    |
|`SECURE_CONNECTION`    | When set to `1`, an encrypted connection is used to access the application's GUI (either via web browser or VNC client). See the [Security](#security) section for more details.                                                                                 | `0`       |
|`VNC_PASSWORD`         | Password needed to connect to the application's GUI. See the [jlesage/baseimage-gui - VNC Password][5t] section for more details.                                                                                                                                             | (unset)   |
|`X11VNC_EXTRA_OPTS`    | Extra options to pass to the x11vnc server running in the Docker container. **WARNING**: For advanced users. Do not use unless you know what you are doing.                                                                                                      | (unset)   |
|`ENABLE_CJK_FONT`      | When set to `1`, open source computer font `WenQuanYi Zen Hei` is installed. This font contains a large range of Chinese/Japanese/Korean characters.                                                                                                             | `1`       |

## User/Group IDs
When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Config Directory
Inside the container, the application's configuration should be stored in the
`/config` directory.

This directory is also used to store the VNC password.

**NOTE**: By default, during the container startup, the user which runs the
application (i.e. user defined by `USER_ID`) will claim ownership of the
entire content of this directory.  This behavior can be changed via the
`TAKE_CONFIG_OWNERSHIP` environment variable.

## Ports
Here is the list of ports used by container.  They can be mapped to the host
via the `-p <HOST_PORT>:<CONTAINER_PORT>` parameter.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Required? | Description                                                                                         |
|------|-----------|-----------------------------------------------------------------------------------------------------|
|`5800`| Mandatory | Port used to access the application's GUI via the web interface.                                    |
|`5900`| Optional  | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |

## Accessing the GUI
Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

  * A web browser:
```
http://<HOST IP ADDR>:5800
```

  * Any VNC client:
```
<HOST IP ADDR>:5900
```

## Security
By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC). Secure connection can be enabled via the
`SECURE_CONNECTION` environment variable. When enabled, application's GUI is
performed over an HTTPs connection when accessed with a browser. All HTTP
accesses are automatically redirected to HTTPs.

When using a VNC client, the VNC connection is performed over SSL. Note that few
VNC clients support this method.

See [jlesage/baseimage-gui][5t] for additional documentation.

## Digikam Setup
TBD

## Reverse Proxy Setup
TBD

## Licensing
Digikam is under the [GPLv2 license as stated here][2j]. Digikam [icon image][f8] is
unmodified and copied under this license.

[5t]: https://hub.docker.com/r/jlesage/baseimage-gui/
[f9]: https://www.digikam.org/download/
[2j]: https://invent.kde.org/kde/digikam/blob/master/COPYING
[f8]: https://raw.githubusercontent.com/r-pufky/digikam/master/digikam_oxygen.svg
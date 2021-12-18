# [![digikam][f8]](https://www.digikam.org/documentation/) digikam

digikam is an advanced open-source digital photo management application that
runs on Linux, Windows, and MacOS. The application provides a comprehensive set
of tools for importing, managing, editing, and sharing photos and raw files.

This is a docker image that uses the [digikam AppImage][f9] combined with
[jlesage/baseimage-gui:debian10][5t] to enable dockerized digikam usage with all
plugins via any modern web browser without additional client configuration.

Please read documentation on [jlesage/baseimage-gui][5t] for detailed baseimage
usage.

:warning:
The 7.4.0 release requires Debian 11 as well as mitigating [CVE-2021-44228][7g].

Debian 11 baseimage has not been released stable yet; therefore a custom build
has been created. As such, 7.4.0 will not be in the 'stable' release until
it is publically released and the build is reproducible without patches.

Build reproduction instructions are located in [Dockerfile](Dockerfile).
:warning:

## Version Tags
This image provides various versions that are available via tags. Use `stable`
or an explicit digikam version (e.g. 7.3.0), which will provide updates but
minimize unexpected changes. 

* `stable` will provide the latest officially released version of digikam.
* `latest` will provide the latest digikam build and can break.

`stable` and `latest` containers are auto-rebuilt weekly.

| Tag    | Description             | Comment                                                         |
|--------|-------------------------|-----------------------------------------------------------------|
| latest | digikam container 7.4.0 | [7.4.0 Release](https://download.kde.org/stable/digikam/7.4.0/) |
| stable | digikam container 7.3.0 | [7.3.0 Release](https://download.kde.org/stable/digikam/7.3.0/) |

* All binaries are based on the [jlesaige/baseimage-gui:debian9][5t] base image.
* See detailed [release notes here][b2] for older container point releases. Only current and previous versions are kept.
* Submit docker-related [bugs here][sl].
* See digikam [release plan here][2k].
* See [troubleshooting](#troubleshooting) for issues, like DB 10 to 11 upgrade failure.

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
  rpufky/digikam:stable
```

### docker-compose
```
---
version: "3"
services:
  digikam:
    image: rpufky/digikam:stable
    ports:
      - "5800:5800"
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
|`LANG`                 | System default locale.                                                                                                                                                                                                                                           | `POSIX`   |
|`LANGUAGE`             | System fallback locale.                                                                                                                                                                                                                                          | `POSIX`   |
|`LC_ALL`               | System locale override.                                                                                                                                                                                                                                          | `POSIX`   |

## Ports
Here are the list of ports used by container. They can be mapped to the host
via the `-p <HOST_PORT>:<CONTAINER_PORT>` parameter. The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Required? | Description                                                                                         |
|------|-----------|-----------------------------------------------------------------------------------------------------|
|`5800`| Mandatory | Port used to access the application's GUI via the web interface.                                    |
|`5900`| Optional  | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |

## Volumes

| Volume  | Function                                   |
|---------|--------------------------------------------|
| /config | Stores digikam configuration and database. |
| /data   | User data location for images.             |

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

## Accessing the GUI
Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

A web browser
```
http://{HOST IP}:5800
```

Any VNC client
```
{HOST IP}:5900
```

However, a **[reverse proxy web based](#reverse-proxy-setup)** connection is
preferred.

## Security
By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC). Secure connection can be enabled via the
`SECURE_CONNECTION` environment variable. When enabled, application's GUI is
performed over an HTTPs connection when accessed with a browser. All HTTP
accesses are automatically redirected to HTTPs.

When using a VNC client, the VNC connection is performed over SSL. Note that few
VNC clients support this method.

See [jlesage/baseimage-gui][5t] for additional documentation.

## Reverse Proxy Setup
digikam should be operated behind a reverse proxy to isolate access to the
container. The following reverse proxy example assumes that you have a
digikam sub-domain setup for nginx.

```nginx
server {
  listen 443 ssl http2;
  server_name digikam.example.com digikam;

  location / {
    proxy_pass https://digikam:5800/;
  }

  location /websockify {
    proxy_pass https://digikam:5800;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
  }
}
```
* `websockify` provides the web socket connection for the browser and needs to
  exposed for the GUI to render properly.

## digikam Setup
When first launching digikam the only explicit settings that must be set are the
following:

### Configure where you keep your images
![digikam images][5k]
* Manually set to `/data` for your images.

### Configure where you will store databases
![digikam db][b7]
* Type: `SQLite`
* Manually set to `/config` for your db.

### Facial recognition training data
![digikam faces][c8]
* Download **~335MB**
* One time download if `/config` is mounted outside of docker.

## Troubleshooting

### Failed to update DB schema from [10 to 11][8s]
Your digikam DB user does not have sufficient rights to modify the DB tables.

By default stored functions [require superuser (root)][8h] permissions.

Enable trusted stored functions.
```bash
mysql -u root -p

set global log_bin_trust_function_creators=1;
```

## Manually Building
Built using a Makefile to manage builds. Common commands below:

```bash
make
```
* Shows all make options.

```bash
sudo make stable
```
* Build a 'stable' package with defaults.

```bash
sudo make latest version=6.4.0 container=10
```
* builds 'latest' version using digikam appimage 6.4.0, container version 6.4.0.10.

```bash
sudo make clean
```
* Cleans build artifacts on the filesystem.

## Licensing
digikam is under the [GPLv2 license as stated here][2j]. digikam [icon image][f8] is
unmodified and copied under this license.

[8h]: https://mariadb.com/docs/reference/mdb/system-variables/log_bin_trust_function_creators/
[8s]: https://bugs.kde.org/show_bug.cgi?id=435065#c8
[2k]: https://www.digikam.org/documentation/releaseplan/
[sl]: https://github.com/r-pufky/digikam/issues
[5t]: https://hub.docker.com/r/jlesage/baseimage-gui/
[f9]: https://www.digikam.org/download/
[2j]: https://invent.kde.org/kde/digikam/blob/master/COPYING
[f8]: https://raw.githubusercontent.com/r-pufky/digikam/master/media/digikam_oxygen.svg?sanitize=true
[5k]: https://github.com/r-pufky/digikam/blob/master/media/digikam-setup-images.png?raw=true
[b7]: https://github.com/r-pufky/digikam/blob/master/media/digikam-setup-db.png?raw=true
[b2]: https://github.com/r-pufky/digikam/blob/master/RELEASE.md
[c8]: https://github.com/r-pufky/digikam/blob/master/media/digikam-setup-faces.png?raw=true
[7g]: https://nvd.nist.gov/vuln/detail/CVE-2021-44228

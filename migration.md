# Migration to Linuxserver Digikam

:warning: ALWAYS BACKUP YOUR DATA AND CONFIGS! :warning:

## TOC
* [Migration Steps](#migration-steps)
* [Manual Migration](#manual-migration)
* [Setup a new linuxserver digikam container](#setup-a-new-linuxserver-digikam-container)
* [File locations](#file-locations)
* [Background](#background)
* [FAQS](#faqs)

## Migration Steps
Database backend types (sqlite3/SQL) do not affect which migration process you
use. If you have used custom storage locations see [Manual Migration](#manual-migration).

These instructions assume you used the default locations in the original setup
[instructions](https://github.com/r-pufky/digikam/blob/master/README.md#digikam-setup).

Only docker-compose steps are covered.

### Setup new linuxserver container
Run through [setup a new linuxserver/digikam container](#setup-a-new-linuxserver-digikam-container)

This will get the new digikam container in the appropriate state for migration.

### Update rpufky digikam to latest release
Standard upgrade steps. Use the `latest` tag in `docker-compose.yml` and update
your container. Be sure to add a `container_name` if you haven't set one
before.

`rpufky-digikam/docker-compose.yml`
```yaml
---
version: "3"
services:
  digikam:
    image: rpufky/digikam:latest    # USE LATEST RELEASE.
    container_name: rpufky-digikam  # SET CONTAINER NAME.
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

Update the container and copy the migration script to your system; this should
use your `container_name`.
```bash
docker-compose stop
docker-compose pull
docker-compose up -d
docker cp rpufky-digikam:/migrate_to_ls /tmp
docker-compose stop
chmod +x /tmp/migrate_to_ls
```

### Migrate configuration data
Use script previous copied to migrate configuration data to the new linuxserver
container. This is non-destructive for the source container.

Trailing slashes are required.
```bash
/tmp/migrate_to_ls -s /my/docker/service/config/ -d /my/docker/service/NEW/config/
```

Restart the linuxserver digikam container and verify settings are correct. Be
aware that you may need to update reverse proxy or firewall rules for the new
ports.

```bash
docker-compose up -d
```

Once verified, the original digikam container may be deleted.

## Manual Migration
Use [Migration Steps](#migration-steps). Only use this if you have a custom
setup that did not follow original instructions.

This assumes working knowledge and only covers major points.

### Setup new linuxserver container
Run through [setup a new linuxserver/digikam container](#setup-a-new-linuxserver-digikam-container)

This will get the new digikam container in the appropriate state for migration.

### Update rpufky digikam to latest release
Standard upgrade steps. Use the `latest` tag for `rpufky/digikam` and update
the image. Launch the container to update and shutdown. Only keep the container
running if `/config` is not mounted externally.

### Migrate settings

Migrate `digikamrc` to the new container config.

```bash
cp -av "{NEW}/config/.config/digikamrc" "{NEW}/config/.config/digikamrc.orig"
cp -av "{ORIGINAL}/config/xdg/config/digikamrc" "{NEW}/config/.config/digikamrc"
```

Migrate DBs.

```bash
find "${NEW}/config" -type f -name "*.db" -exec mv -v {} {}.orig \;
cp -av "${ORIGINAL}"/config/*.db "${NEW}/config"
```

Remember to set permissions on the copied files if different. Restart the
linuxserver digikam container and verify settings are correct. Be aware that
you may need to update reverse proxy or firewall rules for the new ports.

Once verified, the original digikam container may be deleted.

## Setup a new linuxserver digikam container
https://hub.docker.com/r/linuxserver/digikam

Create a new digikam container, using the same settings as originally used
creating the rpufky/digikam container. The `docker-compose.yml` file should be
in a different location to preserve the original config. Use the **same**
`data` location but a **new** `config` location.

Adapt the following settings per your setup.

`ls-digikam/docker-compose.yml`
```yaml
---
version: "2.1"
services:
  digikam:
    image: lscr.io/linuxserver/digikam
    container_name: ls-digikam                 # USE DIFFERENT CONTAINER NAME.
    network_mode: host
    environment:
      - PUID=1000
      - PGID=1000
      - UMASK=022
      - TZ=America/Los_Angeles
      - SUBFOLDER=/
      - KEYBOARD=en-us-qwerty
      - AUTOLOGIN=true
    volumes:
      - /my/docker/service/NEW/config:/config  # USE A NEW CONFIG LOCATION.
      - /my/photo/location:/data               # USE SAME DATA LOCATION.
    ports:
      - "3000:3000"
    restart: unless-stopped
```

Start the container and explicitly set the following
```bash
docker-compose up -d
```

### Configure where you keep your images
<details><summary>Show GUI Screen</summary>
<p>

![digikam images][5k]

</p>
</details>

* Manually set to `/data` for your images (or where your data is set to).

### Configure where you will store databases
<details><summary>Show GUI Screen</summary>
<p>

![digikam db][b7]

</p>
</details>

* Type: `SQLite`
* Manually set to `/config` for your db (or where your config is set to).
* Set SQLite even if you are using a SQL backend. This will setup the initial
  container, and migrating the settings will configure SQL for you.

### Facial recognition training data
<details><summary>Show GUI Screen</summary>
<p>

![digikam faces][c8]

</p>
</details>

* Download **~335MB**
* One time download if `/config` is mounted outside of docker.

All other settings will be overwritten when migration is completed. Once the
facial recognition data is downloaded, shutdown the container for migration.

```bash
docker-compose stop
```

The new linuxserver container is ready to migrate data to.

## File locations
Files locations have changed in the linuxserver container.

| type          | rpufky/digikam               | linuxserver/digikam       |
| ------------- | ---------------------------- | ------------------------- |
| configuration | /config/xdg/config/digikamrc | /config/.config/digikamrc |
| DB's          | /config/*.db                 | /config/*.db              |

## Background
I originally created this image to fit my need for a WebUI docker-based photo
management tool; I modeled this off of linuxserver images at the time and it
quickly grew to become a massive success.

Without getting into the technical back and forth, I moved away from docker
containers a few years ago, but have maintained this image given the popularity
and no drop-in replacement. Now that linuxserver has produced a viable digikam
image, the original purpose for this image no longer exists; and I'm left
solely maintaining software on a platform that I have not used as a daily
driver in years.

It's time to retire this original image and migrate to linuxserver images. When
I used docker, linuxserver images were the only images I used if I didn't build
them myself. You're in good hands.

This repo will be archived on the next major digikam release and support will
cease. Feel free to clone and maintain this if you need to, or spend a few
minutes and migrate to linuxserver/digikam image.

## FAQS

### I need more time to migrate!
If the timeline does not fit your needs; please fork and build your own image
to use. This will be a 1:1 image of the current container. Be sure to update
your docker config to use the new image.

### Can I continue to use this image?
This image will be supported until the next major release. After that you
should fork this repository and maintain it yourself. Be sure to update your
image name in your docker config if you do so.

There will be no support for the image once it is archived.

### How do I build it myself?
A `Makefile` is provided to automatically verify and build from source. Read
through the [build instructions](https://github.com/r-pufky/digikam#manually-building)
and update the `Makefile` accordingly.

### What are the main differences?
1. Only WebGUI via rdesktop is supported. VNC connections are not supported.
1. It is now a full desktop environment. Digikam not longer restarts
   automatically if it crashes; right click on the desktop and re-launch it.
1. The top bar is remove and replaced by a dot on the left hand side for copy
   paste / keyboard operations.
1. International glyphs are supported but the keyboard input mechanism does
   not support this currently. This will be supported when the underlying
   library in the new container enables support.
1. The default port has changed from `5800` to `3000`. Either redirect this in
   the new container or update your reverse proxy.

[5k]: https://github.com/r-pufky/digikam/blob/master/media/digikam-setup-images.png?raw=true
[b7]: https://github.com/r-pufky/digikam/blob/master/media/digikam-setup-db.png?raw=true
[c8]: https://github.com/r-pufky/digikam/blob/master/media/digikam-setup-faces.png?raw=true

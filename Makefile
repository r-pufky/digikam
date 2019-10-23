# Makefile for digikam docker containers.
#
# Public Keys
#   Digikam: http://keys.gnupg.net/pks/lookup?search=digikamdeveloper%40gmail.com&fingerprint=on
#   libpng zlib: http://keys.gnupg.net/pks/lookup?search=Glenn+Randers-Pehrson&fingerprint=on
#
version            = 6.3.0
container          = X
zlib_version       = 1.2.9
BUILD_DIR          = digikam-build
STAGING_DIR        = $(BUILD_DIR)/staging
GPG_DIR            = $(BUILD_DIR)/gpg
DIGI_BUILD         = $(BUILD_DIR)/$(version)/squashfs-root
DIGI_START         = startapp.sh
DOCKER_FILE        = Dockerfile

DIGIKAM_PUBLIC_KEY = C2386E50
DIGIKAM            = digikam-$(version)-x86-64.appimage
DIGIKAM_URI        = https://download.kde.org/stable/digikam/$(version)/${DIGIKAM}

ZLIB_PUBLIC_KEY    = A16C640F
ZLIB               = zlib-$(zlib_version).tar.gz
ZLIB_URI           = https://ayera.dl.sourceforge.net/project/libpng/zlib/$(zlib_version)/$(ZLIB)

REGISTRY           = rpufky
FULL_VERSION       = $(version).$(container)
TAGS_FULL          = $(REGISTRY)/digikam:$(FULL_VERSION)
TAGS_MAJOR         = $(REGISTRY)/digikam:$(version)
TAGS_STABLE        = $(REGISTRY)/digikam:stable
TAGS_LATEST        = $(REGISTRY)/digikam:latest

help:
	@echo "USAGE:"
	@echo "  make digikam [version=$(version)] [container=$(container)] [zlib_version=$(zlib_version)]"
	@echo "        Build digikam docker container with specified values."
	@echo
	@echo "  make stable [version=$(version)] [container=$(container)] [zlib_version=$(zlib_version)]"
	@echo "        Tags completed build as stable with specified values."
	@echo
	@echo "  make latest [version=$(version)] [container=$(container)] [zlib_version=$(zlib_version)]"
	@echo "        Tags completed build as latest with specified values."
	@echo
	@echo "  make clean"
	@echo "        Removes all build artifacts on filesystem. Does NOT remove docker images."
	@echo
	@echo "  make clean_staging"
	@echo "        Removes ONLY staging artifacts on filesystem. Does not remove downloaded files."
	@echo
	@echo "  make all_clean"
	@echo "        Removes all build artifacts and all docker images matching $(REGISTRY)/digikam."
	@echo
	@echo "OPTIONS:"
	@echo "  version: Digikam release version to build from. Default: $(version)."
	@echo
	@echo "  container: Docker container point revision. Default: $(version).$(container)"
	@echo
	@echo "  zlib: zlib release version to package with Digikam. Default: $(zlib_version)."

.PHONY: help Makefile

digikam: appimage zlib extract staging docker_build

docker_build:
	@echo 'Building docker container version:$(FULL_VERSION) using digikam:$(version), zlib:$(zlib_version)'
	@cd $(STAGING_DIR) && \
	 docker build \
     --build-arg digikam_version="Digikam $(version)" \
     -t $(TAGS_FULL) \
     -t $(TAGS_MAJOR) \
     .

stable: digikam
	@echo 'Tagging docker container version:$(FULL_VERSION) using digikam:$(version) as stable'
	@docker image tag $(TAGS_MAJOR) $(TAGS_STABLE)

latest: digikam
	@echo 'Tagging docker container version:$(FULL_VERSION) using digikam:$(version) as stable'
	@docker image tag $(TAGS_MAJOR) $(TAGS_LATEST)

staging:
	@echo 'Staging build for Dockerfile consumption ...'
	@rm -rfv $(STAGING_DIR) || exit 0
	@mkdir -p $(STAGING_DIR) $(DOCKER_STAGING)
	@cp -av $(DIGI_START) $(STAGING_DIR)
	@cp -av $(DOCKER_FILE) $(STAGING_DIR)
	@cp -av $(DIGI_BUILD) $(STAGING_DIR)

extract:
	@echo 'Extracting packages ...'
	@mkdir -p $(BUILD_DIR)/$(version)
	@test ! -d $(DIGI_BUILD) && \
	 cd $(BUILD_DIR)/$(version) && \
	 ../$(DIGIKAM) --appimage-extract || exit 0 && \
	 cd -
	@cp -v $(BUILD_DIR)/$(DIGIKAM).sig $(DIGI_BUILD)
	@test ! -d $(DIGI_BUILD)/zlib-$(zlib_version) && \
   tar -xvf $(BUILD_DIR)/$(ZLIB) --directory $(DIGI_BUILD) || exit 0
	@cp -v $(BUILD_DIR)/$(ZLIB).asc $(DIGI_BUILD)
	@chmod o=u -Rv $(DIGI_BUILD)

appimage:
	@echo 'Downloading and verifying Digikam $(version) AppImage ...'
	@mkdir -p $(BUILD_DIR) $(GPG_DIR)
	@chmod 0700 $(GPG_DIR)
	@test ! -f $(BUILD_DIR)/$(DIGIKAM) && \
   wget --directory-prefix=$(BUILD_DIR)	$(DIGIKAM_URI) || exit 0
	@test ! -f $(BUILD_DIR)/$(DIGIKAM).sig && \
   wget --directory-prefix=$(BUILD_DIR) $(DIGIKAM_URI).sig || exit 0
	@gpg --homedir $(GPG_DIR) --keyserver keys.gnupg.net --recv-keys $(DIGIKAM_PUBLIC_KEY)
	@gpg --homedir $(GPG_DIR) --verify $(BUILD_DIR)/$(DIGIKAM).sig $(BUILD_DIR)/$(DIGIKAM)
	@chmod +x $(BUILD_DIR)/$(DIGIKAM)

zlib:
	@echo 'Downloading and verifying zlib $(zlib_version) dependency ...'
	@mkdir -p $(BUILD_DIR) $(GPG_DIR)
	@test ! -f $(BUILD_DIR)/$(ZLIB) && \
   wget --directory-prefix=$(BUILD_DIR)	$(ZLIB_URI) || exit 0
	@test ! -f $(BUILD_DIR)/$(ZLIB).asc && \
   wget --directory-prefix=$(BUILD_DIR) $(ZLIB_URI).asc || exit 0
	@gpg --homedir $(GPG_DIR) --keyserver keys.gnupg.net --recv-keys $(ZLIB_PUBLIC_KEY)
	@gpg --homedir $(GPG_DIR) --verify $(BUILD_DIR)/$(ZLIB).asc $(BUILD_DIR)/$(ZLIB)

clean:
	@echo 'Cleaning build directories ...'
	@rm -rfv "$(BUILD_DIR)"

clean_staging:
	@echo 'Cleaning ONLY staging directories ...'
	@rm -rfv "$(STAGING_DIR)"

all_clean: clean
	@echo 'Removing $(REGISTRY)/digikam images ...'
	@docker rmi -f `docker images --filter=reference=$(REGISTRY)/digikam --format '{{.ID}}'` || exit 0

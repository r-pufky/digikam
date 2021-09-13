# Makefile for digikam docker containers.
#
# Public Keys
#   Digikam: http://keys.gnupg.net/pks/lookup?search=digikamdeveloper%40gmail.com&fingerprint=on
#
# TODO: De-duplicate stable/unstable and finish simplifying build options.
#
version            = 7.3.0
pre_release        = 7.3.0
BUILD_DIR          = digikam-build
STAGING_DIR        = $(BUILD_DIR)/staging
GPG_DIR            = $(BUILD_DIR)/gpg
GPG_KEYSERVER      = pool.sks-keyservers.net
DIGI_BUILD         = $(BUILD_DIR)/$(version)/squashfs-root
PRE_DIGI_BUILD     = $(BUILD_DIR)/$(pre_release)/squashfs-root
DIGI_START         = startapp.sh
DOCKER_FILE        = Dockerfile

DIGIKAM_PUBLIC_KEY = C2386E50
DIGIKAM            = digiKam-$(version)-x86-64.appimage
PRE_DIGIKAM        = digiKam-$(pre_release)-x86-64.appimage
DIGIKAM_URI        = https://download.kde.org/stable/digikam/$(version)/${DIGIKAM}
PRE_DIGIKAM_URI    = https://download.kde.org/unstable/digikam/${PRE_DIGIKAM}

REGISTRY           = rpufky
TAGS_MAJOR         = $(REGISTRY)/digikam:$(version)
TAGS_PRE           = $(REGISTRY)/digikam:$(pre_release)
TAGS_STABLE        = $(REGISTRY)/digikam:stable
TAGS_LATEST        = $(REGISTRY)/digikam:latest

help:
	@echo "USAGE:"
	@echo "  make digikam[_no_gpg] [version=$(version)]"
	@echo "        Build digikam docker container with specified values."
	@echo
	@echo "  make stable [version=$(version)]"
	@echo "        Tags completed build as stable with specified values."
	@echo
	@echo "  make latest [version=$(version)]"
	@echo "        Tags completed build as latest with specified values."
	@echo
	@echo "  digkam, stable, latest may be used with _no_gpg (digikam_no_gpg)"
	@echo "  to disable GPG verification during build. Occasionally digikam GPG"
	@echo "  certs will not be updated on time and cause build to fail."
	@echo
	@echo "  make pre_release"
	@echo "        Uses static pre_release: $(pre_release) build, tags as latest."
	@echo "        Build is nevered verifed against GPG."
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

.PHONY: help Makefile

digikam: appimage verify extract staging docker_build
digikam_no_gpg: appimage extract staging docker_build

stable: digikam
	@echo 'Tagging docker container digikam:$(version) as stable'
	@docker image tag $(TAGS_MAJOR) $(TAGS_STABLE)
	@echo 'Remember to Verify container, then push to docker hub: docker push $(TAGS_STABLE)'

stable_no_gpg: digikam_no_gpg
	@echo 'Tagging docker container digikam:$(version) as stable'
	@docker image tag $(TAGS_MAJOR) $(TAGS_STABLE)
	@echo 'Remember to Verify container, then push to docker hub: docker push $(TAGS_STABLE)'

latest: digikam
	@echo 'Tagging docker container digikam:$(version) as latest'
	@docker image tag $(TAGS_MAJOR) $(TAGS_LATEST)
	@echo 'Remember to Verify container, then push to docker hub: docker push $(TAGS_LATEST)'

latest_no_gpg: digikam_no_gpg
	@echo 'Tagging docker container digikam:$(version) as latest'
	@docker image tag $(TAGS_MAJOR) $(TAGS_LATEST)
	@echo 'Remember to Verify container, then push to docker hub: docker push $(TAGS_LATEST)'

pre_release: appimage_unstable extract_unstable staging_unstable docker_build_unstable
	@echo 'Tagging docker container digikam:$(pre_release) as latest'
	@docker image tag $(TAGS_PRE) $(TAGS_LATEST)
	@echo 'Remember to Verify container, then push to docker hub: docker push $(TAGS_LATEST)'

docker_build:
	@echo 'Building docker container version:$(version)'
	@cd $(STAGING_DIR) && \
	 docker build \
     --build-arg digikam_version="Digikam $(version)" \
     -t $(TAGS_MAJOR) \
     .
	@echo 'Remember to Verify container, then push to docker hub: docker push $(TAGS_MAJOR)'

docker_build_unstable:
	@echo 'Building docker container version:$(pre_release)'
	@cd $(STAGING_DIR) && \
	 docker build \
     --build-arg digikam_version="Digikam $(pre_release)" \
     -t $(TAGS_PRE) \
     .

staging:
	@echo 'Staging build for Dockerfile consumption ...'
	@rm -rfv $(STAGING_DIR) || exit 0
	@mkdir -p $(STAGING_DIR) $(DOCKER_STAGING)
	@cp -av $(DIGI_START) $(STAGING_DIR)
	@cp -av $(DOCKER_FILE) $(STAGING_DIR)
	@cp -av $(DIGI_BUILD) $(STAGING_DIR)

staging_unstable:
	@echo 'Staging build for Dockerfile consumption ...'
	@rm -rfv $(STAGING_DIR) || exit 0
	@mkdir -p $(STAGING_DIR) $(DOCKER_STAGING)
	@cp -av $(DIGI_START) $(STAGING_DIR)
	@cp -av $(DOCKER_FILE) $(STAGING_DIR)
	@cp -av $(PRE_DIGI_BUILD) $(STAGING_DIR)

extract:
	@echo 'Extracting packages ...'
	@chmod +x $(BUILD_DIR)/$(DIGIKAM)
	@mkdir -p $(BUILD_DIR)/$(version)
	@test ! -d $(DIGI_BUILD) && \
	 cd $(BUILD_DIR)/$(version) && \
	 ../$(DIGIKAM) --appimage-extract || exit 0 && \
	 cd -
	@cp -v $(BUILD_DIR)/$(DIGIKAM).sig $(DIGI_BUILD)
	@chmod o=u -Rv $(DIGI_BUILD)

extract_unstable:
	@echo 'Extracting packages ...'
	@mkdir -p $(BUILD_DIR)/$(pre_release)
	@test ! -d $(PRE_DIGI_BUILD) && \
	 cd $(BUILD_DIR)/$(pre_release) && \
	 ../$(PRE_DIGIKAM) --appimage-extract || exit 0 && \
	 cd -
	@cp -v $(BUILD_DIR)/$(PRE_DIGIKAM).sig $(PRE_DIGI_BUILD)
	@chmod o=u -Rv $(PRE_DIGI_BUILD)

appimage:
	@echo 'Downloading and verifying Digikam $(version) AppImage ...'
	@mkdir -p $(BUILD_DIR) $(GPG_DIR)
	@chmod 0700 $(GPG_DIR)
	@test ! -f $(BUILD_DIR)/$(DIGIKAM) && \
   wget --directory-prefix=$(BUILD_DIR)	$(DIGIKAM_URI) || exit 0
	@test ! -f $(BUILD_DIR)/$(DIGIKAM).sig && \
   wget --directory-prefix=$(BUILD_DIR) $(DIGIKAM_URI).sig || exit 0

verify:
	@echo 'Validating Digikam appimage ...'
	@gpg --homedir $(GPG_DIR) --keyserver $(GPG_KEYSERVER) --recv-keys $(DIGIKAM_PUBLIC_KEY)
	@gpg --homedir $(GPG_DIR) --keyserver $(GPG_KEYSERVER) --verify $(BUILD_DIR)/$(DIGIKAM).sig $(BUILD_DIR)/$(DIGIKAM)

appimage_unstable:
	@echo 'Downloading and verifying Digikam $(pre_release) AppImage from unstable ...'
	@mkdir -p $(BUILD_DIR) $(GPG_DIR)
	@chmod 0700 $(GPG_DIR)
	@test ! -f $(BUILD_DIR)/$(PRE_DIGIKAM) && \
   wget --directory-prefix=$(BUILD_DIR)	$(PRE_DIGIKAM_URI) || exit 0
	@test ! -f $(BUILD_DIR)/$(PRE_DIGIKAM).sig && \
   wget --directory-prefix=$(BUILD_DIR) $(PRE_DIGIKAM_URI).sig || exit 0
	@chmod +x $(BUILD_DIR)/$(PRE_DIGIKAM)

clean:
	@echo 'Cleaning build directories ...'
	@rm -rfv "$(BUILD_DIR)"

clean_staging:
	@echo 'Cleaning ONLY staging directories ...'
	@rm -rfv "$(STAGING_DIR)"

all_clean: clean
	@echo 'Removing $(REGISTRY)/digikam images ...'
	@docker rmi -f `docker images --filter=reference=$(REGISTRY)/digikam --format '{{.ID}}'` || exit 0

SASS=sass
SASSFLAGS=--no-source-map
GLIB_COMPILE_RESOURCES=glib-compile-resources
RES_DIR=gtk-3.0
SCSS_DIR=$(RES_DIR)/scss
DIST_DIR=$(RES_DIR)/dist
RES_DIR320=gtk-3.20
SCSS_DIR320=$(RES_DIR320)/scss
DIST_DIR320=$(RES_DIR320)/dist
INSTALL_DIR=$(DESTDIR)/usr/share/themes/Numix

all: clean gresource

css:
	$(SASS) --update $(SASSFLAGS) $(SCSS_DIR):$(DIST_DIR)
	$(SASS) --update $(SASSFLAGS) $(SCSS_DIR320):$(DIST_DIR320)

gresource: css
	$(GLIB_COMPILE_RESOURCES) --sourcedir=$(RES_DIR) $(RES_DIR)/gtk.gresource.xml
	$(GLIB_COMPILE_RESOURCES) --sourcedir=$(RES_DIR320) $(RES_DIR320)/gtk.gresource.xml

watch: clean
	while true; do \
		make gresource; \
		inotifywait @gtk.gresource -qr -e modify -e create -e delete $(RES_DIR); \
	done

clean:
	rm -rf $(DIST_DIR)
	rm -f $(RES_DIR)/gtk.gresource
	rm -rf $(DIST_DIR320)
	rm -f $(RES_DIR320)/gtk.gresource

install: all
	install -d -m755 $(INSTALL_DIR)

	for f in *; do cp -pr $$f $(INSTALL_DIR)/; done

uninstall:
	rm -rf $(INSTALL_DIR)

.PHONY: all
.PHONY: css
.PHONY: watch
.PHONY: gresource
.PHONY: clean
.PHONY: install
.PHONY: uninstall

.DEFAULT_GOAL := all

# vim: set ts=4 sw=4 tw=0 noet :

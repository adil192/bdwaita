.PHONY: download patch build install clean purge

download: build/unpatched

patch: build/patched

build: build/output/gnome-shell/gnome-shell.css

install: build
	mkdir -p ~/.local/share/themes/bdwaita/
	cp -r build/output/* ~/.local/share/themes/bdwaita/
	dconf write /org/gnome/shell/extensions/user-theme/name "'bdwaita'"
	dconf write /org/gnome/desktop/interface/gtk-theme "'bdwaita'"

clean:
	rm -rf build/patched build/output

purge:
	rm -rf build/

# internal targets...

# Clone upstream repositories
build/upstream/gnome-shell/README.md:
	mkdir -p build/upstream/
	rm -rf build/upstream/gnome-shell
	git clone https://gitlab.gnome.org/GNOME/gnome-shell.git build/upstream/gnome-shell -b gnome-48
build/upstream/gtk-4.0/README.md:
	mkdir -p build/upstream/
	rm -rf build/upstream/gtk-4.0
	git clone https://gitlab.gnome.org/GNOME/gtk.git build/upstream/gtk-4.0 -b gtk-4-18
build/upstream/gtk-3.0/README.md:
	mkdir -p build/upstream/
	rm -rf build/upstream/gtk-3.0
	git clone https://gitlab.gnome.org/GNOME/gtk.git build/upstream/gtk-3.0 -b gtk-3-24

# Prepare the build/unpatched directory structure ready to be patched
build/unpatched: build/upstream/gnome-shell/README.md build/upstream/gtk-4.0/README.md build/upstream/gtk-3.0/README.md
	mkdir -p build/unpatched
	cp -r build/upstream/gnome-shell/data/theme build/unpatched/gnome-shell
	cp -r build/upstream/gtk-4.0/gtk/theme/Default build/unpatched/gtk-4.0
	cp -r build/upstream/gtk-3.0/gtk/theme/Adwaita build/unpatched/gtk-3.0

build/patched: build/unpatched
	rm -rf build/patched build/output
	cp -r build/unpatched build/patched
	cp src/index.theme build/patched/
	./src/patch_colors.sh

SILENCE_DEPRECATION = slash-div,mixed-decls,color-functions,global-builtin,import,strict-unary
build/output/gnome-shell/gnome-shell.css: build/patched
	rm -rf build/output
	cp -r build/patched build/output

	for file in build/output/gnome-shell/*.scss; do \
		echo "Building $$file"; \
		sass --no-source-map --load-path build/output/gnome-shell/gnome-shell-sass/ --silence-deprecation=${SILENCE_DEPRECATION} "$$file" "$${file%.scss}.css"; \
	done
	cp build/output/gnome-shell/gnome-shell-dark.css build/output/gnome-shell/gnome-shell.css
	rm -rf build/output/gnome-shell/*.scss
	rm -rf build/output/gnome-shell/gnome-shell-sass

	for file in build/output/gtk-4.0/*.scss; do \
	    [[ "$$(basename "$$file")" == _* ]] && continue; \
		echo "Building $$file"; \
		sass --no-source-map --silence-deprecation=${SILENCE_DEPRECATION} "$$file" "$${file%.scss}.css"; \
	done
	rm -rf build/output/gtk-4.0/*.scss
	cp build/output/gtk-4.0/Default-light.css build/output/gtk-4.0/gtk.css
	cp build/output/gtk-4.0/Default-light.css build/output/gtk-4.0/gtk-light.css
	cp build/output/gtk-4.0/Default-dark.css build/output/gtk-4.0/gtk-dark.css
	cp build/output/gtk-4.0/Default-hc.css build/output/gtk-4.0/gtk-hc.css
	cp build/output/gtk-4.0/Default-hc-dark.css build/output/gtk-4.0/gtk-hc-dark.css

	for file in build/output/gtk-3.0/*.scss; do \
	    [[ "$$(basename "$$file")" == _* ]] && continue; \
		echo "Building $$file"; \
		sass --no-source-map --silence-deprecation=${SILENCE_DEPRECATION} "$$file" "$${file%.scss}.css"; \
	done
	rm -rf build/output/gtk-3.0/*.scss

	rm -rf build/output/**/meson.build

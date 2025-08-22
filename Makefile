.PHONY: download patch build install clean purge

download: build/unpatched

patch: build/patched

build: build/output-dark/gtk-3.0/gtk.css

install: build
	# Removing old themes if they exist...
	rm -rf ~/.local/share/themes/bdwaita/
	rm -rf ~/.local/share/themes/bdwaita-dark/

	# Installing bdwaita theme...
	mkdir -p ~/.local/share/themes/bdwaita/
	cp -r build/output/* ~/.local/share/themes/bdwaita/
	mkdir -p ~/.local/share/themes/bdwaita-dark/
	cp -r build/output-dark/* ~/.local/share/themes/bdwaita-dark/

	# Enabling bdwaita theme...
	dconf write /org/gnome/shell/extensions/user-theme/name "'bdwaita'"
	dconf write /org/gnome/desktop/interface/gtk-theme "'bdwaita'"
	dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunrise "'dconf write /org/gnome/desktop/interface/gtk-theme \"\'bdwaita\'\"'"
	dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunset "'dconf write /org/gnome/desktop/interface/gtk-theme \"\'bdwaita-dark\'\"'"

clean:
	rm -rf build/patched build/output build/output-dark

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
build/output/gtk-3.0/gtk.css: build/patched
	rm -rf build/output build/output-dark
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
	mv build/output/gtk-4.0/Default-light.css build/output/gtk-4.0/gtk-light.css
	mv build/output/gtk-4.0/Default-dark.css build/output/gtk-4.0/gtk-dark.css
	mv build/output/gtk-4.0/Default-hc.css build/output/gtk-4.0/gtk-hc.css
	mv build/output/gtk-4.0/Default-hc-dark.css build/output/gtk-4.0/gtk-hc-dark.css
	# Setting gtk-light.css as the default gtk.css
	cp build/output/gtk-4.0/gtk-light.css build/output/gtk-4.0/gtk.css

	for file in build/output/gtk-3.0/*.scss; do \
	    [[ "$$(basename "$$file")" == _* ]] && continue; \
		echo "Building $$file"; \
		sass --no-source-map --silence-deprecation=${SILENCE_DEPRECATION} "$$file" "$${file%.scss}.css"; \
	done
	rm -rf build/output/gtk-3.0/*.scss

	rm -rf build/output/**/meson.build

build/output-dark/gtk-3.0/gtk.css: build/output/gtk-3.0/gtk.css
	rm -rf build/output-dark
	cp -r build/output build/output-dark
	rm -rf build/output-dark/gnome-shell
	cp build/output-dark/gtk-4.0/gtk-dark.css build/output-dark/gtk-4.0/gtk.css
	cp build/output-dark/gtk-3.0/gtk-dark.css build/output-dark/gtk-3.0/gtk.css
	sed -i -e 's/Bdwaita/Bdwaita-dark/g' -e 's/bdwaita/bdwaita-dark/g' build/output-dark/index.theme

.PHONY: download patch build clean

download: build/original

patch: build/patched

build: build/built/gnome-shell.css

install: build
	mkdir -p ~/.local/share/themes/custom-adwaita/gnome-shell/
	cp -r build/built/* ~/.local/share/themes/custom-adwaita/gnome-shell/
	gsettings set org.gnome.shell.extensions.user-theme name 'custom-adwaita'

clean:
	rm -rf build/

build/original:
	mkdir -p build/
	git -C build/gnome-shell pull || git clone https://gitlab.gnome.org/GNOME/gnome-shell.git build/gnome-shell -b gnome-48
	rm -rf build/original
	cp -r build/gnome-shell/data/theme build/original

build/patched: build/original
	rm -rf build/patched
	cp -r build/original build/patched
	./scripts/patch_colors.sh

build/built/gnome-shell.css: build/patched
	rm -rf build/built
	cp -r build/patched build/built
	for file in build/built/*.scss; do \
		sass --no-source-map --load-path build/built/gnome-shell-sass/ --silence-deprecation=slash-div,mixed-decls,color-functions,global-builtin,import "$$file" "$${file%.scss}.css"; \
	done
	cp build/built/gnome-shell-dark.css build/built/gnome-shell.css
	rm -rf build/built/*.scss
	rm -rf build/built/gnome-shell-sass
	rm -rf build/built/meson.build

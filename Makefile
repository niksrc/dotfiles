SHELL := bash

.PHONY: all
all: etc dotfiles bin

.PHONY: bin
bin: ## Installs the bin directory files.
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done

.PHONY: dotfiles 
dotfiles: ## Installs dotfiles.
	stow git --target=$(HOME) --dotfiles
	stow .config --target=$(HOME)/.config
	stow --verbose  bash --target=$(HOME)
	
	mkdir -p $(HOME)/.local/share;
	ln -snf $(CURDIR)/.fonts $(HOME)/.local/share/fonts;
	fc-cache -f -v || true

.PHONY: etc 
etc: ## Installs etc configs
	sudo stow --verbose  etc --target=/etc
	systemctl --user daemon-reload || true
	sudo systemctl daemon-reload
	sudo systemctl enable systemd-networkd systemd-resolved
	sudo systemctl start systemd-networkd systemd-resolved

.PHONY: test
test: shellcheck

.PHONY: shellcheck
shellcheck:
	./test.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

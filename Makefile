SHELL := bash

.PHONY: dotfiles

## Installs dotfiles.
dotfiles: 
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not name -not -name ".github" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	ln -fn $(CURDIR)/gitignore $(HOME)/.gitignore;
	
	mkdir -p $(HOME)/.local/share;	
	ln -snf $(CURDIR)/.fonts $(HOME)/.local/share/fonts;
	fc-cache -f -v || true
	
	mkdir -p $(HOME)/.config;
	ln -snf $(CURDIR)/.config/i3 $(HOME)/.config/i3




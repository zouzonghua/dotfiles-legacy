SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

GIT_DIR := $(HOME)/.config/git
TMUX_DIR := $(HOME)/.config/tmux
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc

.PHONY: git tmux ssh vim all

all: git tmux ssh vim

define link_file
	@if [ -e $(2) ] && [ ! -L $(2) ]; then \
		echo "backup $(2)"; \
		mv $(2) $(2).backup; \
	fi
	@ln -sfn $(1) $(2)
endef

git:
	@mkdir -p $(GIT_DIR)
	$(call link_file,$(DOTFILES)/git/config,$(GIT_DIR)/config)
	$(call link_file,$(DOTFILES)/git/work,$(GIT_DIR)/work)
	$(call link_file,$(DOTFILES)/git/personal,$(GIT_DIR)/personal)

tmux:
	@mkdir -p $(TMUX_DIR)
	$(call link_file,$(DOTFILES)/tmux/tmux.conf,$(TMUX_DIR)/tmux.conf)
	$(call link_file,$(DOTFILES)/tmux/conf,$(TMUX_DIR)/conf)
	$(call link_file,$(DOTFILES)/tmux/scripts,$(TMUX_DIR)/scripts)

ssh:
	@mkdir -p $(SSH_DIR)
	$(call link_file,$(DOTFILES)/ssh/config,$(SSH_DIR)/config)
	@if [ -f $(SSH_DIR)/config ]; then chmod 600 $(SSH_DIR)/config; fi

vim:
	$(call link_file,$(DOTFILES)/vim/.vimrc,$(VIMRC))

SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

GIT_DIR := $(HOME)/.config/git
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc

.PHONY: git ssh vim all

all: git ssh vim

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

ssh:
	@mkdir -p $(SSH_DIR)
	$(call link_file,$(DOTFILES)/ssh/config,$(SSH_DIR)/config)
	@if [ -f $(SSH_DIR)/config ]; then chmod 600 $(SSH_DIR)/config; fi

vim:
	$(call link_file,$(DOTFILES)/vim/.vimrc,$(VIMRC))
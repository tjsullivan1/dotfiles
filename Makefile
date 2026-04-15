# Linux Environment Setup — Idempotent Makefile
# Usage:
#   make setup          # run all steps
#   make install-kubectl # run one step
#   make install-helm    # run one step
#   make install-azure-cli # run one step
#   make install-terraform # run one step
#
# Each target uses a sentinel file in .make/ so it only runs once.
# To force a re-run:  make clean-kubectl install-kubectl
# To nuke all state:  make clean

SHELL := /bin/bash
.DEFAULT_GOAL := help

STAMP_DIR := .make
$(shell mkdir -p $(STAMP_DIR))

MAKEFILE_RAW_URL := https://raw.githubusercontent.com/tjsullivan1/dotfiles/refs/heads/main/Makefile

#############################################################################
# Top Level
.PHONY: help setup status clean update self-update

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: update install-kubectl install-helm install-azure-cli install-terraform install-copilot install-gh configure-zsh install-python ## Install required
	@sudo update-alternatives --set editor /usr/bin/vim.basic
	@curl -o "$$HOME/.bashrc" https://raw.githubusercontent.com/tjsullivan1/dotfiles/refs/heads/main/.bashrc;
	@curl -o "$$HOME/.bash_aliases" https://raw.githubusercontent.com/tjsullivan1/dotfiles/refs/heads/main/.bash_aliases;
	@curl -o "$$HOME/.gitconfig" https://raw.githubusercontent.com/tjsullivan1/dotfiles/refs/heads/main/.gitconfig;
	@curl -o "$$HOME/.vimrc" https://raw.githubusercontent.com/tjsullivan1/dotfiles/refs/heads/main/.vimrc;

status: ## Show what is currently installed
	@echo "── Installed versions ──";
	@command -v zsh    >/dev/null 2>&1 && zsh --version 2>/dev/null || echo "zsh: not installed";
	@command -v copilot >/dev/null 2>&1 && copilot --version 2>/dev/null || echo "copilot: not installed";
	@command -v gh     >/dev/null 2>&1 && gh --version 2>/dev/null | head -1 || echo "gh cli: not installed";
	@command -v kubectl    >/dev/null 2>&1 && kubectl version --client 2>/dev/null || echo "kubectl: not installed";
	@command -v helm       >/dev/null 2>&1 && helm version 2>/dev/null             || echo "helm: not installed";
	@command -v terraform  >/dev/null 2>&1 && terraform version -json 2>/dev/null | head -1 || echo "terraform: not installed";
	@command -v az         >/dev/null 2>&1 && az version --output table 2>/dev/null        || echo "az cli: not installed";
	@command -v python     >/dev/null 2>&1 && python --version 2>/dev/null || echo "Python: not installed";

update: ## Run OS updates
	@sudo apt update -y;
	@sudo apt upgrade -y;

self-update: ## Replace this Makefile with latest from GitHub (requires curl)
	@set -euo pipefail; \
	url="$(MAKEFILE_RAW_URL)"; \
	tmp="$$(mktemp)"; \
	echo "Downloading $$url ..."; \
	curl -fsSL "$$url" -o "$$tmp"; \
	if ! grep -q "^# Linux Environment Setup" "$$tmp"; then \
		echo "Downloaded file does not look like expected Makefile; aborting"; \
		rm -f "$$tmp"; \
		exit 1; \
	fi; \
	cp "$$tmp" "$(firstword $(MAKEFILE_LIST))"; \
	rm -f "$$tmp"; \
	echo "Makefile updated. Re-run your command.";

clean: ## Remove all sentinel stamps (does NOT uninstall software)
	rm -rf $(STAMP_DIR)

#############################################################################
# Python Configuration
.PHONY: install-python install-uv clean-python

install-python: install-uv $(STAMP_DIR)/python

$(STAMP_DIR)/python:
	@echo "Ensuring Python 3 and pip are installed...";
	@sudo apt install -y python3 python3-pip python-is-python3;
	@touch $@;

install-uv: $(STAMP_DIR)/uv

$(STAMP_DIR)/uv:
	@curl -LsSf https://astral.sh/uv/install.sh | sh

clean-python:
	rm -f $(STAMP_DIR)/python
	rm -f $(STAMP_DIR)/uv

#############################################################################
# GitHub CLI
.PHONY: install-gh clean-gh

install-gh: $(STAMP_DIR)/gh

$(STAMP_DIR)/gh:
	@if command -v gh >/dev/null 2>&1; then \
		echo "gh already installed: $$(gh --version 2>/dev/null | head -1 || echo installed)"; \
	else \
		echo "Installing GitHub CLI (gh)..."; \
		sudo apt-get update -y; \
		sudo apt-get install -y curl; \
		type -p wget >/dev/null || sudo apt-get install -y wget; \
		sudo mkdir -p -m 755 /etc/apt/keyrings; \
		wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null; \
		sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
		echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null; \
		sudo apt-get update -y; \
		sudo apt-get install -y gh; \
		if ! command -v gh >/dev/null 2>&1; then \
			echo "gh install did not produce a 'gh' binary in PATH"; \
			exit 1; \
		fi; \
	fi
	@touch $@

clean-gh:
	rm -f $(STAMP_DIR)/gh

#############################################################################
# Copilot
.PHONY: install-copilot clean-copilot

install-copilot: $(STAMP_DIR)/copilot

$(STAMP_DIR)/copilot:
	@if command -v copilot >/dev/null 2>&1; then \
		echo "copilot already installed: $$(copilot --version 2>/dev/null || echo installed)"; \
	else \
		echo "Installing Copilot CLI..."; \
		curl -fsSL https://gh.io/copilot-install | bash; \
		if ! command -v copilot >/dev/null 2>&1; then \
			echo "copilot install did not produce a 'copilot' binary in PATH"; \
			exit 1; \
		fi; \
	fi
	@touch $@

clean-copilot:
	rm -f $(STAMP_DIR)/copilot

# ... (rest of your existing Makefile continues unchanged)

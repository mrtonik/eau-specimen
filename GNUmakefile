# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
#
# Top-level GNUmakefile for eau-specimen — builds all specimen apps.
#
# Each subdirectory is a standalone GNUstep application that links against
# the shared SpecimenKit sources via direct compilation (no separate library).
#
# Usage:
#   gmake          — build all apps
#   gmake clean    — clean all apps
#   gmake install  — install all apps
#   gmake APP=N    — build only the app in subdirectory N
#

# ---- apps (order is unimportant; each is self-contained) ----
SPECIMEN_APPS = \
	Buttons \
	Chrome \
	Containers \
	Dialogs \
	Extras \
	Lists \
	Menus \
	Range \
	TextInput \
	Windows

# ---- top-level targets ---------------------------------------------------

.PHONY: all clean install $(SPECIMEN_APPS) apps

all:
	@for app in $(SPECIMEN_APPS); do \
		echo "==> Building $$app ..."; \
		$(MAKE) -C "$$app" all || exit 1; \
	done

clean:
	@for app in $(SPECIMEN_APPS); do \
		echo "==> Cleaning $$app ..."; \
		$(MAKE) -C "$$app" clean || exit 1; \
	done

install:
	@for app in $(SPECIMEN_APPS); do \
		echo "==> Installing $$app ..."; \
		$(MAKE) -C "$$app" install || exit 1; \
	done

# ---- per-app targets (invocable individually, e.g. gmake Buttons) -------

$(SPECIMEN_APPS):
	$(MAKE) -C "$@" all

# ---- convenience: print the list of apps --------------------------------

apps:
	@echo $(SPECIMEN_APPS)

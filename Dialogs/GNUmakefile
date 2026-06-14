include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Dialogs
Dialogs_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Dialogs_OBJC_FILES = \
	main.m \
	DialogsController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -I../.. -Wall
Dialogs_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

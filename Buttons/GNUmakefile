include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Buttons
Buttons_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Buttons_OBJC_FILES = \
	main.m \
	ButtonsController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -I../.. -Wall
Buttons_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

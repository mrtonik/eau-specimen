include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Menus
Menus_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Menus_OBJC_FILES = \
	main.m \
	MenusController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -I../.. -Wall
Menus_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Chrome
Chrome_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Chrome_OBJC_FILES = \
	main.m \
	ChromeController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -I../.. -Wall
Chrome_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

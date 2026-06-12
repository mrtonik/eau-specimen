include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Windows
Windows_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Windows_OBJC_FILES = \
	main.m \
	WindowsController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -Wall
Windows_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

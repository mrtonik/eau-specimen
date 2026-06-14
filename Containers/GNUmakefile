include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Containers
Containers_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Containers_OBJC_FILES = \
	main.m \
	ContainersController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -I../.. -Wall
Containers_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

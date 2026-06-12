include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = TextInput
TextInput_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

TextInput_OBJC_FILES = \
	main.m \
	TextInputController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -Wall
TextInput_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make

# _____     ___ ____     ___ ____
#  ____|   |    ____|   |        | |____|
# |     ___|   |____ ___|    ____| |    \    PS2DEV Open Source Project.
#-----------------------------------------------------------------------
# Copyright 2001-2004, ps2dev - http://www.ps2dev.org
# Licenced under Academic Free License version 2.0
# Review ps2sdk README & LICENSE files for further details.
#
# $Id$


IOP_OBJS_DIR = obj/
IOP_BIN_DIR = bin/
IOP_SRC_DIR = src/
IOP_INC_DIR = include/

IOP_BIN  = bin/ps2hdd.irx
IOP_OBJS = obj/misc.o obj/cache.o obj/apa.o obj/journal.o obj/hdd_fio.o obj/hdd.o

IOP_INCS += -I$(PS2SDKSRC)/iop/dev9/poweroff/include/ -I$(PS2SDKSRC)/iop/dev9/dev9/include/ -I$(PS2SDKSRC)/iop/dev9/atad/include/
IOP_CFLAGS  += -Wall -fno-builtin-printf
IOP_LDFLAGS += -s

all: $(IOP_OBJS_DIR) $(IOP_BIN_DIR) $(IOP_BIN)

clean:
	rm -f -r $(IOP_OBJS_DIR) $(IOP_BIN_DIR)

include $(PS2SDKSRC)/Defs.make
include $(PS2SDKSRC)/iop/Rules.make
include $(PS2SDKSRC)/iop/Rules.release

# _____     ___ ____     ___ ____
#  ____|   |    ____|   |        | |____|
# |     ___|   |____ ___|    ____| |    \    PS2DEV Open Source Project.
#-----------------------------------------------------------------------
# Copyright 2001-2004, ps2dev - http://www.ps2dev.org
# Licenced under Academic Free License version 2.0
# Review ps2sdk README & LICENSE files for further details.
#
# $Id: Makefile 1522 2009-01-22 09:48:56Z radad $

IOP_OBJS_DIR = obj/
IOP_BIN_DIR = bin/
IOP_SRC_DIR = src/
IOP_INC_DIR = include/

#DEBUG = 1
#PS2IP_DHCP=1

ifeq ($(DEBUG),1)
DEBUG_FLAGS = -DDEBUG -DLWIP_DEBUG
endif

LWIP=$(PS2SDKSRC)/common/tcpip/lwip-1.4.1

ps2ip_OBJECTS = ps2ip.o ipconfig.o sys.o sys_arch.o init.o exports.o imports.o mem.o netif.o pbuf.o stats.o tcp_in.o tcp_out.o udp.o memp.o tcp.o etharp.o raw.o def.o timers.o

ifdef PS2IP_DHCP
ps2ip_OBJECTS+= dhcp.o
endif

ps2ip_OBJECTS := $(ps2ip_OBJECTS:%=$(IOP_OBJS_DIR)%)

ps2api_OBJECTS = api_lib.o api_msg.o err.o sockets.o tcpip.o netbuf.o
ps2api_OBJECTS := $(ps2api_OBJECTS:%=$(IOP_OBJS_DIR)%)

ps2api_IPV4 = icmp.o ip.o ip_addr.o ip_frag.o inet_chksum.o inet.o
ps2api_IPV4 := $(ps2api_IPV4:%=$(IOP_OBJS_DIR)%)

# Turns DHCP on.
ifdef PS2IP_DHCP
IOP_CFLAGS += -DPS2IP_DHCP
endif

IOP_BIN = bin/ps2ip141.irx
IOP_OBJS = $(ps2ip_OBJECTS) $(ps2api_OBJECTS) $(ps2api_IPV4)
IOP_INCS += -I$(LWIP)/src/include -I$(LWIP)/src/include/ipv4 -Isrc/include
IOP_CFLAGS += -Wall -fno-builtin -DLWIP_NOASSERT -DLWIP_COMPAT_MUTEX $(DEBUG_FLAGS)
IOP_LDFLAGS += -s

all: $(IOP_OBJS_DIR) $(IOP_BIN_DIR) $(IOP_BIN)

clean:
	rm -fr $(IOP_OBJS_DIR) $(IOP_BIN_DIR)

include $(PS2SDKSRC)/Defs.make
include $(PS2SDKSRC)/iop/Rules.make
include $(PS2SDKSRC)/iop/Rules.release

obj/def.o: $(LWIP)/src/core/def.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/init.o: $(LWIP)/src/core/init.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/api_lib.o: $(LWIP)/src/api/api_lib.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/api_msg.o: $(LWIP)/src/api/api_msg.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/icmp.o: $(LWIP)/src/core/ipv4/icmp.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/ip.o: $(LWIP)/src/core/ipv4/ip.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/ip_addr.o: $(LWIP)/src/core/ipv4/ip_addr.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/ip_frag.o: $(LWIP)/src/core/ipv4/ip_frag.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/err.o: $(LWIP)/src/api/err.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/sockets.o: $(LWIP)/src/api/sockets.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/tcpip.o: $(LWIP)/src/api/tcpip.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/inet.o: $(LWIP)/src/core/ipv4/inet.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/inet_chksum.o: $(LWIP)/src/core/ipv4/inet_chksum.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/mem.o: $(LWIP)/src/core/mem.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/memp.o: $(LWIP)/src/core/memp.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/netbuf.o: $(LWIP)/src/api/netbuf.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/netif.o: $(LWIP)/src/core/netif.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/pbuf.o: $(LWIP)/src/core/pbuf.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/stats.o: $(LWIP)/src/core/stats.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/tcp.o: $(LWIP)/src/core/tcp.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/tcp_in.o: $(LWIP)/src/core/tcp_in.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/tcp_out.o: $(LWIP)/src/core/tcp_out.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/sys.o: $(LWIP)/src/core/sys.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/raw.o: $(LWIP)/src/core/raw.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/timers.o: $(LWIP)/src/core/timers.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

obj/etharp.o: $(LWIP)/src/netif/etharp.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

ifdef PS2IP_DHCP
obj/dhcp.o: $(LWIP)/src/core/dhcp.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@
endif

obj/udp.o: $(LWIP)/src/core/udp.c
	$(IOP_CC) $(IOP_CFLAGS) -c $< -o $@

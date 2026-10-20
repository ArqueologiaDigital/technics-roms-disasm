# KN7MENU, the program menu (README.md): the root KN7APP.BIN that KN7LOAD.CNV loads, which lists the programs
# in the SD card's folders and starts the one chosen; and the card that goes with it.
#   make            build/KN7APP.BIN: the menu (guards first: guard.py)
#   make card       build/card/: the whole SD card tree (the menu, Another World, the ROM dumper's passes 5-9),
#                   with build/card.txt (every file, size, SHA-1). Builds Another World from AW_DIR first (its
#                   own Makefile: its guards, its data from ~/compartilhado/MSDOS; nothing of it is committed).
#   make check      png2icon.py's self-test and fatscan.py on the card (what the menu will list)
PYTHON  ?= python3
TOOLS   := ..
LOADER  := ../cnv_romdump
XAPASM  := $(PYTHON) $(TOOLS)/xapasm.py
OUT     ?= build
INC     := -I . -I $(OUT) -I $(LOADER)
# Another World with the launch block support (kn5000-anotherworld, branch launcher-folders, in its worktree
# until it is merged; then AW_DIR=../../../../kn5000-anotherworld/kn7000)
AW_DIR  ?= ../../../../kn5000-anotherworld-menu/kn7000

all: $(OUT)/KN7APP.BIN

$(OUT)/tramp.bin: tramp.s menu.inc $(LOADER)/kn7cnv.inc $(TOOLS)/xapasm.py $(TOOLS)/mn10300_asm.py
	@mkdir -p $(OUT)
	$(XAPASM) tramp.s $(INC) -o $@ -m $(OUT)/tramp.map

$(OUT)/tramp_bin.inc: $(OUT)/tramp.bin mkinc.py
	$(PYTHON) -I mkinc.py $(OUT)/tramp.bin $(OUT)/tramp.map $(OUT) 0x1800

$(OUT)/default_icon.inc: gen_icons.py
	@mkdir -p $(OUT)
	$(PYTHON) -I gen_icons.py --inc $@

$(OUT)/menu.bin: menu.s menu_card.s menu_draw.s menu_data.s menu.inc $(LOADER)/kn7cnv.inc $(LOADER)/font8x13.inc \
                 $(OUT)/tramp_bin.inc $(OUT)/default_icon.inc $(TOOLS)/xapasm.py $(TOOLS)/mn10300_asm.py
	$(XAPASM) menu.s $(INC) -o $@ -m $(OUT)/menu.map

# no address in IC23, the pools or the loader's area but the five service-table loads; no write service named;
# every frame made before a nested call; the memory map inside the converter's RAM (guard.py)
$(OUT)/guard.txt: $(OUT)/menu.bin $(OUT)/tramp.bin guard.py
	$(PYTHON) -I guard.py $(TOOLS) $(LOADER) $(OUT) > $@ || { cat $@; rm -f -- $@; false; }
	@tail -1 $@

$(OUT)/KN7APP.BIN: $(OUT)/menu.bin $(OUT)/guard.txt $(LOADER)/mkapp.py
	$(PYTHON) -I $(LOADER)/mkapp.py $(OUT)/menu.bin $@

card: $(OUT)/KN7APP.BIN mkcard.py gen_icons.py png2icon.py
	$(MAKE) -C $(AW_DIR) sdcard
	$(PYTHON) -I mkcard.py $(OUT)/card $(OUT)/KN7APP.BIN $(AW_DIR)/build/sdcard $(LOADER)/releases $(OUT)/icons
	$(PYTHON) -I fatscan.py $(OUT)/card

check: card
	$(PYTHON) -I png2icon.py --self-test

clean:
	test -n "$(OUT)" && rm -rf -- "$(OUT)"

.PHONY: all card check clean

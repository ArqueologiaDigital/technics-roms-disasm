# The 9 Technics SX-WSA1R diskettes of MAME's wsa1_flop softlist (hash/wsa1_flop.xml).  They are not
# part of the 2026-10-18 rebuild: the images are the softlist's own, zipped in technics_romsets/wsa1_flop/.
# SHA-1 of each <disk>.img (= the softlist's sha1 attribute).
wsa1_LIST    := wsa1_flop
wsa1_ZIPDIR  ?= $(PROJECTS_ROOT)/technics_romsets/wsa1_flop
wsa1_FORMATS := wsa1/formats.py
wsa1_DISKS   := dance demo1 etec giontop gjs1 mcompos myset qsdisk synth
wsa1_SHA1_dance   := 42e4409cdfb9f327d2c0a69905e4028b9bd2eb95
wsa1_SHA1_demo1   := acae531c1ef750d2153a19a83dbc51ce4d36f0bc
wsa1_SHA1_etec    := b647eda8aba42620db3185c4ea3934644cb75285
wsa1_SHA1_giontop := 19c947ee8f3ddc2f5651b85c0226a97fcd3bb3fb
wsa1_SHA1_gjs1    := fa51c6d300801d7c322894cb57c3979b32814049
wsa1_SHA1_mcompos := fcaa6cfddee7606ee132dcb1cd964c5c1997cfb3
wsa1_SHA1_myset   := 0bf2cf2e5de6b304d91d679b592cd51dadb7224a
wsa1_SHA1_qsdisk  := 25647ca46a15b54e04afbf405b091b9d9f35b03d
wsa1_SHA1_synth   := 904d69c1c79a48e7a691180898bc76591a24ca30

# The .TM records are content-addressed include files shared by every disk (wsa1/formats.py,
# describe_tm): start each regeneration from an empty directory so none is left stale.
src-wsa1: | wsa1-tm-clean
.PHONY: wsa1-tm-clean
wsa1-tm-clean:
	rm -rf -- wsa1/include/tm

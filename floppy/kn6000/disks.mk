# The 21 Technics SX-KN6000 diskettes of MAME's kn6000_flop softlist (hash/kn6000_flop.xml),
# as rebuilt on 2026-10-18 (SOFTLIST_DIR/../summary.tsv).  SHA-1 of each <disk>.img.
kn6000_LIST    := kn6000_flop
kn6000_FORMATS := kn6000/formats.py
kn6000_DISKS   := idd6000 ca6000p ca6000s ca6001 ca6002 ca6003 ca6004 ca6005 ca6006 ca6007 ca6008 \
                   ca6009 ca6010 ca6dim ca6fp01 ca6fp02 ca6fp03 ca6fp04 ca6tm01 ca6tm02 scd6000
kn6000_SHA1_idd6000 := b4a3c41e01efd01572e3ab0417fddfac3fba2bbe
kn6000_SHA1_ca6000p := 89cf8fb24b3b3c538425e8b8bdab9f64a2811d3f
kn6000_SHA1_ca6000s := 146edb7eb77c9d8ec088d0e32253f870b2dbd540
kn6000_SHA1_ca6001  := 981dd997ac8221759209c7e81544e5f32bd60a48
kn6000_SHA1_ca6002  := 23b1da8fc7d959b811af4d2240aa77845df181b9
kn6000_SHA1_ca6003  := 6893eb0878f5dcbee936cde9103f161aec01c9bf
kn6000_SHA1_ca6004  := 43597244357a399972cd831609d96a32fffe071d
kn6000_SHA1_ca6005  := def3e86e7effc7ae15e03280941714d365205c0f
kn6000_SHA1_ca6006  := 9067d8b91255f9a565b3c6ead9ec133eec2d177f
kn6000_SHA1_ca6007  := 378b4afeb229197afb043f8aa7aaad72db52cb99
kn6000_SHA1_ca6008  := d0b52e1d4955087ef6b29f6b87877d41cb79da0c
kn6000_SHA1_ca6009  := 0980bce341e64839f8f4b19651a2029e229fd54b
kn6000_SHA1_ca6010  := d2a893801de5846b18d45d6f650ec260d38b92d0
kn6000_SHA1_ca6dim  := 7baaf71e4a70c602ed993a9516291690f885051a
kn6000_SHA1_ca6fp01 := e5f4f3d28ab9cb70621fc17f609f8f707bfeed03
kn6000_SHA1_ca6fp02 := 4326b58202ac4c15b2e113183ec7ea9a2ad4b9ce
kn6000_SHA1_ca6fp03 := 7332bfde10fa1c682c4bdb7387e1b5cb01251402
kn6000_SHA1_ca6fp04 := 971cfee255fda6869e6a91ad40e9214d98c436a8
kn6000_SHA1_ca6tm01 := 49f83a36387d1136300dfba3d2410ea140a46c59
kn6000_SHA1_ca6tm02 := d819cdd2f77197f4b4417a4e72356697200c94fb
kn6000_SHA1_scd6000 := c2c284e38b59bcbc3ac6d6aead515881bbc1d12e

# The .TM records are content-addressed include files shared by every disk (floppy/tools/kd/
# kn_soundram.py): start each regeneration from an empty directory so none is left stale.
src-kn6000: | kn6000-tm-clean
.PHONY: kn6000-tm-clean
kn6000-tm-clean:
	rm -rf -- kn6000/include/tm

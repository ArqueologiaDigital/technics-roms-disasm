# The 14 Technics SX-KN5000 diskettes of MAME's kn5000_flop softlist (hash/kn5000_flop.xml),
# as rebuilt on 2026-10-18 (SOFTLIST_DIR/../summary.tsv).  SHA-1 of each <disk>.img.
kn5000_LIST    := kn5000_flop
kn5000_FORMATS := kn5000/formats.py
kn5000_DISKS   := idd5000 ca5000r ca5000w ca5001 ca5002 ca5003 ca5004 ca5005 ca5006 ca5007 \
                  ca5008 ca5009 ca5010 mix5000
kn5000_SHA1_idd5000 := 948b43b189a7ee1dbd704e739f8bb14f7f32d8aa
kn5000_SHA1_ca5000r := e05f5edd07987cb4aedc8b59e69403b0e555351b
kn5000_SHA1_ca5000w := 58241412ab26fee9c3aee51d4068ac91b8ec4b5b
kn5000_SHA1_ca5001  := da38a409ba6aa4ec0ecb0b7e3245660e495ca76b
kn5000_SHA1_ca5002  := 5bca4583bcd9303b308d270fccd6b9e3b5e06173
kn5000_SHA1_ca5003  := 9f613a9ed4216497fcf3eb9c147f508d85244c2e
kn5000_SHA1_ca5004  := 6557996d75d32c307c7d247157f31134e05ca8bd
kn5000_SHA1_ca5005  := a58bea374f66673a847c35b2410c9f1f54d92002
kn5000_SHA1_ca5006  := 672744721c85f26ad806ff5ea4ca9abb633ff290
kn5000_SHA1_ca5007  := 70c3217103b12943ab6960f08a21d034218a715f
kn5000_SHA1_ca5008  := dc65796efbbdc007e237eb698f99e5d299b1bdc6
kn5000_SHA1_ca5009  := f6eb9a37d37fc2d5cfe6f9c2eda409b32cae5c56
kn5000_SHA1_ca5010  := afad80b7de4cb2ddc75cd4c656a3128cebd768a6
kn5000_SHA1_mix5000 := 4a4ef711a7c97d573bbb4874ae2347e890429a51
# Generated macro file the describers use (the panel record macros, from the firmware's lists).
kn5000_PREGEN  := $(PYTHON) kn5000/panel_fields.py

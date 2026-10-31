# _paths.py -- where the ic21-own probes find their inputs, inside this repository.
#   the chip:        kn7000/baserom/kn7000_ic21_own.bin   (make -C kn7000 baserom/kn7000_ic21_own.bin,
#                    copied from the private read with a SHA-1 check; IC21_OWN_REF= overrides)
#   factory banks:   kn7000/baserom/customdata/<set>.ic21 (make -C kn7000 verify-customdata)
#   initial data:    the files of kn7000/baserom/idd7000.img, the softlist floppy (same make)
#   firmware images: ROMSET_DIR (default ~/compartilhado/technics_romsets/kn7000), EPROM halves
#   KN5000 program:  original_ROMs/kn5000_v10_program.rom (tracked)
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(KN7)
sys.path.insert(0, os.path.join(KN7, "tools"))
sys.path.insert(0, os.path.join(KN7, "tools", "cnv_romdump"))
import fat12_extract  # noqa: E402

IC21 = os.environ.get("IC21_OWN_REF", os.path.join(KN7, "baserom", "kn7000_ic21_own.bin"))
SETS = ["01ctmini", "01custm1", "02custm2", "03custm3", "04custm4", "01custm5", "02custm6", "03custm7", "04custm8"]
ROMSET = os.environ.get("ROMSET_DIR", os.path.expanduser("~/compartilhado/technics_romsets/kn7000"))
KN5000_V10 = os.path.join(REPO, "original_ROMs", "kn5000_v10_program.rom")


def rd(path):
    if not os.path.exists(path):
        sys.exit(f"{path}: missing; run  make -C kn7000 baserom/kn7000_ic21_own.bin verify-customdata  first")
    return open(path, "rb").read()


def chip():
    return rd(IC21)


def factory_sets():
    """The nine factory CUSTOM banks (0x1E0000 bytes each), by name."""
    return {n: rd(os.path.join(KN7, "baserom", "customdata", f"{n}.ic21")) for n in SETS}


def initial_data(name):
    """A file of the Initial Data Disk idd7000 (02UMDINI.MD, 03FAVINI.FAV, 04HPGINI.HMP)."""
    for nm, _size, get in fat12_extract.root_entries(rd(os.path.join(KN7, "baserom", "idd7000.img"))):
        if nm.upper() == name.upper():
            return get()
    sys.exit(f"{name} not on idd7000")


def program(build):
    """Program image of build '893' or '941', interleaved from the romset's EPROM halves."""
    import find_fw
    v = {"893": "v1.3_b893", "941": "v1.6_b941"}[build]
    return find_fw.interleave(rd(f"{ROMSET}/kn7000_program_even_{v}.ic17"), rd(f"{ROMSET}/kn7000_program_odd_{v}.ic16"))


def table80():
    import find_fw
    return find_fw.interleave(rd(f"{ROMSET}/kn7000_table_even_b80.ic17"), rd(f"{ROMSET}/kn7000_table_odd_b80.ic16"))

#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Extract one member from a self-extracting ZIP "disk" (the .exe archives the KN7000
# updates were distributed as, e.g. the SP7001 set's table1_2.exe / table2_2PLUG-iN.exe).
# Never runs the .exe: Python's zipfile reads the archive appended to the stub.
#
# Usage:  sfx_extract.py <archive.exe> <MEMBER> <out>      |   sfx_extract.py <archive.exe> --list
import sys
import zipfile


def main():
    if len(sys.argv) == 3 and sys.argv[2] == "--list":
        for i in zipfile.ZipFile(sys.argv[1]).infolist():
            print(f"{i.filename:14s} {i.file_size:9d}")
        return
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    z = zipfile.ZipFile(sys.argv[1])
    for i in z.infolist():
        if i.filename.upper() == sys.argv[2].upper():
            open(sys.argv[3], "wb").write(z.read(i))
            return
    sys.exit(f"sfx_extract: {sys.argv[2]} not in {sys.argv[1]}")


if __name__ == "__main__":
    main()

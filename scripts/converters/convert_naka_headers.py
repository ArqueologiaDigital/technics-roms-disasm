#!/usr/bin/env python3
"""Convert raw .byte NAKA widget headers to naka_header macro calls.

Replaces patterns like:
    .byte 0xNN, 0x00, 0x60, 0x01, ...remaining...
with:
    naka_header NAKA_TYPE_<ClassName>
    .byte ...remaining...

When the header bytes appear on the same line as body bytes, splits the line:
the macro call goes on its own line, remaining bytes become a new .byte line.

Uses binary I/O to safely handle Latin-1 characters in kn5000_v10_program.s.
"""

import re
import sys
import os
import glob

# Type byte TT of class id 0x016000TT -> the firmware's class name (InitializeRoot's class table,
# scripts/analysis/nakarest_objtab_map.py --classes; v10/maincpu/shared/macros.s defines them all)
ROOT_CLASS_NAMES = (
    'Object', 'Function', 'ApFunction', 'MainFunction', 'Class', 'SupportClass', 'Mode', 'Title',
    'ResBitmap', 'ResFrame', 'ResIcon', 'ResFont', 'ResEvent', 'ResMethod', 'ResString', 'ResName',
    'Viewable', 'VwBox', 'PsParaBox', 'AcLswBox', 'AcTempoBox', 'PsEditBox', 'PsNumEditBox', 'PsTblEditBox',
    'AcOnOffBox', 'AcNumEditBox', 'AcLswEditBox', 'AcRamEditBox', 'PsMenuBox', 'AcTitleMenu', 'PsEditSwBox', 'AcIndexEditSw',
    'AcFuncEditSw', 'PsWideESBox', 'AcIndexWideES', 'AcFuncWideES', 'PsPageBox', 'AcWindowPage', 'PsToggleBox', 'PsInvisibleBox',
    'IvPageControl', 'IvMainEditSw', 'AcSoundName', 'Label', 'Bitmap', 'Icon', 'Line', 'Frame',
    'EditSw', 'Box', 'GroupBox', 'Screen', 'TtlScreen', 'Window', 'TextBox', 'StringBox',
    'ModeEdit', 'TitleEdit', 'AcRhythmName', 'AcPmemName', 'AcMixerVol', 'VwMenuBox', 'VwEditSwBox', 'VwWideESBox',
    'AcModeMenu', 'AcScreenMenu', 'AcWindowMenu', 'AcBitEditBox', 'AcFuncToggle', 'PsWideToggle', 'DbMemo', 'IvExit',
    'IvExitMode', 'IvExitScreen', 'IvFixWin', 'AcNamingWindow', 'PsCursorBox', 'IvNaming', 'AcIndexToggle', 'AcRamBox',
    'PsRadioBox', 'AcStrRadioBox', 'IvCatchEvent', 'PsListBox', 'PsGridBox', 'AcListBox', 'AcGridBox', 'DbDebugMenu',
    'PsTrackSwitch', 'AcTrackSwitch', 'IvDirmdScreen', 'IvTrackSwitch', 'IvExitWindow', 'DbMemoryDump', 'IvInterrupt', 'IvIntReminder',
    'IvIntError', 'IvIntComplete', 'IvIntVari', 'IvIntEasySet', 'IvShowHide', 'PsTextBox', 'AcLanguageText', 'TrTransposeBox',
    'TrChordBox', 'VwUserBitmap', 'IvScreen', 'IvIntWelcome', 'VwUserBitmapByName',
)
NAMED_TYPES = {tt: 'NAKA_TYPE_' + n for tt, n in enumerate(ROOT_CLASS_NAMES)}


def type_name(byte_val):
    """Get the NAKA_TYPE constant name for a given type byte."""
    if byte_val in NAMED_TYPES:
        return NAMED_TYPES[byte_val]
    return f'NAKA_TYPE_0x{byte_val:02X}'


def convert_line(line_bytes):
    """Convert a single line (as bytes). Returns list of output lines (as bytes)."""
    line = line_bytes.decode("latin-1")

    # Match: .byte 0xNN, 0x00, 0x60, 0x01 possibly followed by more bytes
    m = re.search(
        r"(\t)\.byte (0x[0-9a-fA-F]{2}), 0x00, 0x60, 0x01(, .+)?$",
        line
    )
    if not m:
        return [line_bytes]

    indent = m.group(1)
    type_str = m.group(2)
    trailing = m.group(3)  # e.g. ", 0x05, 0x00, 0xff, 0xff" or None
    type_val = int(type_str, 16)
    name = type_name(type_val)

    # Build macro line (preserve any label prefix before the .byte)
    prefix = line[:m.start()]
    macro_line = f"{prefix}{indent}naka_header {name}"

    result = []
    if trailing:
        # Split: macro on one line, remaining bytes on the next
        rest_bytes = trailing[2:]  # remove leading ", "
        result.append(macro_line.encode("latin-1"))
        body_line = f"{indent}.byte {rest_bytes}"
        result.append(body_line.encode("latin-1"))
    else:
        result.append(macro_line.encode("latin-1"))

    return result


def convert_file(filepath):
    """Convert raw NAKA headers in a single file. Returns count of replacements."""
    with open(filepath, 'rb') as f:
        data = f.read()

    lines = data.split(b"\n")
    count = 0
    new_lines = []

    for line_bytes in lines:
        converted = convert_line(line_bytes)
        if len(converted) != 1 or converted[0] != line_bytes:
            count += 1
        new_lines.extend(converted)

    if count > 0:
        with open(filepath, 'wb') as f:
            f.write(b"\n".join(new_lines))

    return count


def main():
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # Files to process
    files = []

    # All naka/ files
    naka_dir = os.path.join(base, 'maincpu', 'naka')
    files.extend(sorted(glob.glob(os.path.join(naka_dir, '*.s'))))

    # Main program file
    main_prog = os.path.join(base, 'maincpu', 'kn5000_v10_program.s')
    files.append(main_prog)

    total = 0
    for filepath in files:
        count = convert_file(filepath)
        if count > 0:
            name = os.path.relpath(filepath, base)
            print(f'  {name}: {count} headers converted')
            total += count

    print(f'\nTotal: {total} headers converted')


if __name__ == '__main__':
    main()

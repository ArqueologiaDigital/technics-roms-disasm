#!/usr/bin/env python3
"""split_cpu1_images.py -- split CPU 1's two program images into one source per firmware module.

QUESTION IT ANSWERS / JOB IT DOES
  prom_a/wsa1_prom_a.s (~200,000 lines) and prom_b/wsa1_prom_b.s (~208,000) were each the whole
  image in one file, so every lane that touched either one edited the same file.  This splits each
  into the image's MODULES -- one `.s` per module under prom_X/modules/ -- and leaves
  prom_X/wsa1_prom_X.s as the image's root: its header, its definitions block and one `.include`
  per module, in address order.

WHERE A MODULE ENDS, and why that is the firmware's boundary and not ours
  CPU 1's firmware is linked as separately-built modules, each padded with `ret` (0x0E) bytes up
  to an aligned address before the next one starts -- the pads are `.fill N, 1, 0x0E` lines, each
  already asserted pure 0x0E by the tree's checks (notes/prom_a_byte_checks.py and the prom_b
  generators).  So a module boundary is an address A where
      * the last line emitting bytes below A is a 0x0E `.fill` that ends exactly at A, and
      * A is a multiple of ALIGN (0x100).
  Two exceptions are written out, each an object the notes describe:
      * prom_b 0xF40000-0xF44017 is ONE object, the routine directory (2,002 slots; notes/
        FINDINGS-prom_b-thunk-table.md); its empty slots are 0x0E fills too, and they are not
        module ends.  The directory is cut out as one file with forced boundaries at 0xF40000
        and 0xF44018 (the end census.py and the symbolisers use as THUNK_HI).
      * prom_a 0xFE0000: the start of the application block (its banner, and
        notes/FINDINGS-prom_a-fcf000-module.md: "0xFE0000 -- a known boundary"); the 6,385 bytes
        below it are deliberately left `.incbin`.
  A part that would hold nothing but 0x0E padding (a whole empty 4 KiB slot) stays with the
  module before it.
  ⚠ NO 64 KiB-BANK FALLBACK.  The work package offered bank starts as a fallback where module
  boundaries were unknown.  They are known everywhere here, and every bank start that is not
  already a module boundary lies INSIDE a padded module (0xFA0000, 0xFD0000; 0xF10000 ...), so a
  bank cut would split one module across two files.  Two modules stay large because they are
  large: prom_a 0xFCF000-0xFDFFFF and prom_b's biggest (see --plan).
  Every other cut is computed, not chosen.  The modules are named in MODULE_NAMES from their
  own banners; a module without an entry gets an address-only name and is reported.

THE CUT CANNOT CHANGE A BYTE
  Neither image has an `.org` or a second section: emission order IS address order.  Every part
  is a CONTIGUOUS run of the original lines, written verbatim, and the root `.include`s it where
  the run stood.  llvm-mc's `.include` is textual, so the assembler sees the same statements in
  the same order.  The script proves the text half itself (--verify: joining the parts back
  gives the pre-split listing line for line) and the byte half is `make gate-wsa1`.

DETERMINISTIC AND RE-RUNNABLE
  --emit always starts from the JOINED listing: on a split tree it first joins the parts back
  (the include block in the root is the only thing it ever wrote), so a second --emit on an
  unchanged tree writes the same files and reports 0 changed.  Edits made inside a part since the
  last emit are carried along; a part whose module boundary moved is renamed accordingly.

RUN (inside wsa1/)
    python3 scripts/tools/split_cpu1_images.py --plan [prom_a|prom_b]   # modules, sizes, titles
    python3 scripts/tools/split_cpu1_images.py --table                  # the same, as Markdown
    python3 scripts/tools/split_cpu1_images.py --emit                   # write the split
    python3 scripts/tools/split_cpu1_images.py --verify                 # join == pre-split text
    python3 scripts/tools/split_cpu1_images.py --join                   # undo: the monolith again
    make gate-wsa1
The address of every line comes from assembling a MARKED copy of the joined listing (a label
before every statement) with the real include paths and linker script, in $TMPDIR; that copy is
checked byte-identical to the ROM before any address is believed.
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PROJECTS = os.environ.get("PROJECTS_ROOT", os.path.expanduser("~/compartilhado"))
LLVM = os.path.join(PROJECTS, "llvm-project", "build", "bin")

ALIGN = 0x100

IMAGES = {
    "prom_a": dict(rom="original_ROMs/wsa1_prom_a.ic12", base=0xF80000, ld="prom_a/prom_a.ld",
                   prologue_end=re.compile(r'^; MACRO-PRELUDE-END\s*$'),
                   forced=[0xFE0000], whole=[]),
    "prom_b": dict(rom="original_ROMs/wsa1_prom_b.ic13", base=0xF00000, ld="prom_b/prom_b.ld",
                   prologue_end=re.compile(r'^\.equ KERNEL_MEM_OPS_PROVIDED, 1\b'),
                   forced=[0xF40000, 0xF44018], whole=[(0xF40000, 0xF44018)]),
}

# Module start address -> file-name subject.  Each comes from the module's own banner (the first
# `; ====` block of the part) or, where the banner is only an address range, from the labels it
# opens with; --plan prints both, so every name here can be re-checked against its part.
MODULE_NAMES = {
    "prom_a": {
        0xF80000: "sequencer_job_button_tables",       # 104 ButtonTable_* of the AdvanceDelay/NoteChange/... jobs
        0xF82000: "main_task_reset_and_interrupts",    # MainTask_Loop, RESET, INTT1/INTTR4/NMI, ModuleInitDirectory
        0xF84000: "ring_buffers",                      # banner: the BYTE RING-BUFFER CLASS
        0xF85600: "kernel_and_dsp_refresh",            # INTT3_KernelTick, kernel/kernel.s, EntryPoint_Records, DSP task
        0xF86000: "panel_task_and_ui_event_lists",     # PanelTask_*, UiListA/B/C_Class*
        0xF89800: "control_normaliser",                # banner: the CONTINUOUS-CONTROL NORMALISER
        0xF8A000: "panel_wire_to_group",               # banner: the PANEL WIRE-to-GROUP module
        0xF8BC00: "ascii_numeric_fields",              # banner: ASCII numeric fields
        0xF8C000: "panel_leds",                        # PanelLed_*
        0xF8DA00: "callback_queue",                    # Task2_CallbackDispatcher, CallbackQueue_*
        0xF8DC00: "analog_scan",                       # AnalogScan_*
        0xF8E000: "link_port",                         # Link_*, INT0/INTTC2/INTTC3, uDMA helpers
        0xF8E800: "lcd_swi7_and_combination_screens",  # LCD_* / SWI7 services, then C0mbinati0nM0de_* screens
        0xF94C00: "debug_monitor_and_param_scripts",   # DebugMonitor_*, TestMode_*, ParamImage_*, Script_*
        0xF99400: "screen_field_redraw_request",       # PanelScreen_RequestRedrawIfFieldQueued, alone
        0xF99800: "midi_settings_screens",             # SysexBulkDump, MidiTotalMode, MidiInputOutputFilter, ...
        0xF9C000: "system_menu_screens",               # SystemMenu_InitRam, SystemTest, SoundCopy, TuneScale
        0xFA5400: "midi_port",                         # banner: the MIDI module's entry-thunk table; MIDI_*
        0xFA6000: "midi_in_out",                       # MidiIn_*, MidiOut_*
        0xFAA000: "param_message_module",              # banner: the 0x60F0xx MESSAGE MODULE
        0xFAD800: "param_apply_and_event_lists",       # ParamApply_*, Evt2030_*, SeqEvt_*, KeyValueList_*
        0xFB1800: "patch_lists",                       # PatchLists_ApplyAll, PatchList_*
        0xFB2000: "sysex_module",                      # SysExModule_*, SysExSession/Param/Dump/Tx/Rx_*
        0xFB9000: "smf_playback",                      # SmfPlay_*, Transport_*_SaveRegs
        0xFBAC00: "seq_file_load_save",                # SeqFile_Load / _Save
        0xFBB800: "part_params_and_combi_edit",        # PartParam_*, CombiEdit*
        0xFC0000: "msg0716_module",                    # banner: the 0x0716 MESSAGE MODULE
        0xFC4000: "digital_effect_screen_data",        # banner: the SOUND EDIT "DIGITAL EFFECT" pages' screen data
        0xFC5400: "note_routing",                      # NoteRouting_*
        0xFC8000: "ram3800_module",                    # banner: the RAM-0x3800 MODULE
        0xFCF000: "tone_edit_module",                  # banner: the 0xFCF000 module; ToneEditPage_* / ToneEditField_*
        0xFE0000: "disk_and_floppy",                   # banner: the block-device layer and the FDC driver; Disk_*, Fdc_*
        0xFE7800: "medley",                            # Medley_*
        0xFE8000: "edit_screens",                      # banner: CPU 1's SCREEN AND DISPATCH module; EditScreen_*
        0xFF3800: "disk_menu_screens",                 # banner: a UI SCREEN MODULE (the DISK MENU)
        0xFF8000: "splash_bitmaps",                    # banner: THREE 320 x 240 BITMAPS
        0xFFFF00: "vectors",                           # banner: interrupt vector table
    },
    "prom_b": {
        0xF00000: "old_copies_and_display_lists",      # OldCopy_*, stale PtrTable_F00340.., DL_*, Transport_*
        0xF06800: "scale_and_sound_group_tables",      # ScaleTuningOffsets, ToneGroupNames, GroupMaxMemberIndex_*
        0xF09800: "sound_edit_screens",                # SoundEditController_* / SoundEditMenu_*
        0xF0C800: "midi_screen_display_lists",         # banner: a UI SCREEN MODULE; MidiTotalMode, filter lists
        0xF0E800: "blink_and_dsp_effect_editor",       # banner: THE FIELD-BLINK ENGINE; DspEffect_*, EffectEditor_*
        0xF1B400: "fonts",                             # banner: THE TWELVE CHARACTER GENERATORS
        0xF27C00: "mode_screen_display_lists",         # DL records; ModeScreen_*, C0mbinati0nM0de_*
        0xF2C800: "test_mode_display_lists",           # GATE ARRAY / PANEL CPU / SINE WAVE CHECK lists
        0xF2D000: "screen_field_lists",                # ScreenFieldListPtrs, ScreenFieldList_*
        0xF2D800: "messages_and_display_list_interpreter",  # DL_PleaseWait, DL_Error*, DisplayListB_*, DLHandler_*
        0xF32800: "sound_edit_display_lists",          # SoundEditController_*_DL, Draw_ToneTemplate_*
        0xF34000: "sequencer_display_lists",           # DL_MasterSongMeasure, RealtimeRecord, CyclePlay lists
        0xF36800: "sysex_param_ranges",                # Pack3x7BitFields_*, SysExThirdRegion_*, Clamp*
        0xF38800: "param_image_copy",                  # ParamImage_CopyToSongWorkspace
        0xF39000: "sequencer_job_display_lists",       # DL_YesAreYouSure, Paint_SongClear/TrackAssign/StepRecord DLs
        0xF3F400: "factory_default_records",           # banner: the FACTORY DEFAULTS; Default_*
        0xF40000: "routine_directory",                 # banner: THUNK TABLE (the routine directory)
        0xF44018: "sequencer_core",                    # Seq_*, SeqRecord_*, TimedEventRing_*
        0xF47800: "bstore_cursor_and_seq_cycle",       # BStore_*Cursor*, SeqCycle_*
        0xF48C00: "disk_file_signature",               # Table_WsaSoundRamS0Wsa1, DiskFile_*
        0xF49800: "seq_record",                        # SeqRecord_*, CycleRecord_*
        0xF4C000: "creator_select_controller_screen",  # banner: THE "CREATOR SELECT / CONTROLLER" SCREEN
        0xF4C800: "bstore_compaction",                 # BStore_CompactBlocks, BStore_Relocate*
        0xF4D000: "bstore_track_cursor",               # BStore_AdvanceCursorForWrite_B, BStore_SeekChainToBeat
        0xF4E000: "track_key_handlers",                # SeqRecord_DisarmTrack, *_OnTrackKey
        0xF4EC00: "realtime_record",                   # RealtimeRecord_*, CountIn_*
        0xF4F000: "part_sound_stepping",               # PartSound_*, LCD_BlitValueBar_StackArgs
        0xF4F800: "sysex_param_descriptors",           # PtrTable_F4F800, SysExParamDesc_*
        0xF53000: "drawbar_screen",                    # banner: THE NINE-DRAWBAR ORGAN REGISTRATION SCREEN
        0xF55000: "param_edit_primitives",             # banner: PARAMETER-EDIT PRIMITIVES AND TWO TABLE ACCESSORS
        0xF55800: "seq_play_screens",                  # ModeEnter_SeqPlay, SeqPlayScreen, CyclePlayScreen
        0xF57C00: "ring_put_block",                    # RingPutBlock_*, Ring*_PutBlock*, INTT2's handler
        0xF58000: "disk_display_lists_and_sc1_link",   # DL_Disk*, SC1_*
        0xF5B800: "song_edit_jobs_and_tone_edit_draws",  # SongEdit_*, Quantize_*, MeasureErase_*, ToneEditPage_*
        0xF62C00: "block_store",                       # banner: THE BLOCK STORE
        0xF65000: "song_edit_time_signatures",         # SongEdit_*TimeSig*
        0xF65C00: "track_assign_and_medley_screens",   # TrackAssign_*, SequencerMedley_*
        0xF67400: "step_record",                       # StepRecord_*, MsgLine_*
        0xF6F000: "smf_file_io_and_old_copy",          # banner: AN OLDER BUILD'S COPY..., then Smf*_*
        0xF7A400: "bstore_allocator",                  # banner: THE BLOCK-STORE ALLOCATOR
        0xF7AA00: "song_store_commands",               # banner (0xF7A400): THE SONG-STORE COMMANDS; TrackMerge, Measure*
        0xF7D000: "panel_screen_methods",              # banner: 32 TABLES OF 32 ROUTINE POINTERS; panel-screen methods
    },
}

BEGIN = "; >>> BEGIN MODULE INCLUDES (generated by scripts/tools/split_cpu1_images.py; do not edit by hand)"
END = "; <<< END MODULE INCLUDES"
INCLUDE_RE = re.compile(r'^\t\.include "(prom_[ab]/modules/[^"]+)"')
FILL_RET = re.compile(r'^\s*\.fill\s+(0x[0-9a-fA-F]+|\d+)\s*,\s*1\s*,\s*0x0[eE]\b')
LABEL = re.compile(r'^([A-Za-z_.$][\w.$@]*):')
MARK = "__wsa1split_"


def read_lines(path):
    text = open(path, "rb").read().decode("utf-8")
    assert text.endswith("\n"), "%s does not end in a newline" % path
    return text[:-1].split("\n")


def write_text(path, lines):
    data = ("\n".join(lines) + "\n").encode("utf-8")
    if os.path.exists(path) and open(path, "rb").read() == data:
        return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp%d" % os.getpid()
    open(tmp, "wb").write(data)
    os.replace(tmp, path)
    return True


def root_path(img):
    return os.path.join(ROOT, img, "wsa1_%s.s" % img)


def joined(img):
    """(lines of the pre-split listing, [part paths it was assembled from])."""
    root = read_lines(root_path(img))
    if BEGIN not in root:
        return root, []
    s, e = root.index(BEGIN), root.index(END)
    out, parts = root[:s], []
    for ln in root[s + 1:e]:
        m = INCLUDE_RE.match(ln)
        if m:
            parts.append(m.group(1))
            out += read_lines(os.path.join(ROOT, m.group(1)))
        else:
            assert ln.startswith(";") or not ln.strip(), \
                "%s: the include block holds a line this script did not write: %r" % (img, ln)
    return out + root[e + 1:], parts


def is_statement(ln):
    s = ln.strip()
    return bool(s) and not s.startswith(";")


def line_addresses(img, lines):
    """{line index: address} for every statement line, from a marked, byte-checked assembly."""
    cfg = IMAGES[img]
    scratch = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
    with tempfile.TemporaryDirectory(dir=scratch, prefix="wsa1-split-") as td:
        marked = []
        for i, ln in enumerate(lines):
            if is_statement(ln):
                marked.append("%s%d:" % (MARK, i))
            marked.append(ln)
        src = os.path.join(td, "marked.s")
        open(src, "wb").write(("\n".join(marked) + "\n").encode("utf-8"))
        obj, elf, raw = (os.path.join(td, x) for x in ("m.o", "m.elf", "m.bin"))
        run([os.path.join(LLVM, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-I", ROOT,
             "-I", os.path.join(ROOT, img), "-o", obj, src])
        run([os.path.join(LLVM, "ld.lld"), "-e", "0", "-T", os.path.join(ROOT, cfg["ld"]), "-o", elf, obj])
        run([os.path.join(LLVM, "llvm-objcopy"), "-O", "binary", elf, raw])
        if open(raw, "rb").read() != open(os.path.join(ROOT, cfg["rom"]), "rb").read():
            sys.exit("%s: the marked listing does not rebuild the ROM -- refusing to believe its "
                     "addresses (is the tree byte-identical?  make gate-wsa1)" % img)
        addr = {}
        nm = run([os.path.join(LLVM, "llvm-nm"), "--defined-only", elf])
        for ln in nm.split("\n"):
            p = ln.split()
            if len(p) == 3 and p[2].startswith(MARK):
                addr[int(p[2][len(MARK):])] = int(p[0], 16)
    return addr


def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        sys.exit("FAILED: %s\n%s" % (" ".join(cmd), r.stderr[-3000:]))
    return r.stdout


def plan(img, lines):
    """-> (prologue_len, [(start_line, start_addr, end_addr, why)]) covering lines[prologue_len:]."""
    cfg = IMAGES[img]
    p = next(i for i, ln in enumerate(lines) if cfg["prologue_end"].match(ln)) + 1
    while p < len(lines) and not lines[p].strip():
        p += 1
    addr = line_addresses(img, lines)
    stmts = [i for i in range(p, len(lines)) if i in addr]
    end_of_image = cfg["base"] + 0x80000

    def size_at(k):
        """bytes emitted by statement stmts[k] = next statement's address - its own"""
        nxt = addr[stmts[k + 1]] if k + 1 < len(stmts) else end_of_image
        return nxt - addr[stmts[k]]

    # a boundary at A is "the first line after the last statement that starts below A";
    # it is CLEAN when that statement ends exactly at A (no statement straddles A)
    cuts = {}                              # address -> (cut line index, why)
    for k, i in enumerate(stmts):
        m = FILL_RET.match(lines[i])
        if not m:
            continue
        end = addr[i] + int(m.group(1), 0)
        if size_at(k) != int(m.group(1), 0) or end % ALIGN or end >= end_of_image:
            continue
        if any(lo < end < hi for lo, hi in cfg["whole"]):
            continue
        cuts[end] = (i + 1, "0x0E pad ends at an 0x%X-aligned address" % ALIGN)

    def clean_cut(a):
        before = [k for k, i in enumerate(stmts) if addr[i] < a]
        if not before:
            return None
        k = before[-1]
        if addr[stmts[k]] + size_at(k) != a:
            return None
        return stmts[k] + 1

    for a in cfg["forced"]:
        c = clean_cut(a)
        assert c is not None, "%s: forced boundary 0x%06X is not at a clean line boundary" % (img, a)
        cuts[a] = (c, "forced: " + ("routine directory" if img == "prom_b" else "application block"))
    # a part that is nothing but 0x0E padding (a whole empty 4 KiB slot after a module) stays with
    # the module it pads: a file holding one `.fill` names no module
    order = sorted(cuts)
    for a0, a1 in zip(order, order[1:] + [end_of_image]):
        body = [i for i in stmts if a0 <= addr[i] < a1]
        if body and all(FILL_RET.match(lines[i]) for i in body):
            del cuts[a0]
    bounds = sorted([(cfg["base"], p, "image start")] + [(a, c, w) for a, (c, w) in cuts.items()])
    mods = []
    for k, (a, c, w) in enumerate(bounds):
        a_end = bounds[k + 1][0] if k + 1 < len(bounds) else end_of_image
        mods.append((c, a, a_end, w))
    return p, mods


def banner_title(lines, lo, hi):
    """The first informative line of the part's first `; ===` banner, else ''."""
    for i in range(lo, min(hi, lo + 400)):
        if re.match(r'^;\s*={6,}', lines[i]):
            for j in range(i + 1, min(hi, i + 6)):
                t = lines[j].lstrip("; ").rstrip()
                if t and not re.match(r'^[=\-*~ ]+$', t):
                    return t
    return ""


def first_labels(lines, lo, hi, n=3):
    out = []
    for i in range(lo, hi):
        m = LABEL.match(lines[i])
        if m:
            out.append(m.group(1))
            if len(out) == n:
                break
    return out


def part_name(img, a, a_end):
    subj = MODULE_NAMES[img].get(a)
    base = "%06x_%06x" % (a, a_end - 1)
    return "%s/modules/%s%s.s" % (img, base, "_" + subj if subj else "")


def emit(img, dry=False):
    lines, old_parts = joined(img)
    p, mods = plan(img, lines)
    root = lines[:p]
    block = [BEGIN,
             "; %s is assembled from these %d module sources, in address order.  A module ends where"
             % (img, len(mods)),
             "; its 0x0E (`ret`) padding reaches an aligned address -- the firmware's own link layout;",
             "; the rule, its two written-out exceptions and the proof that the cut changes no byte are",
             "; in scripts/tools/split_cpu1_images.py.  Edit the module files; this block is regenerated.",
             ""]        # ⚠ keeps this comment from joining the first module's banner in an expanded view
    names = []
    for k, (c, a, a_end, _w) in enumerate(mods):
        c_end = mods[k + 1][0] if k + 1 < len(mods) else len(lines)
        name = part_name(img, a, a_end)
        names.append((name, c, c_end))
        block.append('\t.include "%s"' % name)
    block.append(END)
    if dry:
        return names
    changed = 0
    for name, c, c_end in names:
        changed += write_text(os.path.join(ROOT, name), lines[c:c_end])
    changed += write_text(root_path(img), root + block)
    stale = sorted(set(old_parts) - {n for n, _c, _e in names})
    for s in stale:
        os.remove(os.path.join(ROOT, s))
    print("%s: %d modules, %d file(s) written or changed, %d stale part(s) removed"
          % (img, len(names), changed, len(stale)))
    return names


def join(img):
    lines, parts = joined(img)
    write_text(root_path(img), lines)
    for s in parts:
        os.remove(os.path.join(ROOT, s))
    print("%s: joined %d part(s) back into %s" % (img, len(parts), os.path.relpath(root_path(img), ROOT)))


def verify(img, base_rev):
    """The joined working tree == the listing at base_rev, line for line."""
    lines, parts = joined(img)
    prefix = run(["git", "-C", ROOT, "rev-parse", "--show-prefix"]).strip()
    r = subprocess.run(["git", "-C", ROOT, "show", "%s:%s%s/wsa1_%s.s" % (base_rev, prefix, img, img)],
                       capture_output=True)
    if r.returncode:
        sys.exit(r.stderr.decode())
    base = r.stdout.decode("utf-8")[:-1].split("\n")
    ok = base == lines
    print("%s: %d part(s); joined listing %s the %s listing (%d vs %d lines)"
          % (img, len(parts), "EQUALS" if ok else "DIFFERS FROM", base_rev, len(lines), len(base)))
    if not ok:
        for i, (x, y) in enumerate(zip(base, lines)):
            if x != y:
                print("  first difference at line %d:\n    base: %r\n    now:  %r" % (i + 1, x, y))
                break
    return ok


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("images", nargs="*", default=["prom_a", "prom_b"])
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--plan", action="store_true")
    g.add_argument("--table", action="store_true", help="the module list as an aligned Markdown table")
    g.add_argument("--emit", action="store_true")
    g.add_argument("--join", action="store_true")
    g.add_argument("--verify", metavar="REV", nargs="?", const="HEAD",
                   help="compare the joined tree with REV's listing (default HEAD; give the "
                        "pre-split commit once the split is committed)")
    a = ap.parse_args()
    os.chdir(ROOT)
    bad = 0
    for img in a.images:
        if a.plan:
            lines, _parts = joined(img)
            p, mods = plan(img, lines)
            print("%s: prologue %d lines, %d modules" % (img, p, len(mods)))
            for k, (c, s, e, why) in enumerate(mods):
                c_end = mods[k + 1][0] if k + 1 < len(mods) else len(lines)
                print("  %06X-%06X %7d lines  %-26s %s" % (s, e - 1, c_end - c,
                      MODULE_NAMES[img].get(s, "(unnamed)"), why))
                print("      banner: %s" % banner_title(lines, c, c_end)[:110])
                print("      labels: %s" % ", ".join(first_labels(lines, c, c_end)))
        elif a.table:
            lines, _parts = joined(img)
            p, mods = plan(img, lines)
            rows = [["file", "range", "lines", "why it starts there"]]
            for k, (c, s, e, why) in enumerate(mods):
                c_end = mods[k + 1][0] if k + 1 < len(mods) else len(lines)
                rows.append(["`%s`" % os.path.basename(part_name(img, s, e)), "0x%06X-0x%06X" % (s, e - 1),
                             format(c_end - c, ","), why])
            w = [max(len(r[i]) for r in rows) for i in range(4)]
            fmt = lambda r: "| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(r)) + " |"  # noqa: E731
            print("%s/modules/ -- %d modules, root prologue %d lines\n" % (img, len(mods), p))
            print(fmt(rows[0]))
            print("|" + "|".join("-" * (x + 2) for x in w) + "|")
            for r in rows[1:]:
                print(fmt(r))
            print()
        elif a.emit:
            emit(img)
        elif a.join:
            join(img)
        else:
            bad += not verify(img, a.verify)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()

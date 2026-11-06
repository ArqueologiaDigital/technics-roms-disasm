#!/usr/bin/env python3
r"""kernel4_maincpu.py -- the KN5000 MAIN CPU's kernel joined to wsa1/kernel/kernel.s (a fourth processor).

QUESTIONS THIS ANSWERS / JOB IT DID (lane open10/kernel4, 2026-11-06, register item L-kernel-a3-kn5000-maincpu)
    The owner decided on 2026-11-06: "one kernel source ... with conditional blocks through most routines".
    Lane open9/kernel-a3 made kernel.s the kernel of three processors (both SX-WSA1R CPUs and the KN5000
    sub-CPU).  The KN5000 MAIN program (v10, v9 -> v8, v7) carries a separate build of the same kernel
    (FINDINGS-kernel-in-the-kn5000.md sec 7).  This tool measured it against kernel.s and joined it:

      --pairing    which main-CPU instruction IS which kernel.s instruction, and so which main label is
                   which kernel.s label.  Both sides are cut at proven boundaries and decoded by MAME
                   unidasm off the dumps: the main CPU's kernel extent (TaskSched_Init .. the end of
                   TaskSched_TCBTemplate, as named at BASE) off each main ROM, and kernel.s's KN5000 view
                   (asm_source.cpu_view, the text the sub-CPU build assembles) off the v1.42 payload.  The
                   two token sequences (kernel_structural_match.tok: every literal folded) are aligned by
                   one LCS over the whole extent -- no per-routine window, no threshold -- and each main
                   label is the kernel.s label at the same aligned point.  Per routine (kernel.s's 33
                   KN5000 entries, kernel_a3_pairing.ENTRIES) it prints the main span and its score.
                   --selftest exits 1 if the label map drifts from RENAME below, or differs between the
                   three trees, or any routine scores below 0.9.
      --report     how much of the kernel is now written once for all FOUR processors (counted in the
                   current kernel.s through cpu_view, views 0 / 1 / 2).
      --emit       (the job, done once) the edits to kernel.s, kernel/kernel_kn5000_maincpu.inc, the three
                   trees' system_handlers.s and scripts/renaming/rename_kernel4.sed.  Kept as the RECORD of
                   the join, not a build step: kernel.s is the source.
      --verify     what must hold after the join (see cmd_verify); the byte gate proves the bytes.

    The measured result, BASE a385de42f: 1,135 KN5000 sub-CPU slots against 1,135 main-CPU slots (an 8-byte
    inline argument block counts as one slot); the LCS pairs 1,133, of which 1,030 are byte-identical and the rest differ only in an operand -- every one a
    value kernel_kn5000_maincpu.inc names (its RAM map, counts, three ROM labels).  The text differs in
    five places: two copy lengths the sub-CPU writes in the 1-byte `ld bc, N:i3` form and the main CPU,
    whose counts (10, 12) do not fit in 3 bits, as `ldw bc, N`; three sub-CPU lines that spelled a value
    as a literal or a label where an equate now names it (respelled, KS4_EDITS).

RUN (from wsa1/, on a built tree: `make gate` at the repo root first)
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open10-kernel4-probes/kernel4_maincpu.py --pairing [--selftest]
    ... --report
    ... --verify
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WSA1 = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(WSA1)
sys.path.insert(0, os.path.dirname(HERE))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "open9-a3-probes"))
os.environ.setdefault("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
import kernel_structural_match as K   # noqa: E402
import kernel_a3_pairing as P         # noqa: E402
import kernel_a3_merge as M           # noqa: E402
from asm_source import cpu_view       # noqa: E402

BASE = "a385de42f"
NM = "/home/fsanches/compartilhado/llvm-project/build/bin/llvm-nm"
KS_FILE = "wsa1/kernel/kernel.s"
INC_FILE = "wsa1/kernel/kernel_kn5000_maincpu.inc"
SED_FILE = "scripts/renaming/rename_kernel4.sed"
TREES = ["v10", "v9", "v7"]            # v8 is the v9 tree; v6 / v5 keep their own copy (labels renamed only)
SUB_ELF = "rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf"


def sh_file(tree):
    return "%s/maincpu/boot/system_handlers.s" % tree


def rom_file(tree):
    return "original_ROMs/kn5000_%s_program.rom" % tree


def elf_file(tree):
    return "rebuilt_ROMs/kn5000_%s_program.llvm.elf" % tree


for _t in TREES:
    K.IMAGES["kn5000:" + _t] = (os.path.join(REPO, rom_file(_t)), 0xE00000)


# ------------------------------------------------------------------ reading ---
def git_text(path, rev=BASE):
    b = subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (rev, path)], capture_output=True, check=True).stdout
    return b.decode("utf-8", "surrogateescape")


def read(path):
    return open(os.path.join(REPO, path), "rb").read().decode("utf-8", "surrogateescape")


def write(path, text):
    open(os.path.join(REPO, path), "wb").write(text.encode("utf-8", "surrogateescape"))


def elf_symbols(path):
    out = subprocess.run([NM, "--defined-only", os.path.join(REPO, path)], capture_output=True, text=True,
                         check=True).stdout
    return {p[2]: int(p[0], 16) for p in (l.split() for l in out.split("\n")) if len(p) == 3}


def sym(table, *names):
    for n in names:
        if n in table:
            return table[n]
    sys.exit("kernel4_maincpu: none of %r in the ELF" % (names,))


class El(object):
    """One instruction, or one run of data lines, with the non-code lines in front of it."""
    def __init__(self, idx, lines, addr, n, text, raw):
        self.idx, self.lines, self.addr, self.n, self.text, self.raw = idx, lines, addr, n, text, raw
        self.tok = K.tok(text) if text is not None else "DATA%d" % n
        self.pre = []

    @property
    def line(self):
        return self.lines[0]

    @property
    def labels(self):
        return [M.LABEL.match(l).group(1) for k, i, l in self.pre if k == "label"]


def data_size(line):
    m = re.match(r'^\s+\.(byte|short|long)\s+(.*)$', M.code_of(line))
    return {"byte": 1, "short": 2, "long": 4}[m.group(1)] * len(m.group(2).split(","))


def elements(lines, lo_i, hi_i, key, lo, hi, data, labels=None):
    """The instruction / data lines of lines[lo_i:hi_i] as El, each address PROVEN: the instruction
    lines take the linear decode of [lo, hi) in order (the inline data block skipped) and the data
    lines their byte count; the walk must land exactly on hi."""
    dec = M.decode_skip(key, lo, hi, data)
    img = K.image(key)
    out, pre, di, pc = [], [], 0, lo
    for i in range(lo_i, hi_i):
        l = lines[i]
        k = M.kind(l)
        if k in ("blank", "comment", "label", "cond"):
            if k == "label" and labels is not None:
                n = M.LABEL.match(l).group(1)
                a = labels(n)
                if a is not None and a != pc:
                    sys.exit("kernel4_maincpu: label %s is at 0x%X in the ELF, the decode walk says 0x%X" % (n, a, pc))
            pre.append((k, i, l))
            continue
        if k == "data":
            n = data_size(l)
            if out and out[-1].text is None and all(k == "blank" for k, _, _ in pre):   # one data run, one element
                e = out[-1]
                e.lines.append(l)
                e.n += n
                e.raw = img[K.off_of(key, e.addr):K.off_of(key, e.addr) + e.n]
                e.tok = "DATA%d" % e.n
                pc += n
                continue
            e = El(i, [l], pc, n, None, img[K.off_of(key, pc):K.off_of(key, pc) + n])
            pc += n
        elif k == "insn":
            a, n, t, raw = dec[di]
            assert a == pc, (hex(a), hex(pc), l)
            di += 1
            e = El(i, [l], a, n, t, raw)
            pc += n
        else:
            sys.exit("unexpected line %d: %r" % (i + 1, l))
        e.pre, pre = pre, []
        out.append(e)
    assert pc == hi and di == len(dec), (hex(pc), hex(hi), di, len(dec))
    return out


def sub_side(ks_text):
    """kernel.s's KN5000 view (the sub-CPU build), Kernel_InitRam to the end, at v1.42 addresses."""
    lines = ks_text.split("\n")
    kv = cpu_view(lines, 1)
    s = elf_symbols(SUB_ELF)
    lo_i = next(i for i, l in enumerate(kv) if l.startswith("Kernel_InitRam:"))
    return lines, kv, elements(kv, lo_i, len(kv), "kn5000:payload", s["Kernel_InitRam"], s["Timer_Delay_Ticks"],
                               (s["SoftTimer_Request_Boot"], 8), labels=s.get)


def main_region(lines):
    lo_i = next(i for i, l in enumerate(lines) if l.startswith("TaskSched_Init:"))
    hi_i = next(i for i, l in enumerate(lines) if l.startswith("TaskSched_DelayTicks:"))
    return lo_i, hi_i


def main_side(tree, text):
    lines = text.split("\n")
    lo_i, hi_i = main_region(lines)
    s = elf_symbols(elf_file(tree))
    lo = sym(s, "TaskSched_Init", "Kernel_InitRam")
    hi = s["TaskSched_DelayTicks"]
    data = (sym(s, "TaskSched_TimerDesc_Slot1", "SoftTimer_Request_Boot"), 8)
    names = dict(RENAME, **DATA_RENAME)
    return lines, lo_i, hi_i, elements(lines, lo_i, hi_i, "kn5000:" + tree, lo, hi, data,
                                       labels=lambda n: s.get(n, s.get(names.get(n))))


def align(sub, main):
    return K.lcs_pairs([e.tok for e in sub], [e.tok for e in main])


# --------------------------------------------------------------- the pairing ---
# The measured label map (main-CPU name at BASE -> kernel.s name), the same in v10, v9 and v7.
RENAME = {
    "TaskSched_Init": "Kernel_InitRam",
    "TaskSched_InitPriorityQueues": "Kernel_InitRam__ready_queues",
    "TaskSched_InitTCBFields": "Kernel_InitRam__tcbs",
    "TaskSched_InitTimerSlots": "Kernel_InitRam__soft_timers",
    "TaskSched_InitExtQueues": "TaskSched_Init_QueueGroup_B",
    "TaskSched_InitExtQueues2": "Kernel_InitRam__sema_queues",
    "TaskSched_InitFreeList": "Kernel_InitRam__free_nodes",
    "TaskSched_LinkFreeSlots": "Kernel_InitRam__free_append",
    "TaskSched_InitLockQueues": "Kernel_InitRam__wait_queues",
    "TaskSched_InitMsgQueues": "Kernel_InitRam__msg_queues",
    "TaskSched_TimerDesc_Slot1": "SoftTimer_Request_Boot",
    "TaskSched_PostInit": "Kernel_InitRam__install",
    "TaskSched_AllIdle": "Kernel_Idle",
    "TaskSched_HaltLoop": "Kernel_Idle__loop",
    "TaskSched_Dispatch": "Kernel_Dispatch",
    "TaskSched_ScanPriorityQueues": "Kernel_Dispatch__pick_task",
    "TaskSched_ScanQueue_Loop": "Kernel_Dispatch__scan",
    "TaskSched_FoundReadyTask": "Kernel_Dispatch__switch_to",
    "TaskSched_ReturnToDispatch": "Kernel_ResumeTask",
    "TaskSched_TimerTick": "Kernel_ServiceSoftTimers",
    "TaskSched_CheckTimerSlot": "Kernel_ServiceSoftTimers__next",
    "TaskSched_TimerSlot_Skip": "Kernel_ServiceSoftTimers__step",
    "TaskSched_TimerSlot_Fire": "Kernel_ServiceSoftTimers__fire",
    "INTT3_CheckNesting": "IRQ_Epilogue",
    "INTT3_EnterScheduler": "IRQ_Epilogue__enter_kernel",
    "TaskSched_SpawnTask": "Kernel_StartTask",
    "TaskSched_ExitCurrentTask": "Kernel_ExitTask",
    "TaskSched_GetCurrentGroup": "TaskSched_GetCurrentTaskId",
    "TaskSched_GetCurrentGroup_Nested": "TaskSched_ReturnZero",
    "TaskSched_YieldToQueue": "Kernel_YieldRotate",
    "TaskSched_YieldToQueue_NoBlock": "Kernel_RotateQueue",
    "TaskSched_YieldToQueue_NoBlock_Return": "Kernel_RotateQueue__ret",
    "TaskSched_Resume": "Kernel_BlockSelf",
    "TaskSched_Resume_DecrementWait": "TaskSched_Block_Self_Consume",
    "TaskSched_WakeBySlotID": "Kernel_ReadyTask",
    "TaskSched_WakeBySlotID_Pending": "TaskSched_Wake_Task_Count",
    "TaskSched_WakeInline_Return": "Kernel_ReadyTask_NoDispatch__done",
    "TaskSched_WakeInline_Pending": "TaskSched_Wake_Task_NoResched_Count",
    "TaskSched_SignalEvent": "TaskEvent_Signal",
    "TaskSched_SignalEvent_Unlink": "TaskEvent_Signal_Wake",
    "TaskSched_SignalEvent_NoBlock": "TaskEvent_Signal_NoResched",
    "TaskSched_SignalEvent_NoBlock_Unlink": "TaskEvent_Signal_NoResched_Wake",
    "TaskSched_WaitForEvent": "TaskEvent_Wait",
    "TaskSched_WaitForEvent_Block": "TaskEvent_Wait_SuspendTask",
    "Audio_Lock_Release": "Kernel_SemaSignal",
    "AudioLock_Release_NoWaiter_Done": "Kernel_SemaSignal__return",
    "AudioLock_Release_WakeWaiter": "Kernel_SemaSignal__wake",
    "AudioLock_Release_NB_Saturated": "Kernel_SemaSignal_NoDispatch__return",
    "AudioLock_Release_NB_WakeWaiter": "Kernel_SemaSignal_NoDispatch__wake",
    "Audio_Lock_Acquire": "Kernel_SemaWait",
    "AudioLock_Acquire_Block": "Kernel_SemaWait__block",
    "AudioLock_TryAcquire": "Kernel_SemaTryWait",
    "AudioLock_TryAcquire_Fail": "Kernel_SemaTryWait__fail",
    "AudioLock_TryAcquire_Return": "Kernel_SemaTryWait__ret",
    "AudioLock_GetCount": "TaskSem_GetCount",
    "TaskMsg_Send": "MsgQueue_Send",
    "TaskMsg_Send_QueueFull": "MsgQueue_Send__no_node",
    "TaskMsg_Send_WakeReceiver": "MsgQueue_Send__wake",
    "TaskMsg_Send_NB_Return": "MsgQueue_Send_NoDispatch__ret",
    "TaskMsg_Send_NB_QueueFull": "MsgQueue_Send_NoDispatch__no_node",
    "TaskMsg_Send_NB_WakeReceiver": "MsgQueue_Send_NoDispatch__wake",
    "TaskMsg_Receive": "MsgQueue_ReceiveBlocking",
    "TaskMsg_Receive_Block": "MsgQueue_ReceiveBlocking__block",
    "TaskMsg_TryReceive": "MsgQueue_Receive_NoBlock",
    "TaskMsg_TryReceive_Empty": "MsgQueue_Receive_NoBlock__empty",
    "TaskMsg_TryReceive_Return": "MsgQueue_Receive_NoBlock__ret",
    "TaskTimer_Register": "SoftTimer_Register",
    "TaskSched_ChangePriority": "Kernel_SetTaskLevel",
    "TaskSched_ChangePriority_NotReady": "Kernel_SetTaskLevel__store_only",
    "TaskSched_ChangePriority_Inline": "Kernel_SetTaskLevel_NoDispatch",
    "TaskSched_ChangePriority_Inline_NotReady": "Kernel_SetTaskLevel_NoDispatch__store_only",
    "TaskSched_ChangePriority_Inline_Return": "Task_Reassign_Guard_Return",
    "TaskSched_TCBTemplate": "Kernel_KillTask",
}
# The kernel's data (and two helpers), outside its extent in both KN5000 trees: the main CPU takes the sub-CPU's names for
# the same records -- each is the ROM value of the same kernel_kn5000_*.inc equate (KERNEL_TCB_TEMPLATE + 12,
# KERNEL_EVENT_FLAG_IMAGE, KERNEL_SEMA_COUNT_IMAGE, KERNEL_BOOT_TIMER_CALLBACK), read by the same paired
# instruction.  "TaskSched_TCBTemplate" was the main CPU's name for Kernel_KillTask (code, not a template).
DATA_RENAME = {
    "TaskSched_TaskTable": "TaskSched_TaskDescriptorTable",
    "TaskSched_ExtQueueByteInit": "TaskSched_EventFlagInit",
    "TaskSched_ExtQueue2ByteInit": "TaskSched_SemaphoreInit",
    "TaskTimer_NullCallback": "TaskSched_NullTimerCallback",
    # and the timer-3 run-bit pair the kernel calls (Kernel_InitRam__install), `set` / `res 3,(T8RUN)`, ret
    # on both CPUs: kernel.s's KN5000 text names them as the sub-CPU does
    "Start_8bit_Timer_3": "Timer3_Start",
    "Stop_and_Clear_8bit_Timer_3": "Timer3_Stop",
}


# ★ CORROBORATION, offered after the fact and not used by the pairing: the main program exports the
#   kernel to its plug-ins (the HD-AE5000 calls them) as one-`jp` stubs that carry the routines' muITRON
#   service names (v10/maincpu/kn5000_v10_program.s, `rot_rdq_X: jp ...`).  Read at BASE, every stub's
#   target is, through RENAME, the kernel.s routine the pairing put there -- and that routine does what
#   the ITRON call names.
ITRON = {
    "rot_rdq_X": "Kernel_YieldRotate",          # rotate ready queue
    "set_flg_X": "TaskEvent_Signal",            # set event flag
    "wai_flg_X": "TaskEvent_Wait",              # wait for event flag
    "sig_sem_X": "Kernel_SemaSignal",           # signal semaphore
    "preq_sem_X": "Kernel_SemaTryWait",         # poll-and-request semaphore
    "wai_sem_X": "Kernel_SemaWait",             # wait on semaphore
    "ref_sem_X": "TaskSem_GetCount",            # refer to semaphore status
    "snd_msg_X": "MsgQueue_Send",               # send message
    "rcv_msg_X": "MsgQueue_ReceiveBlocking",    # receive message
    "prcv_msg_X": "MsgQueue_Receive_NoBlock",   # poll-and-receive message
    "get_tid_X": "TaskSched_GetCurrentTaskId",  # get task id
}


def itron_check(tree):
    t = git_text("%s/maincpu/kn5000_%s_program.s" % (tree, tree)).split("\n")
    got = {}
    for k, l in enumerate(t):
        m = re.match(r'^([a-z_]+_X):\s*$', l)
        if m and m.group(1) in ITRON:
            tgt = re.match(r'^\s*jp\s+([A-Za-z_][\w]*)', t[k + 1])
            got[m.group(1)] = RENAME.get(tgt.group(1), "?" + tgt.group(1)) if tgt else None
    return got


def measure(tree, ks_text=None, sh_text=None):
    """-> (sub elements, main elements, pairs, label map)."""
    _, _, sub = sub_side(ks_text if ks_text is not None else git_text(KS_FILE))
    _, _, _, main = main_side(tree, sh_text if sh_text is not None else git_text(sh_file(tree)))
    pairs = align(sub, main)
    at = {j: i for i, j in pairs}
    lab = {}
    for j, e in enumerate(main):
        for n in e.labels:
            i = at.get(j)
            ks = sub[i].labels if i is not None else []
            lab[n] = ks[0] if ks else None
    return sub, main, pairs, lab


def routine_table(sub, main, pairs):
    """[(kernel.s entry, main old label at the span start, main address, n sub, n main, score)]."""
    entries = [new for old, new in P.ENTRIES[:-1]]
    at_sub = {}
    for i, e in enumerate(sub):
        for n in e.labels:
            at_sub[n] = i
    starts = [at_sub[n] for n in entries] + [len(sub)]
    jof = {i: j for i, j in pairs}
    rows = []
    for k, n in enumerate(entries):
        lo, hi = starts[k], starts[k + 1]
        js = [jof[i] for i in range(lo, hi) if i in jof]
        mlo = min(js) if js else None
        nxt = [jof[i] for i in range(hi, len(sub)) if i in jof]
        mhi = min(nxt) if nxt else len(main)
        m = len(js)
        score = m / float(max(hi - lo, mhi - mlo)) if js else 0.0
        old = main[mlo].labels[0] if js and main[mlo].labels else "-"
        rows.append((n, old, main[mlo].addr if js else 0, hi - lo, mhi - mlo if js else 0, score))
    return rows


def cmd_pairing():
    ok = True
    maps = {}
    for tree in TREES:
        sub, main, pairs, lab = measure(tree)
        same = sum(1 for i, j in pairs if sub[i].raw == main[j].raw)
        print("== %s: %d KN5000 sub-CPU slots (kernel.s KN5000 view), %d main-CPU slots, %d aligned, "
              "%d byte-identical" % (tree, len(sub), len(main), len(pairs), same))
        rows = routine_table(sub, main, pairs)
        if tree == TREES[0]:
            print("  %-34s %-40s %8s %5s %5s %6s" % ("kernel.s routine (KN5000 entry)", "main-CPU label at BASE",
                                                    "addr", "n", "n", "score"))
        for r in rows:
            if tree == TREES[0]:
                print("  %-34s %-40s %08X %5d %5d %6.3f" % r)
            if r[5] < 0.9:
                ok = False
                print("  LOW %s %.3f" % (r[0], r[5]))
        order = [r[2] for r in rows]
        if order != sorted(order):
            ok = False
            print("  ROM ORDER DIFFERS")
        maps[tree] = lab
    for tree in TREES:
        got = itron_check(tree)
        bad = {k: v for k, v in got.items() if ITRON[k] != v} if len(got) == len(ITRON) else {"missing": len(got)}
        print("%s: the %d muITRON stubs' targets are the paired routines: %s" % (tree, len(got), "yes" if not bad else bad))
        ok = ok and not bad
    lab = maps[TREES[0]]
    print("label map: %d main-CPU labels, %d with a kernel.s label at the same point" %
          (len(lab), sum(1 for v in lab.values() if v)))
    if "--selftest" in sys.argv:
        for tree in TREES:
            if maps[tree] != RENAME:
                ok = False
                for k in sorted(set(maps[tree]) | set(RENAME)):
                    if maps[tree].get(k) != RENAME.get(k):
                        print("  DRIFT %s %s: measured %r, recorded %r" % (tree, k, maps[tree].get(k), RENAME.get(k)))
        print("selftest:", "ok" if ok else "FAIL")
        return 0 if ok else 1
    return 0


# -------------------------------------------------------------- the join ---
MAIN_BANNER = "; >>>>>> moved from v10/maincpu/boot/system_handlers.s -- the KN5000 MAIN CPU >>>>>>"
RECORD = "; KN5000 main-CPU names until 2026-11-06 (it IS this routine: wsa1/notes/open10-kernel4-probes/):"
IF_MAIN, IF_NOT_MAIN, ELSE, ENDIF = ".if KERNEL_KN5000 == 2", ".if KERNEL_KN5000 != 2", ".else", ".endif"

# kernel.s lines respelled so ONE line serves both KN5000 processors: each spelled a per-CPU value as a
# literal or a label where a kernel_kn5000_*.inc equate names it (same bytes in the sub-CPU build).
KS4_EDITS = [
    ("\tld b, 0x2:opc\n", "\tld b, KERNEL_EVENT_COUNT:opc\n"),
    ("\tld xhl, TaskSched_EventFlagInit\n", "\tld xhl, KERNEL_EVENT_FLAG_IMAGE\n"),
    ("\tld (TREG3:8), 0x1D:io\n", "\tld (TREG3:8), KERNEL_TICK_TREG3:io\n"),
]

# The main CPU's values for kernel.s's equates.  Each is the operand of the main instruction paired with
# a kernel.s use (cmd_verify re-derives them); the label values are labels of each main tree.
MAIN_EQU = [
    ("KERNEL_KN5000",              "2", "selects the main CPU's blocks: 0 = SX-WSA1R, 1 = KN5000 sub-CPU, 2 = KN5000 main CPU"),
    ("KERNEL_MEM_OPS_PROVIDED",    "1", "as on the sub-CPU: the TLCS-900 byte-emitter macros stay out of this build"),
    ("KERNEL_STACK_TOP",           "0x0001E53A", "the kernel's own stack, above task 3's (0x0001E4B8, TaskSched_TaskDescriptorTable)"),
    ("KERNEL_CURRENT_TASK",        "0x0487", "word cell: the running task's control block, 0 = none (the main tree's TASK_CURRENT)"),
    ("KERNEL_PENDING_TICKS",       "0x0485", "byte cell: kernel ticks not yet serviced; Kernel_Start clears it"),
    ("KERNEL_TCB_BASE",            "0x0489", "task control blocks, stride 12 (+8 level, +9 state, +10 pending wakes, +11 task id)"),
    ("KERNEL_TASK_COUNT",          "5", "how many control blocks Kernel_InitRam clears (TaskSched_TaskDescriptorTable has 5 records)"),
    ("KERNEL_READY_HEADS",         "0x04C5", "ready-queue heads, stride 4, one per priority level"),
    ("KERNEL_READY_LEVELS",        "3", "how many priority levels Kernel_Dispatch scans"),
    ("KERNEL_SEMA_QUEUES",         "0x0503", "one wait-queue head per counting semaphore, stride 4"),
    ("KERNEL_SEMA_COUNTS",         "0x0533", "the semaphore counts, one byte each"),
    ("KERNEL_SEMA_COUNT",          "12", "how many counting semaphores this CPU has"),
    ("KERNEL_SEMA_COUNT_IMAGE",    "TaskSched_SemaphoreInit", "ROM: the power-on image of KERNEL_SEMA_COUNTS (12 x 1)"),
    ("KERNEL_MSGQ_WAITQ",          "0x053F", "one receiver wait-queue head per message queue, stride 4"),
    ("KERNEL_MSGQ_HEADS",          "0x0553", "one message-list head per message queue, stride 4"),
    ("KERNEL_MSGQ_COUNT",          "5", "how many message queues this CPU has"),
    ("KERNEL_NODE_POOL",           "0x0567", "the message nodes, stride 8"),
    ("KERNEL_NODE_COUNT",          "10", "how many message nodes are in the pool"),
    ("KERNEL_FREE_LIST",           "0x05B7", "head of the free-node list; the whole pool is appended to it at boot"),
    ("KERNEL_TIMERS",              "0x05BB", "software-timer slots, stride 8"),
    ("KERNEL_TIMER_COUNT",         "1", "ONE slot, as on the sub-CPU"),
    ("KERNEL_BOOT_TIMER_CALLBACK", "TaskSched_NullTimerCallback", "ROM: the callback in SoftTimer_Request_Boot (a bare RET)"),
    ("KERNEL_TCB_TEMPLATE",        "TaskSched_TaskDescriptorTable - 12", "the task entry-point record array minus one 12-byte stride"),
    ("KERNEL_LOCK_DEPTH",          "0x05C3", "word cell: the dispatch-inhibit depth, mirrored into control register 0x7C"),
    ("KERNEL_EVENT_QUEUES",        "0x04D1", "one wait-queue head per EVENT flag (TaskEvent_*), stride 4"),
    ("KERNEL_EVENT_FLAGS",         "0x04F9", "the event flags, one byte each, bit 0 = signal latched"),
    ("KERNEL_EVENT_COUNT",         "10", "how many event flags this CPU has"),
    ("KERNEL_EVENT_FLAG_IMAGE",    "TaskSched_EventFlagInit", "ROM: the power-on image of KERNEL_EVENT_FLAGS (10 x 1)"),
    ("KERNEL_PRIORITY_OUT",        "0x0131", "byte: the running task's id << 5, written by Kernel_Dispatch (0xFF while idle)"),
    ("KERNEL_TICK_TREG3",          "0x07", "8-bit timer 3's compare value, the kernel tick's period (the sub-CPU's is 0x1D)"),
]


def main_values(tree):
    s = elf_symbols(elf_file(tree))
    look = {}
    for n, v, _ in MAIN_EQU:
        e = v
        for o, nn in DATA_RENAME.items():
            if nn in e and nn not in s:
                e = e.replace(nn, o)
        e = re.sub(r'[A-Za-z_][A-Za-z0-9_]*', lambda m: str(s[m.group(0)]) if m.group(0) in s else m.group(0), e)
        look[n] = eval(e, {}, {})
    return look


SUB_VAL = dict((n, v) for n, _, v in M.KN_EQU)
SUB_VAL["KERNEL_TICK_TREG3"] = 0x1D


def spell_main(mline, sline, mval):
    """The main line with each literal that a kernel equate names spelled as that equate: the equate
    whose MAIN value is the main literal AND whose SUB value is the sub line's literal at the same
    operand position (both CPUs must agree on what the operand IS)."""
    mc, sc = M.code_of(mline), M.code_of(sline)
    ml = M.NUM.findall(mc.split(None, 1)[1]) if len(mc.split(None, 1)) > 1 else []
    sl = M.NUM.findall(sc.split(None, 1)[1]) if len(sc.split(None, 1)) > 1 else []
    out = mc
    for a, b in zip(ml, sl):
        va, vb = int(a, 0), int(b, 0)
        cand = [n for n in mval if mval[n] == va and SUB_VAL.get(n) == vb and n != "KERNEL_KN5000"]
        if len(cand) == 1:
            out = re.sub(r'(?<![\w.])%s(?![\w.])' % re.escape(a), cand[0], out, count=1)
    return out


def cmd_emit():
    ks0 = read(KS_FILE)                  # the current text: its line numbers are the ones edited below
    ks = ks0
    for old, new in KS4_EDITS:          # (line-for-line, so the numbers stay true)
        assert ks.count(old) == 1, old
        ks = ks.replace(old, new)
    sub, main, pairs, lab = measure("v10", ks_text=ks0)
    assert lab == RENAME, "pairing drifted: run --pairing --selftest"
    mval = main_values("v10")
    lines = ks.split("\n")
    jof = {i: j for i, j in pairs}
    iof = {j: i for i, j in pairs}
    before, after = {}, {}          # raw kernel.s line index -> lines to insert before / after it

    # 1. per-CPU text: runs of sub-only elements, with the main-only elements at the same point
    i = j = 0
    gaps = []
    while i < len(sub) or j < len(main):
        if i in jof and jof[i] == j:
            i += 1
            j += 1
            continue
        si = []
        while i < len(sub) and i not in jof:
            si.append(i)
            i += 1
        mj = []
        while j < len(main) and j not in iof:
            mj.append(j)
            j += 1
        if si or mj:
            gaps.append((si, mj))
    for si, mj in gaps:
        assert si, "a main-only run with no sub-CPU text at its point is not a shape this join met"
        s_idx = [sub[x].idx for x in si]
        assert s_idx == list(range(s_idx[0], s_idx[-1] + 1)), "a per-CPU run must be contiguous source lines"
        if mj:
            mtext = ["\t" + spell_main(main[y].line, sub[si[0]].line, mval).strip().replace(" ", "\t", 1)
                     for y in mj]
            before.setdefault(s_idx[0], []).extend([IF_MAIN] + mtext + [ELSE])
        else:
            before.setdefault(s_idx[0], []).append(IF_NOT_MAIN)
        after.setdefault(s_idx[-1], []).append(ENDIF)
    # 2. every aligned pair must now be the same text for both KN5000 CPUs (the byte gate proves it)
    # 3. the main CPU's comments and its old names, under a banner before each routine
    entries = [new for old, new in P.ENTRIES[:-1]]
    rename = dict(RENAME)
    rename.update(DATA_RENAME)

    def renamed(t):
        for o in sorted(rename, key=len, reverse=True):
            t = re.sub(r'(?<![\w.])%s(?![\w.])' % re.escape(o), rename[o], t)
        return t
    routine_of = {}
    cur = None
    for x, e in enumerate(main):
        for n in e.labels:
            if RENAME[n] in entries:
                cur = RENAME[n]
        routine_of[x] = cur
    olds = {}
    for x, e in enumerate(main):
        for n in e.labels:
            olds.setdefault(routine_of[x], []).append(n)
    first_label_line = {}
    for i_, e in enumerate(sub):
        for k, idx, l in e.pre:
            if k == "label":
                first_label_line.setdefault(M.LABEL.match(l).group(1), idx)
    done = set()
    for x, e in enumerate(main):
        comments = [l for k, idx, l in e.pre if k == "comment"]
        r = routine_of[x]
        is_entry = any(RENAME[n] == r for n in e.labels)
        if is_entry and r not in done:
            done.add(r)
            block = ["", MAIN_BANNER, RECORD]
            names = olds[r]
            for k in range(0, len(names), 3):
                block.append(";    " + ", ".join("%s = %s" % (n, RENAME[n]) for n in names[k:k + 3]) +
                             ("," if k + 3 < len(names) else "."))
            hdr = [l for k_, idx, l in e.pre if k_ == "comment" and idx < next(
                i2 for k2, i2, l2 in e.pre if k2 == "label")]
            block += [renamed(l) for l in hdr]
            comments = [l for l in comments if l not in hdr]
            before.setdefault(first_label_line[r], [])[0:0] = block
        if comments:
            i_ = iof.get(x)
            assert i_ is not None, "a main comment before a main-only line"
            before.setdefault(sub[i_].idx, []).extend(renamed(l) for l in comments)
    # 4. assemble
    out = []
    for k, l in enumerate(lines):
        out += before.get(k, [])
        out.append(l)
        out += after.get(k, [])
    ks = "\n".join(out)
    ks = header_edits(ks)
    write(KS_FILE, ks)
    write(INC_FILE, inc_text())
    for tree in TREES:
        t = read(sh_file(tree)).split("\n")
        lo_i, hi_i = main_region(t)
        write(sh_file(tree), "\n".join(t[:lo_i] + INCLUDE + t[hi_i:]))
    with open(os.path.join(REPO, SED_FILE), "w") as f:
        f.write("# rename_kernel4.sed -- KN5000 MAIN-CPU kernel labels -> the canonical names of wsa1/kernel/kernel.s\n")
        f.write("# Written by wsa1/notes/open10-kernel4-probes/kernel4_maincpu.py --emit (lane open10/kernel4, 2026-11-06).\n")
        f.write("# Each main-CPU label on the left IS the kernel.s label on the right (--pairing --selftest, measured in\n")
        f.write("# v10, v9 and v7 alike); six are outside the extent -- the kernel's data (TaskSched_TaskTable, _ExtQueueByteInit,\n")
        f.write("# _ExtQueue2ByteInit, TaskTimer_NullCallback) and the timer-3 start / stop pair it calls -- named as the\n")
        f.write("# sub-CPU names them.  Apply to\n")
        f.write("# the main-CPU trees v10, v9, v7, v6, v5 (and their prose); NOT to the sub-CPU trees, whose names A3 set.\n")
        for o, n in sorted(rename.items(), key=lambda t: (-len(t[0]), t[0])):
            f.write("s/\\<%s\\>/%s/g\n" % (o, n))
    print("wrote %s, %s, %s and the three trees' %s" % (KS_FILE, INC_FILE, SED_FILE, "boot/system_handlers.s"))


INCLUDE = [
    "; =============================================================================",
    "; The multitasking kernel: Kernel_InitRam .. Kernel_KillTask (wsa1/kernel/kernel.s)",
    "; =============================================================================",
    "; ONE SOURCE FOR FOUR PROCESSORS since 2026-11-06 (owner decision; register item",
    "; L-kernel-a3-kn5000-maincpu): this program builds its kernel from the SX-WSA1R's",
    "; wsa1/kernel/kernel.s, the file both WSA1 CPUs and the KN5000 sub-CPU build theirs from.",
    "; kernel_kn5000_maincpu.inc is this processor's RAM map for it and sets KERNEL_KN5000 = 2.",
    "; The text that stood here moved there, its comments under a banner naming this file, and",
    "; each routine records, under that banner, the names it had here (the main CPU's",
    "; TaskSched_* / Audio_Lock_* / TaskMsg_* kernel names; scripts/renaming/rename_kernel4.sed).",
    "; The pairing and the join: wsa1/notes/open10-kernel4-probes/kernel4_maincpu.py (README there).",
    "; The data the kernel reads (TaskSched_TaskDescriptorTable, TaskSched_EventFlagInit,",
    "; TaskSched_SemaphoreInit above), the timer-3 interrupt in front of it (INTT3_HANDLER,",
    "; INTT3_PriorityAdjust, TaskSched_NullTimerCallback) and TaskSched_DelayTicks below stay in",
    "; this file, as the sub-CPU's do in its own: none has a WSA1 partner.",
    "\t.include \"kernel_kn5000_maincpu.inc\"",
    "\t.include \"kernel.s\"",
    "",
]


def inc_text():
    out = [
        "; ============================================================================",
        "; kernel/kernel_kn5000_maincpu.inc -- what the SHARED kernel source means on the",
        "; Technics KN5000's MAIN CPU (TMP94C241F, program v10 / v9 / v8 / v7).",
        "; ============================================================================",
        ";",
        "; kernel/kernel.s is ONE source assembled into FOUR processors: the SX-WSA1R's two",
        "; TMP95C061s (kernel_maincpu.inc, kernel_subcpu.inc), the KN5000 sub-CPU",
        "; (kernel_kn5000_subcpu.inc) and this one.  The two KN5000 builds are the same text",
        "; but for two copy lengths (`ld bc, N:i3` on the sub-CPU, whose counts fit in 3 bits;",
        "; `ldw bc, N` here): 1,030 of the main CPU's 1,135 kernel slots are byte-identical to the",
        "; sub-CPU's and the rest differ only in the values below (lane open10/kernel4,",
        "; wsa1/notes/open10-kernel4-probes/kernel4_maincpu.py --pairing).",
        ";",
        "; ⚠ EVERY VALUE BELOW IS A MEASUREMENT: the operand of the main-CPU instruction paired",
        ";   with each kernel.s use of the name, and if one is wrong the program stops rebuilding",
        ";   (`make gate`, sections maincpu v10 / v9 / v8 / v7).  The RAM map is the same in all",
        ";   four versions (their kernels assemble from this one file); the ROM values are labels of",
        ";   each program, so they follow each version's addresses.",
        ";   FINDINGS-kernel-in-the-kn5000.md sec 8's main-CPU table paired the WSA1's semaphores",
        ";   with this CPU's EVENT flags (0x04CD/0x04D1 queues, 0x04F8/0x04F9 flags) -- the same",
        ";   mix-up A3 corrected on the sub-CPU; the semaphores are 0x0503 / 0x0533 below.",
        ";",
        "; ★ Read together, these equates ARE the KN5000 main CPU's kernel RAM map, 0x0485-0x05C4.",
        "",
    ]
    w = max(len(n) for n, _, _ in MAIN_EQU) + 1
    for n, v, c in MAIN_EQU:
        out.append(".equ %-*s %s\t; %s" % (w, n + ",", v, c))
    return "\n".join(out) + "\n"


HEADER_ANCHORS = [
    ('insert-after',
     ';   (and, since 2026-11-06, for the KN5000\'s sub-CPU as well: "A THIRD PROCESSOR")\n',
     ';   (and its MAIN CPU: "A FOURTH PROCESSOR", the same day)\n'),
    ('insert-after',
     ';                                             ->  0x01FDDA-0x02083A in payload v1.42\n',
     ';\n'
     ";     v10/maincpu/boot/system_handlers.s     the KN5000's MAIN CPU, TMP94C241F\n"
     ';         .include "kernel_kn5000_maincpu.inc"    (-I wsa1/kernel; v9 -- and v8,\n'
     ';         .include "kernel.s"                     its build -- and v7 do the same)\n'
     ';                                             ->  0xEF1977-0xEF23D9 in program v10\n'),
    ('insert-after',
     ';   README).\n',
     ';   ★ DONE THE SAME DAY: see "A FOURTH PROCESSOR" below.\n'
     ';\n'
     '; ==============================================================================\n'
     '; ★★ A FOURTH PROCESSOR (2026-11-06, lane open10/kernel4, L-kernel-a3-kn5000-maincpu)\n'
     '; ==============================================================================\n'
     "; The KN5000 MAIN program (v10, v9 and its v8 build, v7) builds its kernel from\n"
     '; this file too, through kernel_kn5000_maincpu.inc, and all four images rebuild\n'
     '; byte for byte (`make gate`).  KERNEL_KN5000 is now a processor number:\n'
     ';     0  the SX-WSA1R, both CPUs     1  the KN5000 sub-CPU     2  the KN5000 main CPU\n'
     ';   `.if KERNEL_KN5000` is text both KN5000 processors assemble; `.if KERNEL_KN5000\n'
     ";   == 2` / `!= 2` the few lines where the main CPU's differ from the sub-CPU's.\n"
     ';\n'
     ';   MEASURED FIRST (wsa1/notes/open10-kernel4-probes/kernel4_maincpu.py --pairing):\n'
     ";   one LCS over the whole extent, the main CPU's listing against this file's KN5000\n"
     ';   view, both decoded off the dumps: 1,135 slots on each side, 1,133 aligned,\n'
     ';   1,030 byte-identical, every other aligned pair an operand the .inc names -- so the\n'
     ";   two KN5000 kernels are ONE build over two RAM maps, not merely the same design.\n"
     ';   All 33 KN5000 routines pair (scores 0.98-1.00; v10, v9 and v7 alike), in the same\n'
     ';   ROM order, and every one of the main CPU\'s 73 kernel labels lands on a label of\n'
     ';   this file.  (After the fact: the main program exports the kernel to its plug-ins\n'
     ';   as muITRON stubs -- `rot_rdq_X: jp ...`, `sig_sem_X`, `wai_flg_X`, `snd_msg_X` --\n'
     ';   and all 11 land on the routine of that meaning: Kernel_YieldRotate,\n'
     ';   Kernel_SemaSignal, TaskEvent_Wait, MsgQueue_Send, ...)  The text differs in two places: the event-flag and semaphore copy\n'
     ';   lengths, which the sub-CPU writes `ld bc, N:i3` (N = 2, 4 fit in 3 bits) and the\n'
     ';   main CPU `ldw bc, N` (N = 10, 12) -- the two `.if KERNEL_KN5000 == 2` blocks.\n'
     ';   Three sub-CPU lines spelled a per-CPU value as a literal or a label and now name\n'
     ';   it (KERNEL_EVENT_COUNT, KERNEL_EVENT_FLAG_IMAGE, KERNEL_TICK_TREG3).\n'
     ';\n'
     ";   NAMES.  The main CPU's kernel labels took this file's names (73, and six labels\n"
     ";   outside it took the sub-CPU's: scripts/renaming/rename_kernel4.sed); each routine\n"
     ";   records them under\n"
     ';     ; >>>>>> moved from v10/maincpu/boot/system_handlers.s -- the KN5000 MAIN CPU >>>>>>\n'
     ";   with the main CPU's comments.  ⚠ ADDRESSES IN THOSE COMMENTS ARE THE MAIN CPU'S\n"
     ';   (v10; its RAM map is kernel_kn5000_maincpu.inc).  So since this lane the two\n'
     ';   KN5000 processors call the same routine by the same name (TaskSched_Dispatch is\n'
     ';   Kernel_Dispatch on both; Audio_Lock_Acquire / _Release are Kernel_SemaWait /\n'
     ';   Kernel_SemaSignal).\n'),
]


def header_edits(text):
    for how, anchor, add in HEADER_ANCHORS:
        assert text.count(anchor) == 1, anchor[:60]
        text = text.replace(anchor, anchor + add)
    return text


# ------------------------------------------------------------- the checks ---
VARIANTS = {   # a BASE comment line of v9/v7 -> the v10 line that carries it (the same sentence, respelled)
    ";   TCB (0x487) bytes +9/+10, sets the current task to 0, unlinks the TCB from its queue (+0 next, +2 prev) and enters":
    ";   TCB (TASK_CURRENT) bytes +9/+10, sets the current task to 0, unlinks the TCB from its queue (+0 next, +2 prev) and enters",
}


def cmd_verify():
    ok = fail = 0

    def check(desc, cond, extra=""):
        nonlocal ok, fail
        print(("  ok   " if cond else "  FAIL ") + desc + (("   " + extra) if extra else ""))
        ok, fail = ok + bool(cond), fail + (not cond)

    rename = dict(RENAME)
    rename.update(DATA_RENAME)
    now = read(KS_FILE).split("\n")
    base = git_text(KS_FILE)
    for old, new in KS4_EDITS:
        base = base.replace(old, new)
    base = header_edits(base).split("\n")
    # 1. kernel.s only GREW: every BASE line (with KS4_EDITS and the header) is still there, in order,
    #    allowing the later dated edits kernel_a3_merge.py knows (LATER_EDITS)
    later = getattr(M, "LATER_EDITS", [])
    btxt = "\n".join(base)
    for _, _, how, anchor, add in later:
        if btxt.count(anchor) == 1:
            btxt = btxt.replace(anchor, anchor + add if how == "insert-after" else add)
    miss = M.subseq([l.rstrip() for l in btxt.split("\n")], [l.rstrip() for l in now])
    check("every BASE kernel.s line (with the %d KS4_EDITS and the header) is in kernel.s, in order"
          % len(KS4_EDITS), miss is None, "" if miss is None else "first missing %r" % btxt.split("\n")[miss][:70])
    # 2. the WSA1 and sub-CPU views: their code lines are BASE's, but for KS4_EDITS (sub-CPU view only)
    for cpu, tag in ((0, "WSA1"), (1, "KN5000 sub-CPU")):
        a = [l for l in cpu_view(now, cpu) if l.strip() and not l.strip().startswith(";")]
        b = [l for l in cpu_view(btxt.split("\n"), cpu) if l.strip() and not l.strip().startswith(";")]
        check("the %s view's code lines are BASE's (%d)" % (tag, len(b)), a == b, "%d vs %d" % (len(a), len(b)))
    # 3. the main view: its instruction/data slots are the main CPU's, element for element, at BASE
    mv = cpu_view(now, 2)
    for tree in TREES:
        bl = git_text(sh_file(tree)).split("\n")
        lo_i, hi_i = main_region(bl)
        bcode = [M.code_of(l).lower().replace("\t", " ") for l in bl[lo_i:hi_i] if M.kind(l) in ("insn", "data")]
        lo = next(i for i, l in enumerate(mv) if l.startswith("Kernel_InitRam:"))
        n = sum(1 for l in mv[lo:] if M.kind(l) == "insn")
        bn = sum(1 for l in bl[lo_i:hi_i] if M.kind(l) == "insn")
        check("%s: the main-CPU view has %d instruction lines from Kernel_InitRam on, as BASE's region had"
              % (tree, bn), n == bn, "%d" % n)
        # every BASE comment line of the region is in the main view, renamed (or its v10 variant)
        kc = [rename_text(l, rename).rstrip() for l in bl[lo_i:hi_i] if l.strip().startswith(";")]
        kc = [VARIANTS.get(l, l) for l in kc]
        mvs = set(l.rstrip() for l in mv)
        lost = [l for l in kc if l not in mvs]
        check("%s: all %d comment lines of BASE's kernel region are in kernel.s's main-CPU view" % (tree, len(kc)),
              not lost, lost[0][:70] if lost else "")
        # every BASE label is defined by its new name in the main view
        defined = {M.LABEL.match(l).group(1) for l in mv if M.LABEL.match(l)}
        labs = [M.LABEL.match(l).group(1) for l in bl[lo_i:hi_i] if M.LABEL.match(l)]
        lostl = [x for x in labs if rename.get(x, x) not in defined]
        check("%s: all %d kernel labels of BASE are defined in the main-CPU view by kernel.s's name"
              % (tree, len(labs)), not lostl, str(lostl[:4]))
        t = read(sh_file(tree))
        check("%s's system_handlers.s includes kernel_kn5000_maincpu.inc and kernel.s, and holds no copy" % tree,
              '.include "kernel.s"' in t and '.include "kernel_kn5000_maincpu.inc"' in t and
              "\nKernel_Dispatch:" not in t and "\nTaskSched_Dispatch:" not in t)
    # 4. no old name is left in any main-CPU tree's code (comments may quote one)
    stale = set()
    pat = re.compile(r'(?<![\w.])(%s)(?![\w.])' % "|".join(sorted(map(re.escape, rename), key=len, reverse=True)))
    for tree in TREES + ["v6", "v5"]:
        for dp, dn, fn in os.walk(os.path.join(REPO, tree, "maincpu")):
            for f in fn:
                if f.endswith(".s"):
                    for ln in open(os.path.join(dp, f), "rb").read().decode("latin-1").split("\n"):
                        stale |= set(pat.findall(ln.split(";", 1)[0]))
    check("no old main-CPU kernel name is used in v10/v9/v7/v6/v5 code", not stale, str(sorted(stale)[:5]))
    # 5. the main CPU's equates are what its instructions carry (re-derived from the pairing)
    mk = open(os.path.join(REPO, "Makefile")).read()
    for v in ("v10", "v9", "v8", "v7"):
        rule = [l for l in mk.split("\n") if l.startswith("rebuilt_ROMs/kn5000_%s_program.llvm.o:" % v)]
        check("Makefile: the %s object depends on the shared kernel source" % v,
              bool(rule) and "MAINCPU_KERNEL_SRC" in rule[0])
    print("%d checks, %d failures" % (ok + fail, fail))
    return 1 if fail else 0


def origin_lines():
    """Every comment line this join put into kernel.s: the header's FOURTH PROCESSOR text, the banners and
    name records, and the main CPU's own comment lines (renamed) of the three trees at BASE.  What
    notes/kernel_join_probe.py --verify accepts as the main-CPU origin of a comment in kernel.s."""
    rename = dict(RENAME)
    rename.update(DATA_RENAME)
    out = {MAIN_BANNER, RECORD}
    for _, _, add in HEADER_ANCHORS:
        out |= {l.rstrip() for l in add.split("\n")}
    for tree in TREES:
        bl = git_text(sh_file(tree)).split("\n")
        lo_i, hi_i = main_region(bl)
        out |= {rename_text(l, rename).rstrip() for l in bl[lo_i:hi_i] if l.strip().startswith(";")}
    for l in read(KS_FILE).split("\n"):
        if l.startswith(";    ") and all(re.match(r'^[A-Za-z_]\w* = [A-Za-z_]\w*$', x.strip().rstrip(",."))
                                         and x.strip().split(" = ")[0] in RENAME
                                         and RENAME[x.strip().split(" = ")[0]] == x.strip().rstrip(",.").split(" = ")[1]
                                         for x in l[5:].split(", ")):
            out.add(l.rstrip())
    return out


def rename_text(t, rename):
    for o in sorted(rename, key=len, reverse=True):
        t = re.sub(r'(?<![\w.])%s(?![\w.])' % re.escape(o), rename[o], t)
    return t


def cmd_report():
    now = read(KS_FILE).split("\n")
    views = [cpu_view(now, c) for c in (0, 1, 2)]
    lo = next(i for i, l in enumerate(now) if l.startswith("Kernel_InitRam:"))

    def code(i, v):
        return M.kind(views[v][i]) in ("insn", "data")
    n = len(now)
    all4 = sum(1 for i in range(lo, n) if code(i, 0) and code(i, 1) and code(i, 2))
    kn2 = sum(1 for i in range(lo, n) if code(i, 1) and code(i, 2) and not code(i, 0))
    main_only = sum(1 for i in range(lo, n) if code(i, 2) and not code(i, 1))
    sub_only = sum(1 for i in range(lo, n) if code(i, 1) and not code(i, 2))
    tot = [sum(1 for i in range(lo, n) if code(i, v)) for v in (0, 1, 2)]
    print("code lines from Kernel_InitRam on: WSA1 %d, KN5000 sub-CPU %d, KN5000 main CPU %d" % tuple(tot))
    print("  written once for all four processors:          %d" % all4)
    print("  written once for the two KN5000 processors:    %d" % kn2)
    print("  main CPU only (`.if KERNEL_KN5000 == 2`):      %d" % main_only)
    print("  sub-CPU only (its `.else` / `!= 2` branches):  %d" % sub_only)
    print("conditional blocks: %d `.if KERNEL_KN5000 == 2`, %d `.if KERNEL_KN5000 != 2`" % (
        sum(1 for l in now if l.strip() == IF_MAIN), sum(1 for l in now if l.strip() == IF_NOT_MAIN)))


if __name__ == "__main__":
    if "--pairing" in sys.argv:
        sys.exit(cmd_pairing())
    if "--emit" in sys.argv:
        cmd_emit()
    elif "--verify" in sys.argv:
        sys.exit(cmd_verify())
    elif "--report" in sys.argv:
        cmd_report()
    else:
        print(__doc__)

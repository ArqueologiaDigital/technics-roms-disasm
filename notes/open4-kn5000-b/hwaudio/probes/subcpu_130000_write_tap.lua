-- subcpu_130000_write_tap.lua -- what does the KN5000 firmware actually write to the sub-CPU's
-- 0x130000 register block (address latch +0, data +2), and does it ever read it?
--
-- The static reading (notes/open4-kn5000-b/hwaudio/README.md, kn5000-1oy) is that the only live
-- writer is DSP_Init_Channels (0x01FC95, called once from Audio_System_Init), plus the boot ROM's
-- byte-identical INIT_TONE_GEN (0xFF84A8), and that DSP_Init_Channels passes its arguments in the
-- wrong registers for DSP_Write_Channel.  This tap records every access to 0x130000-0x130003 on the
-- sub CPU's program space over a cold boot: emulated time, PC, offset, data, mem_mask, read/write.
--
-- Run: run_subcpu_130000_tap.sh (no debugger needed).

local OUT = os.getenv("TAP_OUT") or "subcpu_130000_writes.txt"
local outf = io.open(OUT, "w")
local function LOG(s) print(s); if outf then outf:write(s .. "\n"); outf:flush() end end

local mach = manager.machine
local sub  = mach.devices[":subcpu"]
local space = sub.spaces["program"]
local nw, nr = 0, 0
local LIMIT = 400

local function pc() return sub.state["PC"].value end

WTAP = space:install_write_tap(0x130000, 0x130003, "w130000", function(offset, data, mask)
  nw = nw + 1
  if nw <= LIMIT then
    LOG(("W t=%.6f pc=%06X off=%06X data=%08X mask=%08X"):format(mach.time:as_double(), pc(), offset, data, mask))
  end
end)
RTAP = space:install_read_tap(0x130000, 0x130003, "r130000", function(offset, data, mask)
  nr = nr + 1
  if nr <= LIMIT then
    LOG(("R t=%.6f pc=%06X off=%06X data=%08X mask=%08X"):format(mach.time:as_double(), pc(), offset, data, mask))
  end
end)
LOG("taps armed on :subcpu program 0x130000-0x130003")

local frame = 0
FRAME_SUB = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if frame == 1200 then
    LOG(("summary: %d writes, %d reads in %.3f s of emulated time"):format(nw, nr, mach.time:as_double()))
    if outf then outf:close(); outf = nil end
    mach:exit()
  end
end)

-- boot_timeline_tap.lua -- when does each KN5000 boot milestone run, in emulated time?
--
-- Question: how long after reset does the SX-KN5000 (v10 program, sub-CPU v1.42 payload) reach each
-- boot milestone (reset handler, payload transfer, sub-CPU audio init, graphics init, the first screen,
-- the main loop)?  boot-sequence.md "Boot Time Estimates" had only unmeasured guesses.
--
-- Method: a read tap on each CPU's program space at each milestone's address.  The bus is 16 bits
-- wide, so a tap covers the aligned word holding the milestone and the next one; a hit is accepted
-- only when the CPU's PC equals the milestone address (a fetch for the instruction AT the milestone:
-- not a data read, and not the prefetch of the previous instruction, which an earlier [addr-4,
-- addr+8] window let through), and only the FIRST hit is reported.  A milestone entered by falling
-- through from the instruction before it is fetched by that instruction's prefetch and may never be
-- seen with PC == addr; for those, the first fetch with addr-6 <= PC < addr is logged as NEAR.  A
-- NEAR line is an upper bound only if the preceding instruction does run straight into the
-- milestone (it can also be a prefetch that is then branched away from, e.g. a loop's first pass).  Time is machine.time at the tap, i.e. the scheduler's time, good to one scheduling
-- slice.  Every 60 frames the two PCs are sampled.  XIZ is logged with each hit: at
-- SubCPU_Payload_Done it is the delay loop's final count (0x100000 if the loop ran in full).
--
-- A first version used debugger breakpoints (-debug -debugger none, self-clearing bps); with them
-- armed the main CPU never reached SubCPU_Send_Payload in 22.8 s, so that method perturbs the boot
-- and was dropped.
--
-- Addresses: symbols/maincpu_v10_symbols_reference.txt and symbols/subcpu_symbols_reference.txt
-- (technics-roms-disasm 130735749).  Run with run_boot_timeline.sh.

local OUT = os.getenv("BOOT_TAP_OUT") or "boot_timeline.txt"
local outf = io.open(OUT, "w")
local function LOG(s) print(s); if outf then outf:write(s .. "\n"); outf:flush() end end

local mach = manager.machine
local main = mach.devices[":maincpu"]
local sub  = mach.devices[":subcpu"]

local MAIN = {
  {0xEF03C6, "RESET_HANDLER"},                 -- MAME answers reset from the program flash
  {0xEF050F, "Boot_InitIOPorts"},
  {0xEF068A, "SubCPU_Send_Payload"},           -- then 5 x 64 KB tone database
  {0xEF41E3, "SLIDE_Parse_Header"},            -- payload image at 0x3E0000 found: decompress it
  {0xEF40B8, "SLIDE_Decompress_4K_Done"},
  {0xEF072A, "SubCPU_Payload_TransferPart2"},  -- the 192 KB executable
  {0xEF0781, "SubCPU_Payload_DelayLoop_Long"}, -- transfer finished, 1M-iteration wait
  {0xEF078B, "SubCPU_Payload_Done"},
  {0xEF092B, "SubCPU_Payload_Verify"},
  {0xFDDB46, "ScreenGroup_Dispatch"},          -- subsystem init phases
  {0xFAA547, "InitializeGraphics"},
  {0xEF0620, "Boot_DisplayScreen"},
  {0xEF1245, "MainLoop"},
  {0xF7F4A6, "AcWelcomScreenProc"},
}
local SUB = {
  {0xFF8433, "sub:RESET_ENTRY"},               -- boot ROM IC30 (a BAD_DUMP in MAME)
  {0x000400, "sub:PAYLOAD_ENTRY"},
  {0x01F924, "sub:RESET"},
  {0x01FACB, "sub:Audio_System_Init"},
  {0x034C45, "sub:DSP_System_Init"},
}

TAPS = {}
local seen, near = {}, {}
local function arm(cpu, list)
  local sp = cpu.spaces["program"]
  for _, e in ipairs(list) do
    local a, n = e[1], e[2]
    TAPS[#TAPS + 1] = sp:install_read_tap(a & ~1, (a & ~1) + 3, n, function(off, data, mask)
      if seen[n] then return end
      local pc = cpu.state["PC"].value
      if pc == a then
        seen[n] = true
        LOG(("HIT  %-32s t=%10.6f s  pc=%06X  XIZ=%08X"):format(n, mach.time:as_double(), pc, cpu.state["XIZ"].value))
      elseif pc >= a - 6 and pc < a and not near[n] then
        near[n] = true
        LOG(("NEAR %-32s t=%10.6f s  pc=%06X  XIZ=%08X"):format(n, mach.time:as_double(), pc, cpu.state["XIZ"].value))
      end
    end)
  end
end
arm(main, MAIN)
arm(sub, SUB)
LOG(("armed %d taps"):format(#TAPS))

local frame, LAST = 0, 900
FRAME_SUB = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if frame % 60 == 0 then
    LOG(("sample frame %d t=%.3f mainPC=%06X subPC=%06X"):format(frame, mach.time:as_double(),
        main.state["PC"].value, sub.state["PC"].value))
  end
  if frame == LAST then
    LOG(("not reached in %.3f s of emulated time:"):format(mach.time:as_double()))
    for _, l in ipairs({MAIN, SUB}) do
      for _, e in ipairs(l) do if not seen[e[2]] then LOG("  " .. e[2]) end end
    end
    if outf then outf:close(); outf = nil end
    mach:exit()
  end
end)

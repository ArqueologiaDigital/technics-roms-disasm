-- kit_readers.lua (N-b8f49b1e): which program-941 code reads which byte of the CUSTOM user kit
-- (03custm3 slot 7's custom-sound block: the 0x27-byte TABLE tone head, 128 note references at
-- +0x27, 128 voice records of 0x8E bytes at +0x1A7) when the instrument plays it?
--
-- Observed in emulation, not on hardware.  Runs on the kn7000_mame overlay build (BIOS v16 = program
-- 941) with IC21's CUSTOM bank = 03custm3 (see README.md: the bank must be given halfword-swapped as
-- kn7000_custom_data.rom, because this driver build delivers that region to the CPU halfword-swapped).
-- Slot 7 is in blocks 24..25, so the block is at 0x968E0000 + 0x100 = 0x968E0100 .. 0x968E49A6.
--
-- A read tap on that range counts every CPU read by {phase, PC, byte offset in the block}.  Output
-- lines (OUT, default kit_readers.txt):
--   REGION <name> <start> <end>           a tapped range (REGIONS, below)
--   R <region> <phase> <pc> <offset> <count>   one per distinct {region, phase, pc, offset from the start}
--   [t] <action>                          the timeline
--   PEEK <addr> <bytes>                   a check that the CPU sees the bank's own bytes
-- Phases (emulated seconds): boot (0..20), select (20..27: CUSTOM, then LCDR 3 = "8: Bossa Nova",
-- CUSTOM slot 7), pad1 (27..37: START/STOP, then PAD 1 "PERCUSSION", whose part 1 is the user kit
-- {0, 0, 0x19}), pad4 (37..47: PERFORMANCE PADS/STOP, then PAD 4 "RIDE BELL", part 0 the user kit),
-- keys (47..55: pads and rhythm stopped, keys C2..C6 held on the right part, a control), end.
--   B <phase> <bucket> <count>            reads of the whole slot record (0x968E0000..0x968EFFFF) per
--                                          0x400-byte bucket of the record (bus reads, not bytes)
--   H <phase> H <breakpoint line> x<n>    debugger breakpoint hits per phase (TgNoteOnTableTone, TgTableToneStage,
--                                          func_4844A413 = CustomKitBlock, CustomVoiceRecFetch, PadSelectById)
--   HL <phase> <line>                     the first 400 hits in order
-- The PEEK at 18 s reads through the same space, so its 32 reads show up as phase "boot".
-- Needs -debug -debugger none (the breakpoints).  REDIRECT_PAD=0x200000 makes the first PadSelectById of
-- the pad1 phase take the CUSTOM style's own "TPAD" pads (README.md, "The pad redirect"); PRE_PAD (env)
-- lists the buttons pressed before the pads.  Command: README.md, "The runs".
local mac = manager.machine
local cpu = mac.devices[":maincpu"]
local prog = cpu.spaces["program"]
local OUT = io.open(os.getenv("OUT") or "kit_readers.txt", "w")
local closed = false
local function log(s) if not closed then OUT:write(s .. "\n"); OUT:flush() end end
local BASE = 0x968E0100
local SIZE = 0x48A7
local phase = "boot"
local cnt = {}
local bkt = {}
local function pc() local ok, v = pcall(function() return cpu.state["CURPC"].value end); return ok and v or 0 end

local function fld(port, name)
  for tag, p in pairs(mac.ioport.ports) do
    if tag:find(port, 1, true) then
      for n, f in pairs(p.fields) do if n == name then return f end end
      for n, f in pairs(p.fields) do if n:find(name .. " ", 1, true) == 1 then return f end end
    end
  end
end
local acts = {}
local function at(t, desc, fn) acts[#acts + 1] = {t = t, desc = desc, fn = fn} end
local function hold(t, port, name, dur)
  at(t, "DOWN " .. name, function() local f = fld(port, name); if f then f:set_value(1) else log("NOFIELD " .. name) end end)
  at(t + dur, "UP " .. name, function() local f = fld(port, name); if f then f:set_value(0) end end)
end
local function setphase(t, p) at(t, "phase " .. p, function() _G.KR_drain(); phase = p end) end
local function snap(t) at(t, "SNAP", function() mac.video:snapshot() end) end

-- REGIONS (env): "name=start-end,..." (hex, inclusive); default the kit block.  The 'JK' archive of the
-- table flash (archive=4806EA98-48138FFF, its voice records, element table and parameter records) is the
-- second region the README's runs use.
local regions = {}
for tok in (os.getenv("REGIONS") or string.format("kit=%08X-%08X", BASE, BASE + SIZE - 1)):gmatch("[^,]+") do
  local nm, lo, hi = tok:match("(%w+)=(%x+)-(%x+)")
  regions[#regions + 1] = {nm, tonumber(lo, 16), tonumber(hi, 16)}
end
at(1, "tap", function()
  _G.KR.taps = {}
  for _, r in ipairs(regions) do
    local nm, lo, hi = r[1], r[2], r[3]
    log(string.format("REGION %s %08X %08X", nm, lo, hi))
    _G.KR.taps[#_G.KR.taps + 1] = prog:install_read_tap(lo & ~3, hi | 3, nm, function(off, data, mask)
      local p = pc()
      for lanei = 0, 3 do
        if ((mask >> (lanei * 8)) & 0xff) ~= 0 then
          local a = off + lanei
          if a >= lo and a <= hi then
            local k = string.format("%s %s %08X %05X", nm, phase, p, a - lo)
            cnt[k] = (cnt[k] or 0) + 1
          end
        end
      end
      return nil
    end)
  end
  -- the whole slot record (blocks 24..25): reads per phase per 0x400-byte bucket, to see which sections a
  -- phase touches (B lines)
  _G.KR.tap2 = prog:install_read_tap(0x968E0000, 0x968EFFFF, "slot", function(off, data, mask)
    local k = string.format("%s %05X", phase, (off - 0x968E0000) & ~0x3FF)
    bkt[k] = (bkt[k] or 0) + 1
    return nil
  end)
end)
-- Debugger breakpoints (the run needs -debug -debugger none): each prints a "H" line into the console log,
-- which is copied to OUT at the end with the phase it fell in.
local BPS = {
  {0x4C036012, 'printf "H TgNoteOnTableTone part=%x note=%x",d0,d1'},
  {0x4C035EAA, 'printf "H TgTableToneStage part=%x layer=%x",d0,d1'},
  {0x4844A416, 'printf "H CustomKitBlock"'},
  {0x4844A434, 'printf "H CustomVoiceRecFetch idx=%x",d1'},
}
local hlines = {}
local consumed = 0
local function drain()
  local ok, cl = pcall(function() return mac.debugger.consolelog end)
  if not ok or cl == nil then return end
  for i = consumed + 1, #cl do
    if cl[i]:match("^H ") then hlines[#hlines + 1] = phase .. " " .. cl[i] end
  end
  consumed = #cl
end
at(2, "breakpoints", function()
  local dbg = cpu.debug
  if dbg == nil then log("NODEBUG (run with -debug -debugger none)"); return end
  for _, b in ipairs(BPS) do dbg:bpset(b[1], "", b[2] .. "; g") end
  -- PadSelectById: logged at its entry 0x48433FED (mov d0, d2).  REDIRECT_PAD (env, hex): the first call
  -- from the pad1 phase on gets its id replaced at the next instruction, 0x48433FEE (d0 and d2 := temp0);
  -- MAME runs one action per address, hence two addresses
  mac.debugger:command("temp0=0")
  dbg:bpset(0x48433FED, "", 'printf "H PadSelectById d0=%08x",d0; g')
  dbg:bpset(0x48433FEE, "temp0!=0", 'printf "H PadSelectById REDIRECT %08x -> %08x",d2,temp0; d0=temp0; d2=temp0; temp0=0; g')
end)
_G.KR_drain = drain
at(18, "peek", function()
  for _, a in ipairs({0x96820000, BASE}) do
    local s = {}
    for i = 0, 31 do s[#s + 1] = string.format("%02x", prog:read_u8(a + i)) end
    log(string.format("PEEK %08X %s", a, table.concat(s, " ")))
  end
end)
snap(19)
setphase(20, "select")
hold(20, ":cpanel:", "CUSTOM (SW2)", 0.3)
hold(23, ":cpanel:", "LCDR 3", 0.3)
-- PRE_PAD (env, comma-separated): buttons pressed 0.6 s apart from 24.2 s, before the pads (default:
-- PERFORMANCE PADS/AUTO, which makes the pads follow the rhythm, so a CUSTOM style's own "TPAD" pads
-- are used: PadSelectById 0x48433FE8 takes them for an id with 0x200000 set, the CUSTOM rhythm id)
do
  local tp = 24.2
  for tok in (os.getenv("PRE_PAD") or "PERFORMANCE PADS/AUTO (SW5)"):gmatch("[^,]+") do hold(tp, ":cpanel:", tok, 0.3); tp = tp + 0.6 end
end
snap(26)
setphase(27, "pad1")
if os.getenv("REDIRECT_PAD") then at(26.5, "redirect armed", function() mac.debugger:command("temp0=" .. os.getenv("REDIRECT_PAD")) end) end
hold(27, ":cpanel:", "START/STOP (SW4)", 0.3)
hold(29, ":cpanel:", "PAD 1 (SW4)", 0.3)
snap(33)
setphase(37, "pad4")
hold(37, ":cpanel:", "PERFORMANCE PADS/STOP (SW1)", 0.3)
hold(39, ":cpanel:", "PAD 4 (SW2)", 0.3)
snap(43)
setphase(47, "keys")
hold(47, ":cpanel:", "PERFORMANCE PADS/STOP (SW1)", 0.3)
hold(47.5, ":cpanel:", "START/STOP (SW4)", 0.3)
for k, key in ipairs({"C2", "C3", "C4", "C5", "C6"}) do hold(48 + k, ":KEYS", key, 0.8) end
setphase(55, "end")
at(56, "dump", function()
  _G.KR_drain()
  local hc = {}
  for _, l in ipairs(hlines) do
    local key = l:gsub("idx=%x+", "idx=*"):gsub("note=%x+", "note=*")
    hc[key] = (hc[key] or 0) + 1
  end
  local hk = {}
  for k in pairs(hc) do hk[#hk + 1] = k end
  table.sort(hk)
  for _, k in ipairs(hk) do log("H " .. k .. " x" .. hc[k]) end
  for n, l in ipairs(hlines) do if n <= 400 then log("HL " .. l) end end
  local ks = {}
  for k in pairs(cnt) do ks[#ks + 1] = k end
  table.sort(ks)
  for _, k in ipairs(ks) do log("R " .. k .. " " .. cnt[k]) end
  log(("DISTINCT %d"):format(#ks))
  ks = {}
  for k in pairs(bkt) do ks[#ks + 1] = k end
  table.sort(ks)
  for _, k in ipairs(ks) do log("B " .. k .. " " .. bkt[k]) end
  OUT:close(); closed = true
  mac:exit()
end)

_G.KR = {}
table.sort(acts, function(a, b) return a.t < b.t end)
local i = 1
_G.KR.h = emu.register_periodic(function()
  local t = mac.time.seconds + mac.time.attoseconds / 1e18
  while i <= #acts and t >= acts[i].t do
    local a = acts[i]; i = i + 1
    local ok, err = pcall(a.fn)
    if not ok then log("ERR " .. a.desc .. ": " .. tostring(err)) else log(("[%6.2f] %s"):format(t, a.desc)) end
  end
end)

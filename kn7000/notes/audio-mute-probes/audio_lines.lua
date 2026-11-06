-- audio_lines.lua (N-44e56012): do the firmware's three software-driven audio lines move when SD
-- PICTURE LOAD opens or while a key is played on it?
--
-- The lines (service manual trace: README.md section 1):
--   PMUT  CPU port P22 = GPIO byte 0x36008004 bit 2 (1 = the power amplifier's bias rail +15PM on)
--   SPSW  sound-control latch IC25 Q5 = byte 0x98060000 bit 1 (1 = the summing stage's FET switches
--         Q502 / Q503 conduct: headphones and speakers fed)
--   DAC   the main D/A converter IC311's mode port: latch bits 3 (ML), 4 (MC), 5 (MDI), shifted out
--         MSB first by SdPowerSerial16; every 16-bit word latched (ML rising) is printed
-- Observed in emulation, not on hardware.  Runs on the overlay build of the KN7000 driver (BIOS v16 =
-- program 941) with -debug -debugger none (the title redirect is a debugger breakpoint).
--
-- Every write is logged from power-on, with the emulated time and the PC:
--   PMUT <t> pc=<pc> <old> -> <new>        bit 2 of 0x36008004 changed (writes that keep it are counted)
--   LATCH <t> pc=<pc> := <byte>            every write to the 0x98060000 latch that changes SPSW or SDMODE
--                                          (bit 0, USB.WAITM, toggles with every USB-MIDI byte: LATCH_ALL=1 logs those too)
--   DACWORD <t> pc=<pc> <word>             a 16-bit word clocked into the DAC (ML low .. ML rising)
--   COUNT <window> <name> <n>              writes inside each key window
-- Screen route as picload_keys.lua with TITLE=0xD6 AFTER="LCDR 2" (the PICTURE LIST, then its PICTURE
-- LOAD item, which opens SD PICTURE LOAD): windows A-home, B-opened (key held), C-after-exit.
--
-- Command (from a scratch run directory with cfg/ nvram/ snap/ diff/ and a fresh copy of the real
-- SD card as sd_real.img):
--   OUT=audio_lines.txt timeout 1800 ~/compartilhado/kn7000_mame_build/kn7000 kn7000 \
--     -rompath ~/compartilhado/technics_romsets -skip_gameinfo -video none -sound none -nothrottle \
--     -debug -debugger none -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
--     -diff_directory diff -harddisk sd_real.img -autoboot_script audio_lines.lua
local mac = manager.machine
local cpu = mac.devices[":maincpu"]
local dbg = cpu.debug
local prog = cpu.spaces["program"]
local OUT = io.open(os.getenv("OUT") or "audio_lines.txt", "w")
local function log(s) OUT:write(s .. "\n"); OUT:flush(); print(s) end
local TITLE = tonumber(os.getenv("TITLE") or "0xD6")
local T_HOME = tonumber(os.getenv("T_HOME") or "20")
local T_OPEN = tonumber(os.getenv("T_OPEN") or "28")
local KEY = os.getenv("KEY") or "C4"
local PRESSES = {}
for tok in (os.getenv("PRESSES") or "PROGRAM MENUS,LCDR 2"):gmatch("[^,]+") do PRESSES[#PRESSES + 1] = tok end
local OPEN_BTN2 = os.getenv("OPEN_BTN2") or "LCDL 3"
local AFTER = {}
for tok in (os.getenv("AFTER") or "LCDR 2"):gmatch("[^,]+") do AFTER[#AFTER + 1] = tok end

local function cmd(s) mac.debugger:command(s) end
local function now() return mac.time.seconds + mac.time.attoseconds / 1e18 end
local function pc() local ok, v = pcall(function() return cpu.state["CURPC"].value end); return ok and v or 0 end

-- byte of a bus write at the lane of address `want` (little-endian 32-bit bus)
local function lane(off, data, mask, want)
  local sh = ((want - (off & ~3)) & 3) * 8
  if ((mask >> sh) & 0xff) == 0 then return nil end
  return (data >> sh) & 0xff
end

local cnt = {}
local function bump(k) cnt[k] = (cnt[k] or 0) + 1 end
local pmut = -1
local latch = -1
local sh_word, sh_bits, ml_low = 0, 0, false

_G.AL = {}
_G.AL.tp = prog:install_write_tap(0x36008004, 0x36008007, "pmut", function(off, data, mask)
  local b = lane(off, data, mask, 0x36008004)
  if b == nil then return nil end
  local v = (b >> 2) & 1
  bump("P04-writes")
  if v ~= pmut then log(("PMUT %9.4f pc=%08X %d -> %d (byte %02X)"):format(now(), pc(), pmut, v, b)); pmut = v end
  return nil
end)
_G.AL.tl = prog:install_write_tap(0x98060000, 0x98060003, "latch", function(off, data, mask)
  local b = nil
  for want = 0x98060000, 0x98060003 do b = b or lane(off, data, mask, want) end
  if b == nil then return nil end
  bump("latch-writes")
  local old = latch
  if b ~= old then
    if os.getenv("LATCH_ALL") or ((old < 0) or (((old ~ b) & 0x06) ~= 0)) then
      log(("LATCH %9.4f pc=%08X := %02X (SPSW %d, SDMODE %d, USB.WAITM %d)"):format(now(), pc(), b, (b >> 1) & 1, (b >> 2) & 1, b & 1))
    end
    -- DAC serial: ML = bit 3, MC = bit 4, MDI = bit 5
    local ml, mc, mdi = (b >> 3) & 1, (b >> 4) & 1, (b >> 5) & 1
    local oml, omc = (old >> 3) & 1, (old >> 4) & 1
    if old >= 0 then
      if oml == 1 and ml == 0 then ml_low, sh_word, sh_bits = true, 0, 0 end
      if ml_low and omc == 0 and mc == 1 then sh_word = ((sh_word << 1) | mdi) & 0xffff; sh_bits = sh_bits + 1 end
      if ml_low and oml == 0 and ml == 1 then
        log(("DACWORD %9.4f pc=%08X %04X (%d bits) reg %d data %02X"):format(now(), pc(), sh_word, sh_bits, (sh_word >> 8) & 0x7f, sh_word & 0xff))
        ml_low = false
      end
    end
    latch = b
  end
  return nil
end)
log("taps armed at power-on: 0x36008004 (PMUT bit 2), 0x98060000 (IC25 latch)")

local function fld(port_sub, name)
  for tag, p in pairs(mac.ioport.ports) do
    if tag:find(port_sub, 1, true) then
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
local nsnap = 0
local function snap(t, tag) at(t, "SNAP " .. tag, function() mac.video:snapshot(); nsnap = nsnap + 1; log(("SNAPFILE %d %s"):format(nsnap - 1, tag)) end) end
local function window(t0, win, press_key)
  at(t0, "open window " .. win, function() cnt = {}; log(("STATE %s PMUT %d latch %02X"):format(win, pmut, latch & 0xff)) end)
  if press_key then hold(t0 + 0.5, ":KEYS", KEY, 1.0) end
  at(t0 + 2.5, "close window " .. win, function()
    log(("COUNT %s P04-writes %d"):format(win, cnt["P04-writes"] or 0))
    log(("COUNT %s latch-writes %d"):format(win, cnt["latch-writes"] or 0))
    log(("STATE %s-end PMUT %d latch %02X"):format(win, pmut, latch & 0xff))
  end)
end

at(1, "breakpoints", function()
  cmd("temp0=0")
  -- call entries of ChangeTitle / InterruptTitle: 941 (BIOS v16) by default; 893 (-bios v13):
  -- BP_CHANGETITLE=0x4842B3B2 BP_INTERRUPTTITLE=0x4842B45E (kn7000_b893.sym + 5, past the prologue)
  local ct = tonumber(os.getenv("BP_CHANGETITLE") or "0x4842B3F4")
  local it = tonumber(os.getenv("BP_INTERRUPTTITLE") or "0x4842B4A0")
  for _, b in ipairs({{ct, "ChangeTitle"}, {it, "InterruptTitle"}}) do
    dbg:bpset(b[1], "temp0==0", ('printf "T %s d0=%%x",d0; g'):format(b[2]))
    dbg:bpset(b[1], "temp0!=0", ('printf "T %s d0=%%x REDIRECT -> %%x",d0,temp0; d0=temp0; temp0=0; g'):format(b[2]))
  end
end)
snap(T_HOME, "home")
window(T_HOME + 0.5, "A-home", true)
for k, b in ipairs(PRESSES) do hold(T_OPEN - 2 * (#PRESSES - k + 1), ":cpanel:", b, 0.3) end
at(T_OPEN, "redirect armed", function() cmd(("temp0=%x"):format(TITLE)); log(("REDIRECT armed to 0x%X"):format(TITLE)) end)
hold(T_OPEN + 0.2, ":cpanel:", OPEN_BTN2, 0.3)
snap(T_OPEN + 4, "opened")
local TB = T_OPEN + 5
for k, b in ipairs(AFTER) do hold(TB, ":cpanel:", b, 0.3); snap(TB + 2.5, "after " .. b); TB = TB + 3 end
window(TB, "B-opened", true)
snap(TB + 3, "after-B")
hold(TB + 3.5, ":cpanel:", "EXIT", 0.3)
snap(TB + 7, "after-exit")
window(TB + 8, "C-after-exit", true)
at(TB + 11, "end", function()
  for _, l in ipairs(mac.debugger.consolelog) do if l:match("^T ") then log("TITLECALL " .. l) end end
  log(("STATE end PMUT %d latch %02X"):format(pmut, latch & 0xff)); OUT:close(); mac:exit()
end)

table.sort(acts, function(a, b) return a.t < b.t end)
local i = 1
_G.AL.h = emu.register_periodic(function()
  local t = now()
  while i <= #acts and t >= acts[i].t do
    local a = acts[i]; i = i + 1
    local ok, err = pcall(a.fn)
    if not ok then log("ERR " .. a.desc .. ": " .. tostring(err)) else log(("[%6.2f] %s"):format(t, a.desc)) end
  end
end)

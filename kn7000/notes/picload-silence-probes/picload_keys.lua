-- picload_keys.lua (N-44e56012): where does a key-bed note stop while a PICTURE LOAD screen is open?
--
-- Runs on the overlay build of the KN7000 driver (BIOS v16 = program 941) with -debug -debugger none,
-- so that debugger breakpoints count the key path's routines.  Observed in emulation, not on hardware.
--
-- Timeline (emulated seconds; env overrides in brackets):
--   T_HOME  [20]  snapshot of the home screen
--   window A: Key C4 held 1 s on the home screen; counts every breakpoint below
--   before T_OPEN press PRESSES [PROGRAM MENUS, LCDR 2] 2 s apart (to the SEQ MENU screen)
--   T_OPEN  [28]  arm the redirect (debugger variable temp0 = title index) and press OPEN_BTN2
--                 [LCDL 3, SEQ MENU's RECORD & EDIT]; the first ChangeTitle / InterruptTitle call after that gets d0 replaced by the
--                 title index TITLE [0x12B = TT_PICTLDSD, SdCardPictureLoad; 0x12A = TT_PICTLDDK,
--                 PictureLoadDisk; 0xD6 = TT_SSWLIST], so the firmware itself opens the screen
--   window B: Key C4 held 1 s on that screen (T_OPEN + 5); same counts
--   then EXIT pressed, window C on the screen the firmware returns to; snapshots after each step.
--
-- Signals (breakpoint hit counts per window, printed as "COUNT <window> <name> <n>"):
--   KeyFifoRead   func_48448077 entry 0x4844807C  the key-bed FIFO reader (TGA_KEY_FIFO 0x98050004)
--   M3Dispatch    func_4C01B6DA entry 0x4C01B6DF  M3 dispatch (every M3 message, not only keys)
--   KeyRoute      func_48451AA7 entry 0x48451AAC  the 0x700000 key router
--   KeyToPart     func_484524EB entry 0x484524F0  zone -> part routing
--   PartNotePost  func_4844FAF1 entry 0x4844FAF6  posts the part's note to the TG translator
--   M3ToTg        func_4C024DD8 entry 0x4C024DDD  the M3 -> TG translator
--   TgcNoteOnSend 0x4C029798 (entry of 0x4C029793), d0 = source kind, d1 = part
--   TgcBufWrite   0x4C003A65 (entry of 0x4C003A60), a0 = {len, bytes}; the first bytes are printed
--   TgPartKeyEvent 0x4C036EA4, TgLevelResolve 0x4C02FBE3 (the library side of the TG stream)
-- plus the raw writes to the two tone generators' register ports (0x98040000 / 0x98050000; the
-- 0xFC00 idle class excluded), as tools/rigs/keybed_trigger.lua of the kn7000_mame repo counts them.
--
-- Command (from a scratch run directory; ROMs from technics_romsets, the real SD card copied):
--   TITLE=0x12B OUT=picload_sd.txt timeout 900 ~/compartilhado/kn7000_mame_build/kn7000 kn7000 \
--     -rompath ~/compartilhado/technics_romsets -skip_gameinfo -video none -sound none -nothrottle \
--     -debug -debugger none -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
--     -diff_directory diff -harddisk sd_real.img -autoboot_script <this file>
local mac = manager.machine
local cpu = mac.devices[":maincpu"]
local dbg = cpu.debug
local prog = cpu.spaces["program"]
local OUT = io.open(os.getenv("OUT") or "picload_keys.txt", "w")
local function log(s) OUT:write(s .. "\n"); OUT:flush(); print(s) end
local TITLE = tonumber(os.getenv("TITLE") or "0x12B")
local T_HOME = tonumber(os.getenv("T_HOME") or "20")
local T_OPEN = tonumber(os.getenv("T_OPEN") or "28")
local KEY = os.getenv("KEY") or "C4"
-- PRESSES: the buttons pressed 2 s apart before T_OPEN (PROGRAM MENUS, then its SEQUENCER item
-- LCDR 2, which changes the mode, not the title); OPEN_BTN2: the press whose title call is redirected
-- (LCDL 3 = SEQ MENU's RECORD & EDIT, an AcTitleMenu whose AcTitleMenuProc calls ChangeTitle)
local PRESSES = {}
for tok in (os.getenv("PRESSES") or "PROGRAM MENUS,LCDR 2"):gmatch("[^,]+") do PRESSES[#PRESSES + 1] = tok end
local OPEN_BTN2 = os.getenv("OPEN_BTN2") or "LCDL 3"

local function cmd(s) mac.debugger:command(s) end

-- counters live in debugger variables so that the breakpoint actions can bump them: temp2 = window
-- open flag; one temp per counter would run out (temp0..temp9), so the counters are printed with a
-- tag and summed from the console log instead.
local BPS = {
  {0x4844807C, "KeyFifoRead",    'printf "H KeyFifoRead"'},
  {0x4C01B6DF, "M3Dispatch",     'printf "H M3Dispatch d0=%08x d1=%08x",d0,d1'},
  {0x48451AAC, "KeyRoute",       'printf "H KeyRoute d0=%08x d1=%08x",d0,d1'},
  {0x484524F0, "KeyToPart",      'printf "H KeyToPart d0=%08x d1=%08x",d0,d1'},
  {0x4844FAF6, "PartNotePost",   'printf "H PartNotePost d0=%08x d1=%08x",d0,d1'},
  {0x4C024DDD, "M3ToTg",         'printf "H M3ToTg d0=%08x d1=%08x",d0,d1'},
  {0x4C029798, "TgcNoteOnSend",  'printf "H TgcNoteOnSend d0=%08x d1=%08x",d0,d1'},
  {0x4C003A65, "TgcBufWrite",    'printf "H TgcBufWrite %02x %02x %02x %02x %02x %02x",b@a0,b@(a0+1),b@(a0+2),b@(a0+3),b@(a0+4),b@(a0+5)'},
  {0x4C036EA4, "TgPartKeyEvent", 'printf "H TgPartKeyEvent d0=%08x d1=%08x",d0,d1'},
  {0x4C02FBE3, "TgLevelResolve", 'printf "H TgLevelResolve d0=%08x d1=%08x",d0,d1'},
}
-- title calls: always logged; the redirect replaces d0 once while temp0 != 0
local TITLE_BPS = {
  {0x4842B3F4, "ChangeTitle"}, {0x4842B422, "ChangeTitleEZ"}, {0x4842B460, "ChangeTitleDirect"},
  {0x4842B4A0, "InterruptTitle"},
}

local tg_addr, tgw, armed = {0, 0}, 0, false
-- IOLOG: from T_OPEN + IOLOG_FROM to T_OPEN + IOLOG_TO [0 .. 3.8 s: the redirected screen opening] every
-- TG register write {reg, data} (the 0xFC00 class, which the idle loop rewrites, included) and
-- every write to the DSP host ports (0x98000000 index / 0x9C000000 data) and the GPIO block
-- 0x36008000..0x360080FF is collected; "IO" lines print each distinct {where, value} with a count.
local iolog, iocount = false, {}
local function iorec(k) if iolog then iocount[k] = (iocount[k] or 0) + 1 end end
local function tap(base, idx)
  return prog:install_write_tap(base, base + 3, "tg" .. idx, function(off, data, mask)
    if (mask & 0x0000ffff) ~= 0 then tg_addr[idx] = data & 0xffff end
    if (mask & 0xffff0000) ~= 0 then
      if armed and (tg_addr[idx] & 0xff00) ~= 0xfc00 then tgw = tgw + 1 end
      iorec(("TG%d reg %04X := %04X"):format(idx, tg_addr[idx], (data >> 16) & 0xffff))
    end
    return nil
  end)
end
local function iotap(lo, hi, nm)
  return prog:install_write_tap(lo, hi, nm, function(off, data, mask)
    iorec(("%s %08X := %08X mask %08X"):format(nm, off, data, mask)); return nil end)
end

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

local consumed = 0
local function drain(win)
  local cl = mac.debugger.consolelog
  local counts, firsts = {}, {}
  for i = consumed + 1, #cl do
    local line = cl[i]
    local nm = line:match("^H (%S+)")
    if nm then
      counts[nm] = (counts[nm] or 0) + 1
      firsts[nm] = firsts[nm] or {}
      if #firsts[nm] < 6 then table.insert(firsts[nm], line) end
    elseif line:match("^T ") then
      log(win .. " " .. line)
    end
  end
  consumed = #cl
  for _, b in ipairs(BPS) do
    log(("COUNT %s %-14s %d"):format(win, b[2], counts[b[2]] or 0))
    for _, l in ipairs(firsts[b[2]] or {}) do log("   " .. win .. " " .. l) end
  end
  log(("COUNT %s %-14s %d"):format(win, "TG-port-writes", tgw))
  tgw = 0
end

local function window(t0, win, press_key)
  at(t0, "open window " .. win, function() drain("pre-" .. win); cmd("temp2=1"); armed = true end)
  if press_key then hold(t0 + 0.5, ":KEYS", KEY, 1.0) end
  at(t0 + 2.5, "close window " .. win, function() cmd("temp2=0"); armed = false; drain(win) end)
end

at(1, "breakpoints", function()
  cmd("temp0=0"); cmd("temp2=0")
  for _, b in ipairs(BPS) do dbg:bpset(b[1], "temp2", b[3] .. "; g") end
  for _, b in ipairs(TITLE_BPS) do
    dbg:bpset(b[1], "temp0==0", ('printf "T %s d0=%%x d1=%%x",d0,d1; g'):format(b[2]))
    dbg:bpset(b[1], "temp0!=0",
      ('printf "T %s d0=%%x d1=%%x REDIRECT -> %%x",d0,d1,temp0; d0=temp0; temp0=0; g'):format(b[2]))
  end
  _G.PK.t1 = tap(0x98040000, 1); _G.PK.t2 = tap(0x98050000, 2)
  _G.PK.t3 = iotap(0x98000000, 0x98000003, "DSPidx"); _G.PK.t4 = iotap(0x9C000000, 0x9C000003, "DSPdat")
  _G.PK.t5 = iotap(0x36008000, 0x360080FF, "GPIO")
  log("armed: " .. #BPS .. " counting breakpoints, " .. #TITLE_BPS .. " title breakpoints")
end)
snap(T_HOME, "home")
window(T_HOME + 0.5, "A-home", true)
for k, b in ipairs(PRESSES) do hold(T_OPEN - 2 * (#PRESSES - k + 1), ":cpanel:", b, 0.3); snap(T_OPEN - 2 * (#PRESSES - k + 1) + 1.5, "after " .. b) end
at(T_OPEN, "redirect armed", function() drain("pre-open"); cmd(("temp0=%x"):format(TITLE)); log(("REDIRECT armed to 0x%X"):format(TITLE)) end)
hold(T_OPEN + 0.2, ":cpanel:", OPEN_BTN2, 0.3)
local IOLOG_FROM = tonumber(os.getenv("IOLOG_FROM") or "0")
local IOLOG_TO = tonumber(os.getenv("IOLOG_TO") or "3.8")
at(T_OPEN + IOLOG_FROM, "iolog on", function() iolog = true end)
at(T_OPEN + IOLOG_TO, "iolog off", function()
  iolog = false
  local ks = {}
  for k in pairs(iocount) do ks[#ks + 1] = k end
  table.sort(ks)
  for _, k in ipairs(ks) do log(("IO %-50s x%d"):format(k, iocount[k])) end
  log(("IO distinct %d"):format(#ks))
end)
snap(T_OPEN + 4, "opened")
-- AFTER: buttons pressed 3 s apart once the redirected screen is up (e.g. "LCDR 1" = PICTURE LIST's
-- PICTURE LOAD item, the AcSswImgLoad that opens the floppy PICTURE LOAD screen)
local AFTER = {}
for tok in (os.getenv("AFTER") or ""):gmatch("[^,]+") do AFTER[#AFTER + 1] = tok end
local TB = T_OPEN + 5
for k, b in ipairs(AFTER) do hold(TB, ":cpanel:", b, 0.3); snap(TB + 2.5, "after " .. b); TB = TB + 3 end
window(TB, "B-opened", true)
window(TB + 3, "B0-opened-nokey", false)
snap(TB + 6, "after-B")
hold(TB + 6.5, ":cpanel:", "EXIT", 0.3)
snap(TB + 10, "after-exit")
window(TB + 11, "C-after-exit", true)
at(TB + 14, "end", function() drain("end"); OUT:close(); mac:exit() end)

_G.PK = {}
table.sort(acts, function(a, b) return a.t < b.t end)
local i = 1
_G.PK.h = emu.register_periodic(function()
  local t = mac.time.seconds + mac.time.attoseconds / 1e18
  while i <= #acts and t >= acts[i].t do
    local a = acts[i]; i = i + 1
    local ok, err = pcall(a.fn)
    if not ok then log("ERR " .. a.desc .. ": " .. tostring(err)) else log(("[%6.2f] %s"):format(t, a.desc)) end
  end
end)

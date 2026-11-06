-- m3_sweep.lua (N-e411f8fa): which M3 parameter ids does each of a list of panel buttons set?
-- (m3_watch.lua's breakpoint and report, one window per button: press 0.3 s, 3 s window, then EXIT.)
--
-- Overlay build of the KN7000 driver (BIOS v16 = program 941), -debug -debugger none.  Observed in
-- emulation, not on hardware.  A breakpoint on PutM3Em's call entry (0x4C014A56; d0 = word 0 = source
-- nibble 31..28, sub-index 27..24, parameter id 23..0; d1 = value; MDR = the return address) logs every
-- call while a window is open; at the window's end the probe prints each distinct id with its count,
-- first / last value and first caller.  ".. -> 0x" ids are the ones song-records.md section 3 lists as
-- unexplained (WATCH below).
--
-- BUTTONS (env, ','-separated cpanel field names; default below) are pressed from t = 20 s, 4.5 s apart.
-- Command (scratch run directory, as picload_keys.lua):
--   OUT=m3_sweep.txt BUTTONS="PAD 1,FADE IN" timeout 900 ~/compartilhado/kn7000_mame_build/kn7000 kn7000 \
--     -rompath ~/compartilhado/technics_romsets -skip_gameinfo -video none -sound none -nothrottle \
--     -debug -debugger none -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
--     -diff_directory diff -harddisk sd_real.img -autoboot_script <this file>
local mac = manager.machine
local cpu = mac.devices[":maincpu"]
local OUT = io.open(os.getenv("OUT") or "m3_sweep.txt", "w")
local function log(s) OUT:write(s .. "\n"); OUT:flush(); print(s) end
local function cmd(s) mac.debugger:command(s) end
local WATCH = {[0x8002]=1, [0x8006]=1, [0x8008]=1, [0x8031]=1, [0x8032]=1, [0xC081]=1, [0xE000]=1,
               [0xE002]=1, [0x200081]=1, [0x204080]=1, [0x204081]=1}
for i = 0x200088, 0x20008F do WATCH[i] = 1 end
for i = 0x200099, 0x20009A do WATCH[i] = 1 end
for i = 0x2000B0, 0x2000BF do WATCH[i] = 1 end

local function fld(port_sub, name)
  for tag, p in pairs(mac.ioport.ports) do
    if tag:find(port_sub, 1, true) then
      for n, f in pairs(p.fields) do if n == name then return f end end
      for n, f in pairs(p.fields) do if n:find(name .. " ", 1, true) == 1 then return f end end
    end
  end
end
local function adjuster(port) for _, f in pairs(mac.ioport.ports[port].fields) do return f end end

local acts = {}
local function at(t, desc, fn) acts[#acts + 1] = {t = t, desc = desc, fn = fn} end
local function hold(t, port, name, dur)
  at(t, "DOWN " .. name, function() local f = fld(port, name); if f then f:set_value(1) else log("NOFIELD " .. name) end end)
  at(t + dur, "UP " .. name, function() local f = fld(port, name); if f then f:set_value(0) end end)
end
local function slider(t, v)
  at(t, "VOL_APCSEQ := " .. v, function() adjuster(":VOL_APCSEQ").user_value = v end)
  at(t + 1.5, "latch", function() log(("  latch 0x5006BEA6 = 0x%02X, PanelCtrlLatch32 remap 0x5006BEAD = 0x%02X"):format(
    cpu.spaces["program"]:read_u8(0x5006BEA6), cpu.spaces["program"]:read_u8(0x5006BEAD))) end)
end

local consumed = 0
local function drain(win)
  local cl = mac.debugger.consolelog
  local seen, order = {}, {}
  for i = consumed + 1, #cl do
    local w0, v, ra = cl[i]:match("^P (%x+) (%x+) (%x+)")
    if w0 then
      local id = tonumber(w0, 16) & 0xFFFFFF
      local key = ("%06X"):format(id)
      local s = seen[key]
      if not s then s = {n = 0, first = v, w0 = w0, ra = ra}; seen[key] = s; order[#order + 1] = key end
      s.n = s.n + 1; s.last = v
    end
  end
  consumed = #cl
  table.sort(order)
  for _, key in ipairs(order) do
    local s = seen[key]
    log(("ID %-12s %s%s n=%-4d word0=%s first=%s last=%s caller=%s"):format(win, key,
      WATCH[tonumber(key, 16)] and " *" or "  ", s.n, s.w0, s.first, s.last, s.ra))
  end
  log(("WINDOW %s: %d distinct ids"):format(win, #order))
end
local function window(t0, t1, win)
  at(t0, "open " .. win, function() drain("pre-" .. win); cmd("temp2=1") end)
  at(t1, "close " .. win, function() cmd("temp2=0"); drain(win) end)
end

at(1, "breakpoints", function()
  cmd("temp2=0")
  cpu.debug:bpset(0x4C014A56, "temp2", 'printf "P %08x %08x %08x",d0,d1,mdr; g')
  log("armed")
end)
local BUTTONS = {}
for tok in (os.getenv("BUTTONS") or "PAD 1,PERFORMANCE PADS/STOP,PERFORMANCE PADS/AUTO,PERFORMANCE PADS/BANK,FADE IN,FADE OUT,AUTO MODE,PLAY CHORD OFF/ON,MUSIC STYLIST,START/STOP,START/STOP"):gmatch("[^,]+") do BUTTONS[#BUTTONS + 1] = tok end
local t = 20
for k, b in ipairs(BUTTONS) do
  local tag = ("%02d-%s"):format(k, b:gsub("[^%w]", ""))
  window(t, t + 3.2, tag)
  hold(t + 0.2, ":cpanel:", b, 0.3)
  at(t + 3.0, "snap", function() mac.video:snapshot() end)
  hold(t + 3.4, ":cpanel:", "EXIT", 0.3)
  t = t + 4.5
end
at(t, "end", function() drain("end"); OUT:close(); mac:exit() end)

table.sort(acts, function(a, b) return a.t < b.t end)
_G.MS = {}
local i = 1
_G.MS.h = emu.register_periodic(function()
  local t = mac.time.seconds + mac.time.attoseconds / 1e18
  while i <= #acts and t >= acts[i].t do
    local a = acts[i]; i = i + 1
    local ok, err = pcall(a.fn)
    if not ok then log("ERR " .. a.desc .. ": " .. tostring(err)) else log(("[%6.2f] %s"):format(t, a.desc)) end
  end
end)

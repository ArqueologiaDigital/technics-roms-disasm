-- (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
--
-- menu_test.lua -- the program menu in MAME (run_menu_tests.sh runs it): the owner's loader floppy in the
-- drive, a copy of the real KN7000's SD card with a card layout in its root, -bios v13 (program 893). Every
-- check prints "menu_test: <name> PASS|FAIL detail"; the write taps' report goes to MT_OUT/taps.txt.
--
-- MT_MODE:
--   card      the card make card builds: the programs (names, folders, sizes, icons in RAM and on the LCD),
--             in whichever menu folder KN7MENU.TOC put them, equal fatscan.py's (MT_EXPECT); the left buttons
--             pick rows (and open folders), PART SELECT moves, PAGE DOWN / PAGE UP turn pages, LCDR 1 goes back; the menu draws itself again after something else drew
--             on the LCD; holding EXIT leaves to the main screen with no firmware message and no "Continue
--             Next?" (ended()); DISK MENU, STYLE CONVERT, OK bring the menu back; LEAVE (LCDR 4) leaves the same way.
--   fallback  a card of malformed and missing manifests and icons, a long-named folder, a folder without a
--             program, a damaged and a foreign KN7APP.BIN: the list equals fatscan.py's, and RUN on the
--             damaged and the foreign one is refused with the message, the menu staying.
--   run       start MT_PROGRAM (a name in the list) with RUN (MT_TAP: a tap script of the program's own to load
--             first, cnv_romdump test/cpu_tap.lua for pass 9; its PREFILL_END(MT_OUT) is called at the end): the launch block, the program's own header at
--             APP_BASE, the converter calls going to it; with MT_DONE ("addr=value", the program's own
--             "finished" word) wait for it to finish and end (its hold, 0xFE, EXIT, "Continue Next?" YES):
--             the menu is back; then LEAVE (ended()).
--   leave     MT_PROGRAM (a program that goes back to the menu at its quit: Another World) started from the menu
--             and quit with EXIT held gives the menu back with no firmware message and no "Continue Next?"
--             (MT_GAME_UP "addr=value": the program's word that says it runs).
--   buttons   a menu that reads no button (-D BUTTONS_USED=0): each candidate button is pressed in turn;
--             what each changed in IC23 (the panel settings), whether the firmware drew on the LCD, and
--             whether the converter went on being called.
--   end       the menu up (on the fallback card), then LEAVE: how it ends (ended()), also for test builds (END_D).
-- MT_SYMS: test/syms.py's table. MT_PANEL: PANEL_CPR of the BIOS (893 0x5006BE4C), to confirm each press
-- in the firmware's own bitmap. MT_CHGMODE, MT_RQSTATE: what FindEnd must find on the BIOS (893 0x4842B301, 0x5004E3F8;
-- test/endsig.py). MT_POWER=1: POWER OFF at the end (else exit).
local M = manager.machine
local cpu = M.devices[":maincpu"]
local sp = cpu.spaces["program"]
local S = dofile(os.getenv("MT_SYMS"))
local MODE = os.getenv("MT_MODE") or "card"
local OUT = os.getenv("MT_OUT") or "."
local EXPECT = os.getenv("MT_EXPECT") and dofile(os.getenv("MT_EXPECT")) or nil
local PANEL = tonumber(os.getenv("MT_PANEL") or "")
local POWER = (os.getenv("MT_POWER") or "") ~= ""
local CHGMODE, RQSTATE = tonumber(os.getenv("MT_CHGMODE") or ""), tonumber(os.getenv("MT_RQSTATE") or "")
local MSGW = tonumber(os.getenv("MT_MSGW") or "")  -- TtMessage's message number (893 0x5006B59C: MT_SetParam's movhu)
local LV_STATE = S.LOADER_VARS                     -- loader.s: 1 = running an application
local results, fails = {}, 0
local function now() return M.time:as_double() end
local function log(s) print("menu_test: " .. s) end
local function result(name, ok, detail)
  results[#results + 1] = name
  if not ok then fails = fails + 1 end
  log(string.format("%-9s %s  %s", name, ok and "PASS" or "FAIL", detail))
  M.video:snapshot()
end
local function u32(a) return sp:read_u32(a) end
local function cstr(a, n)
  local t = {}
  for i = 0, (n or 64) - 1 do local c = sp:read_u8(a + i); if c == 0 then break end; t[#t + 1] = string.char(c) end
  return table.concat(t)
end
local function appname() return cstr(S.APP_BASE + S.AH_NAME, 32) end
local function mstate() return u32(S.V_STATE) end
local function menu_up() return appname() == "KN7000 PROGRAM MENU 1.0" end   -- (before the taps, which use it)

-- ---- write taps: IC23, the pools, the loader's area, the converter RAM --------------------------
local CODE = { { S.CNV_BASE, S.CNV_END }, { S.T_BASE, S.T_END } }  -- the loader, the menu, an app; the trampoline
local function ours(p) for _, r in ipairs(CODE) do if p >= r[1] and p < r[2] then return true end end; return false end
local T = { ic23 = {}, ic23_ours = 0, ic23_n = 0, pools = {}, pools_ours = 0, loader = {}, loader_bad = 0,
            area = {}, area_foreign = 0, fwlcd = 0 }
local function bump(t, k) t[k] = (t[k] or 0) + 1 end
local function pc() return cpu.state["PC"].value end
local phase = "boot"
local function ic23_tap(base)
  return sp:install_write_tap(base, base + 0x3FFFFFF, string.format("i%08X", base), function(offset, data, mask)
    local p = pc(); T.ic23_n = T.ic23_n + 1
    if ours(p) then T.ic23_ours = T.ic23_ours + 1 end
    bump(T.ic23, string.format("%s pc=%08X", phase, p))
  end)
end
local function pool_tap(base)
  return sp:install_write_tap(base + 0x180000, base + 0x297FFF, string.format("p%08X", base), function(offset, data, mask)
    local p = pc()
    if ours(p) then T.pools_ours = T.pools_ours + 1 end
    bump(T.pools, string.format("%s pc=%08X", phase, p))
  end)
end
local function loader_tap(base)       -- 0x502B8000-0x502B9FFF: the loader's own code, the firmware loading it, and a
  local d = base - 0x50000000         -- program the menu started (the ROM dumper sets SV_FG/SV_BG/SV_SCALE, as the
  return sp:install_write_tap(S.CNV_BASE + d, S.APP_BASE - 1 + d, string.format("l%08X", base), function(offset, data, mask)
    local p = pc()                    -- loader's contract has it): never the menu's code or the trampoline's
    local kind = "loader"
    if p >= S.APP_BASE and p < S.CNV_END and not menu_up() then kind = "program"
    elseif p >= S.APP_BASE and p < S.CNV_END then kind = "MENU"; T.loader_bad = T.loader_bad + 1
    elseif p >= S.T_BASE and p < S.T_END then kind = "TRAMPOLINE"; T.loader_bad = T.loader_bad + 1
    elseif p < S.CNV_BASE or p >= S.APP_BASE then
      if u32(S.SVC) ~= 0x53374E4B then kind = "loading" else kind = "FOREIGN"; T.loader_bad = T.loader_bad + 1 end
    end
    bump(T.loader, string.format("%-8s pc=%08X", kind, p))
  end)
end
local function area_tap(base)         -- the RAM a converter may use: who writes there, and where
  local d = base - 0x50000000
  return sp:install_write_tap(S.APP_BASE + d, 0x5037A000 - 1 + d, string.format("a%08X", base), function(offset, data, mask)
    local a = offset - d
    if a >= 0x5031B000 and a < 0x5031C000 then return end     -- the mailbox page
    local p = pc()
    if ours(p) then return end
    local kind
    if u32(LV_STATE) ~= 1 and a < S.CNV_END then kind = "loading"          -- the firmware or loader loading
    elseif menu_up() and u32(S.V_INREAD) == 1 and a >= u32(S.V_RDDST) and a < u32(S.V_RDDST) + u32(S.V_RDLEN) then
      kind = "menu-sdread"                                                   -- a raw read the menu asked for
    elseif not menu_up() then kind = "app"                                   -- while a program runs: its business
    else kind = "FOREIGN"; T.area_foreign = T.area_foreign + 1 end
    bump(T.area, string.format("%-11s pc=%08X page=%08X", kind, p, a & 0xFFFFF000))
  end)
end
local function lcd_tap()              -- the firmware's own drawing on the LCD (anything not from the converter code)
  return sp:install_write_tap(0x9CE00000, 0x9CE00000 + 240 * 1280 - 1, "lcd", function(offset, data, mask)
    if not ours(pc()) then T.fwlcd = T.fwlcd + 1 end
  end)
end
MT_TAPS = { ic23_tap(0x44000000), ic23_tap(0x84000000), pool_tap(0x50000000), pool_tap(0x90000000),
            loader_tap(0x50000000), loader_tap(0x90000000), area_tap(0x50000000), area_tap(0x90000000), lcd_tap() }
local function dump_table(f, t)
  local ks = {}
  for k in pairs(t) do ks[#ks + 1] = k end
  table.sort(ks)
  for _, k in ipairs(ks) do f:write(string.format("  %s %d\n", k, t[k])) end
end
local function report()
  local f = io.open(OUT .. "/taps.txt", "w")
  f:write(string.format("IC23 writes %d, from the converter's code (loader, menu, programs, trampoline) %d\n", T.ic23_n, T.ic23_ours))
  dump_table(f, T.ic23)
  f:write(string.format("pool writes from the converter's code %d\n", T.pools_ours)); dump_table(f, T.pools)
  f:write(string.format("loader area: writes by the menu, the trampoline or a foreign PC %d\n", T.loader_bad)); dump_table(f, T.loader)
  f:write(string.format("converter RAM: foreign writes %d\n", T.area_foreign)); dump_table(f, T.area)
  f:close()
  result("taps", T.ic23_ours == 0 and T.pools_ours == 0 and T.loader_bad == 0 and T.area_foreign == 0,
    string.format("IC23 writes from the converter's code %d (the firmware's own: %d), pools %d, loader area foreign %d, converter RAM foreign %d (%s/taps.txt)",
      T.ic23_ours, T.ic23_n - T.ic23_ours, T.pools_ours, T.loader_bad, T.area_foreign, OUT))
end

-- ---- inputs ------------------------------------------------------------------------------------
local function field(tag, mask)
  local p = M.ioport.ports[":cpanel:" .. tag]
  for _, f in pairs(p.fields) do if f.mask == mask then return f end end
end
local function wait(s) local t = now() + s; while now() < t do coroutine.yield() end end
local function wait_until(cond, s) local t = now() + s; while now() < t do if cond() then return true end; coroutine.yield() end; return cond() end
local LOST = 0
local function press(tag, mask, hold)  -- held until the firmware's bitmap shows it (tried again if not)
  local f = field(tag, mask)
  local seg = tonumber(tag:match("SEG(%d+)"))
  local byte = PANEL and (PANEL + seg + (tag:sub(1, 3) == "CPR" and 0 or 0x30))
  for try = 1, 5 do
    f:set_value(1)
    local seen = not byte or wait_until(function() return (sp:read_u8(byte) & mask) ~= 0 end, 1.0)
    if seen then wait(hold or 0.3); f:set_value(0); wait(0.5); return true end
    f:set_value(0); LOST = LOST + 1; wait(1.0)
  end
  return false
end
local B = { L1 = { "CPL_SEG0", 0x02 }, L2 = { "CPL_SEG0", 0x08 }, L3 = { "CPL_SEG0", 0x20 }, L4 = { "CPL_SEG0", 0x01 },
            L5 = { "CPL_SEG0", 0x04 }, R1 = { "CPR_SEG5", 0x10 }, R2 = { "CPR_SEG5", 0x20 }, R3 = { "CPR_SEG7", 0x01 },
            R4 = { "CPR_SEG6", 0x01 }, R5 = { "CPR_SEG5", 0x01 }, EXIT = { "CPC_SEG11", 0x80 },
            PGUP = { "CPC_SEG11", 0x10 }, PGDN = { "CPC_SEG11", 0x20 }, PREV = { "CPR_SEG2", 0x01 },
            NEXT = { "CPR_SEG1", 0x02 } }
local function btn(name, hold) return press(B[name][1], B[name][2], hold) end
local YES, NO = B.R3, B.R4            -- "Continue Next?" (right buttons 3 and 4)

local function to_menu(c_old)         -- DISK MENU, STYLE CONVERT (left button 3), OK (right button 4) until loaded
  -- (c_old: the loader's calls in the session before; the firmware loads the loader afresh, which counts from 0)
  wait_until(function() return now() > 30 end, 60)
  press("CPR_SEG1", 0x04); wait(5)
  press("CPL_SEG0", 0x20); wait(7)
  phase = "converter"
  for i = 1, 8 do
    press("CPR_SEG6", 0x01)
    if wait_until(function() return u32(LV_STATE) == 1 and (not c_old or u32(S.SVC + S.SV_CALLS) < c_old) end, 8) then break end
    log(string.format("OK press %d not taken at t=%.0f s; again", i, now()))
  end
  return wait_until(function() return menu_up() and mstate() == S.ST_MENU end, 120)  -- (ST_TOC is 8: ">=" took it for the menu)
end

-- ---- what the menu shows -------------------------------------------------------------------------
local function rec(i) return u32(S.ORDER + 4 * i) end
local function icon_ok_ram(r, e)      -- the record's icon pixels = fatscan's (or the default icon)
  local p = u32(r + S.PR_ICONP)
  if e.icon == nil then return p == S.DefaultIcon end
  for k = 1, 1024 do if sp:read_u16(p + 2 * (k - 1)) ~= e.icon[k] then return false end end
  return true
end
local function icon_on_lcd(row, r)    -- the LCD at row's icon position = the record's icon pixels
  local p = u32(r + S.PR_ICONP)
  local y0 = S.TITLE_H + row * S.ROW_H + S.ICON_DY
  for y = 0, 31 do for x = 0, 31 do
    if sp:read_u16(S.MFB + (y0 + y) * S.FB_STRIDE + (8 + x) * 2) ~= sp:read_u16(p + (y * 32 + x) * 2) then return false end
  end end
  return true
end
local function lower(t) return (t:gsub("%u", function(c) return c:lower() end)) end
-- the programs in every menu folder, as one list sorted by name (fatscan.py's order); and a view's names
local function programs()
  local all = {}
  for i = 0, u32(S.V_NCAND) - 1 do
    local r = S.PROG_TAB + i * S.PR_LEN
    if (u32(r + S.PR_FLAGS) & S.PF_APP) ~= 0 then all[#all + 1] = r end
  end
  table.sort(all, function(a, b) return lower(cstr(a + S.PR_NAME)) < lower(cstr(b + S.PR_NAME)) end)
  return all
end
local function check_list(tag)
  if u32(S.V_NREC) > u32(S.V_NCAND) then  -- KN7MENU.TOC's folders: all programs, wherever they are listed
    local all, bad = programs(), {}
    local ok = EXPECT ~= nil and #all == #EXPECT
    for i = 1, math.min(#all, #(EXPECT or {})) do
      local r, e = all[i], EXPECT[i]
      local fl = u32(r + S.PR_FLAGS)
      if not (cstr(r + S.PR_NAME) == e.name and cstr(r + S.PR_DIR, 16) == e.dir and u32(r + S.PR_APPSZ) == e.appsize
        and (fl & S.PF_TOC) ~= 0 and icon_ok_ram(r, e)) then ok = false; bad[#bad + 1] = string.format("#%d %q flags %03X", i, cstr(r + S.PR_NAME), fl) end
    end
    local names = {}
    for i = 1, u32(S.V_NPROG) do names[#names + 1] = cstr(rec(i - 1) + S.PR_NAME) end
    result(tag, ok and u32(S.V_TOCST) == S.TOC_USED, string.format("KN7MENU.TOC %d, %d programs (fatscan.py: %d) in %d menu folders, %d placed by it, %d folders looked into; the top: %s%s",
      u32(S.V_TOCST), #all, EXPECT and #EXPECT or -1, u32(S.V_NREC) - u32(S.V_NCAND), u32(S.V_TOCPROGS), u32(S.V_NFOLDERS),
      table.concat(names, " | "), #bad > 0 and ("; DIFFER: " .. table.concat(bad, ", ")) or ""))
    return
  end
  local n = u32(S.V_NPROG)
  local ok, bad = EXPECT ~= nil and n == #EXPECT, {}
  for i = 1, math.min(n, #(EXPECT or {})) do
    local r, e = rec(i - 1), EXPECT[i]
    local fl = u32(r + S.PR_FLAGS)
    local good = cstr(r + S.PR_NAME) == e.name and cstr(r + S.PR_DIR, 16) == e.dir and u32(r + S.PR_APPSZ) == e.appsize
      and ((fl & S.PF_MNAME) ~= 0) == e.mname and ((fl & S.PF_MANIFEST) ~= 0) == e.manifest
      and ((fl & S.PF_ICONBAD) ~= 0) == e.iconbad and icon_ok_ram(r, e)
    if not good then ok = false; bad[#bad + 1] = string.format("#%d %q flags %02X", i, cstr(r + S.PR_NAME), fl) end
  end
  local names = {}
  for i = 1, n do names[#names + 1] = cstr(rec(i - 1) + S.PR_NAME) end
  result(tag, ok, string.format("%d programs (fatscan.py: %d), %d folders looked into: %s%s", n, EXPECT and #EXPECT or -1,
    u32(S.V_NCAND), table.concat(names, " | "), #bad > 0 and ("; DIFFER: " .. table.concat(bad, ", ")) or ""))
end
local function lcd_start()             -- the S1D13806's start address, REG[042h]-[044h] (words)
  return sp:read_u8(S.LCDC + 0x42) | (sp:read_u8(S.LCDC + 0x43) << 8) | (sp:read_u8(S.LCDC + 0x44) << 16)
end
local function page_on_lcd()          -- every row of the page shown has its program's icon on the LCD
  local top, n, okc = u32(S.V_TOP), u32(S.V_NPROG), 0
  local rows = math.min(S.ROWS, n - top)
  for row = 0, rows - 1 do if icon_on_lcd(row, rec(top + row)) then okc = okc + 1 end end
  return okc == rows, string.format("page from %d: %d of %d icons on the LCD", top, okc, rows)
end
local function sel_is(want, label)
  local ok, d = page_on_lcd()
  return u32(S.V_SEL) == want and ok, string.format("%s: selected %d (want %d), top %d; %s", label, u32(S.V_SEL), want, u32(S.V_TOP), d)
end
local function index_of(name)
  for i = 0, u32(S.V_NPROG) - 1 do if cstr(rec(i) + S.PR_NAME) == name then return i end end
end
local function select(i)              -- page to it, then its row's left button
  while u32(S.V_TOP) + S.ROWS <= i do btn("PGDN"); wait(1) end
  while u32(S.V_TOP) > i do btn("PGUP"); wait(1) end
  btn("L" .. (i - u32(S.V_TOP) + 1)); wait(1)
  return u32(S.V_SEL) == i
end
-- the program named `name` shown: the menu folders KN7MENU.TOC put it in opened from the top, its index then
local function open_to(name)
  local target
  for i = 0, u32(S.V_NREC) - 1 do
    local r = S.PROG_TAB + i * S.PR_LEN
    if (u32(r + S.PR_FLAGS) & S.PF_APP) ~= 0 and cstr(r + S.PR_NAME) == name then target = r end
  end
  if not target then return nil end
  local path, cat = {}, u32(target + S.PR_CAT)
  while cat ~= 0 do
    for i = u32(S.V_NCAND), u32(S.V_NREC) - 1 do
      local r = S.PROG_TAB + i * S.PR_LEN
      if u32(r + S.PR_CATID) == cat then table.insert(path, 1, cstr(r + S.PR_NAME)); cat = u32(r + S.PR_CAT) end
    end
  end
  while u32(S.V_LEVEL) ~= 0 do btn("R1"); wait(1) end
  log(string.format("open_to %q: its folders %s", name, table.concat(path, " / ")))
  for _, f in ipairs(path) do
    local i = index_of(f)
    log(string.format("  folder %q at %s; level %d", f, tostring(i), u32(S.V_LEVEL)))
    if not i then return nil end
    select(i)
  end
  return index_of(name)
end
-- After 0xFE the firmware shows its message (title 3) for about 3 s, then "Continue Next?" (title 0x4C) by
-- itself; EXIT dismisses the message sooner, but pressed on "Continue Next?" it cancels it (to title 0x46).
-- So: wait for title 0x4C (the title table's word, 0x500009A0 on 893 and 941), with EXIT only when the
-- message stays; then the answer.
local TITLE, CONTINUE = 0x500009A0, 0x000F004C
local function continue_next(answer)
  local up = wait_until(function() return u32(TITLE) == CONTINUE end, 10)
  if not up then press("CPC_SEG11", 0x80); up = wait_until(function() return u32(TITLE) == CONTINUE end, 8) end
  M.video:snapshot()
  log(string.format("\"Continue Next?\" %s (title %05X)", up and "up" or "NOT up", u32(TITLE)))
  press(answer[1], answer[2]); wait(3)
end

-- The menu's own end (README.md "Ending"), after act() (LEAVE, or EXIT held): every mode/title the firmware takes from
-- the press on is logged with its time (mode word 0x50000980 = ModeProc_Table[1], labels.sym 0x5000097C; title word
-- 0x500009A0). The firmware must end on the main screen (MD_NORMAL), never having opened its message (title F0003,
-- message 0x4A "ERROR!") nor "Continue Next?" (F004C); the menu's last answer RQ_QUIET, the converter no longer called,
-- the LCD the firmware's. Its frame (display memory from 0, RGB565) goes to OUT/<label>-<s>s.ppm 0.5, 2 and 5 s after.
local MODEW, MD_NORMAL = 0x50000980, 0x000E0001
local function lcd_ppm(name)
  local f = io.open(OUT .. "/" .. name .. ".ppm", "wb")
  if not f then return end
  f:write("P6\n640 241\n255\n")
  for y = 0, 240 do
    local row = {}
    for x = 0, 639 do
      local p = sp:read_u16(S.FB + y * S.FB_STRIDE + x * 2)
      row[#row + 1] = string.char(((p >> 11) & 31) * 255 // 31, ((p >> 5) & 63) * 255 // 63, (p & 31) * 255 // 31)
    end
    f:write(table.concat(row))
  end
  f:close()
end
local function ended(label, act)
  local seen, t0, watch = {}, now(), true
  local last = string.format("%05X/%05X", u32(MODEW), u32(TITLE))
  local first = last
  MT_ENDWATCH = emu.add_machine_frame_notifier(function()
    if not watch then return end
    local k = string.format("%05X/%05X", u32(MODEW), u32(TITLE))
    if k ~= last then seen[#seen + 1] = string.format("%s@%.2f", k, now() - t0); last = k end
  end)
  local fw = u32(S.V_LCDSAVE)
  act()
  local ok = wait_until(function() return mstate() == S.ST_END end, 5)
  local te = now()
  for _, d in ipairs({ 0.5, 2, 5 }) do wait_until(function() return now() >= te + d end, d + 1); lcd_ppm(string.format("%s-%gs", label, d)) end
  local calls = u32(S.SVC + S.SV_CALLS); wait(3)
  watch = false
  local bad = false
  for _, x in ipairs(seen) do if x:match("/F0003@") or x:match("/F004C@") then bad = true end end
  local rq = sp:read_u8(S.MAILBOX)
  result(label, ok and not bad and u32(MODEW) == MD_NORMAL and rq == S.RQ_QUIET and u32(S.SVC + S.SV_CALLS) == calls
    and u32(S.V_LCDMINE) == 0 and lcd_start() == fw,
    string.format("menu state %d, last answer %d (RQ_QUIET %d), calls %d then none in 3 s: %s; LCD start %05X (the firmware's %05X); mode/title %s, then %s; now %05X/%05X%s",
      mstate(), rq, S.RQ_QUIET or -1, calls, tostring(u32(S.SVC + S.SV_CALLS) == calls), lcd_start(), fw, first,
      #seen > 0 and table.concat(seen, " ") or "unchanged", u32(MODEW), u32(TITLE),
      MSGW and string.format("; message word %04X", sp:read_u16(MSGW)) or ""))
end

-- ---- the modes ---------------------------------------------------------------------------------
local function card()
  local ok = to_menu()
  result("menu", ok and u32(S.V_PANEL) == PANEL, string.format("the loader (state %d) runs %q; menu state %d, panel %08X, ms counter %08X, calls %d",
    u32(LV_STATE), appname(), mstate(), u32(S.V_PANEL), u32(S.V_MS), u32(S.V_CALLS)))
  result("findend", S.V_CHGMODE and u32(S.V_CHGMODE) == CHGMODE and u32(S.V_RQSTATE) == RQSTATE, string.format("FindEnd: ChangeMode %08X (want %08X), state byte %08X (want %08X) = %d",
    S.V_CHGMODE and u32(S.V_CHGMODE) or 0, CHGMODE or 0, S.V_RQSTATE and u32(S.V_RQSTATE) or 0, RQSTATE or 0,
    S.V_RQSTATE and u32(S.V_RQSTATE) ~= 0 and sp:read_u8(u32(S.V_RQSTATE)) or -1))
  if not ok then return end
  wait(3)
  check_list("list")
  local good, d = sel_is(0, "first page")
  local st = lcd_start()               -- the controller on the menu's own frame (MFB), the firmware's start saved
  local mine = u32(S.V_LCDMINE) == 1 and st == u32(S.V_LCDSTART) and st == u32(S.V_LCDSAVE) + S.MFB_OFS // 2
  result("screen", good and mine and u32(S.V_NREDRAW) == 0, d .. string.format("; the LCD's start %05X (MFB's %05X, the firmware's %05X), " ..
    "set back %d times; full redraws %d", st, u32(S.V_LCDSTART), u32(S.V_LCDSAVE), u32(S.V_LCDRESET), u32(S.V_NREDRAW)))
  local steps = {}
  local function step(b, want, label) btn(b); wait(1); local g, dd = sel_is(want, label); steps[#steps + 1] = (g and "" or "NOT ") .. dd; return g end
  local n = u32(S.V_NPROG)
  local n0, trail = n, nil
  local all = true
  if u32(S.V_NREC) > u32(S.V_NCAND) then  -- menu folders: into the largest at each level to a list of programs, and back
    trail = {}
    local function below(id)  -- programs anywhere under menu folder id
      local c = 0
      for i = 0, u32(S.V_NCAND) - 1 do
        local r = S.PROG_TAB + i * S.PR_LEN
        local cat = u32(r + S.PR_CAT)
        while cat ~= 0 and cat ~= id do
          local up = 0
          for j = u32(S.V_NCAND), u32(S.V_NREC) - 1 do
            local f = S.PROG_TAB + j * S.PR_LEN
            if u32(f + S.PR_CATID) == cat then up = u32(f + S.PR_CAT) end
          end
          cat = up
        end
        if cat == id and (u32(r + S.PR_FLAGS) & S.PF_APP) ~= 0 then c = c + 1 end
      end
      return c
    end
    local function largest()  -- the folder in the view with the most programs under it, or nil
      local best, most
      for i = 0, n - 1 do
        local r = rec(i)
        if (u32(r + S.PR_FLAGS) & S.PF_FOLDER) ~= 0 then
          local c = below(u32(r + S.PR_CATID))
          if most == nil or c > most then best, most = i, c end
        end
      end
      return best
    end
    while largest() do
      local k = largest()
      local name = cstr(rec(k) + S.PR_NAME)
      trail[#trail + 1] = { k, name }
      select(k)
      n = u32(S.V_NPROG)
      local g, dd = sel_is(0, "opened " .. name)
      g = g and u32(S.V_LEVEL) ~= 0 and u32(S.V_TITLEP) ~= 0 and cstr(u32(S.V_TITLEP)) == name
      steps[#steps + 1] = (g and "" or "NOT ") .. dd .. string.format(", %d entries", n)
      all = all and g
      if n == 0 then break end
    end
  end
  all = all and (n < 3 or (step("L3", 2, "LCDL 3") and step("NEXT", math.min(3, n - 1), "PART SELECT RIGHT 1") and step("PREV", 2, "PART SELECT LEFT")))
  if n > S.ROWS then
    all = step("PGDN", S.ROWS, "PAGE DOWN") and step("PGUP", 0, "PAGE UP") and all
    all = step("L5", 4, "LCDL 5") and step("NEXT", 5, "PART SELECT RIGHT 1 onto page 2") and step("PREV", 4, "PART SELECT LEFT back") and all
  end
  if trail then
    for k = #trail, 1, -1 do all = step("R1", trail[k][1], "LCDR 1, BACK to " .. (k > 1 and trail[k - 1][2] or "the top")) and all end
    all = all and u32(S.V_LEVEL) == 0
  end
  result("navigate", all, table.concat(steps, "; "))
  local r0 = u32(S.V_NREDRAW)         -- something else draws on the LCD: the menu draws itself again
  for y = 100, 140 do for x = 0, 639, 2 do sp:write_u32(S.MFB + y * S.FB_STRIDE + x * 2, 0xFFFFFFFF) end end
  wait(2)
  good, d = page_on_lcd()
  result("repaint", u32(S.V_NREDRAW) > r0 and good, string.format("full redraws %d -> %d; %s", r0, u32(S.V_NREDRAW), d))
  ended("exit", function() press("CPC_SEG11", 0x80, 2.0) end)   -- hold EXIT: the main screen
  local calls = u32(S.SVC + S.SV_CALLS)
  ok = to_menu(calls)                 -- DISK MENU, STYLE CONVERT, OK: the firmware loads the loader, which loads the menu
  wait(2)
  result("again", ok and u32(S.V_NPROG) == n0, string.format("after EXIT held: DISK MENU, STYLE CONVERT, OK start the menu again (calls %d, menu state %d, %d programs)",
    u32(S.SVC + S.SV_CALLS), mstate(), u32(S.V_NPROG)))
  wait(3)
  ended("leave", function() btn("R4") end)   -- LEAVE: the main screen
  phase = "after"
end

local function fallback()
  local ok = to_menu()
  result("menu", ok, string.format("menu state %d, %d programs", mstate(), u32(S.V_NPROG)))
  if not ok then return end
  wait(3)
  check_list("list")
  local good, d = page_on_lcd()
  result("screen", good, d)
  for _, c in ipairs({ { "crc", S.CK_CRC, S.str_ck_crc }, { "header", S.CK_HEADER, S.str_ck_header } }) do
    local want
    for i, e in ipairs(EXPECT) do if e.check == c[1] then want = i - 1 end end
    if want == nil then result("refuse-" .. c[1], false, "no such program in the test card") else
      select(want)
      local r = rec(want)
      btn("R5")                       -- RUN
      ok = wait_until(function() return u32(r + S.PR_CHECK) ~= S.CK_NONE and mstate() == S.ST_MENU end, 20)
      wait(1)
      result("refuse-" .. c[1], ok and u32(r + S.PR_CHECK) == c[2] and u32(S.V_MSG) == c[3] and menu_up() and u32(S.V_LAUNCHES) == 0,
        string.format("RUN on %q: check %d (want %d), message %q, still the menu %s", cstr(r + S.PR_NAME), u32(r + S.PR_CHECK), c[2],
          u32(S.V_MSG) ~= 0 and cstr(u32(S.V_MSG), 96) or "", tostring(menu_up())))
    end
  end
  ended("leave", function() btn("R4") end)
  phase = "after"
end

local function run()
  local ok = to_menu()
  if os.getenv("MT_TAP") then dofile(os.getenv("MT_TAP")) end    -- e.g. cpu_tap.lua: the probe's own accounting
  result("menu", ok, string.format("menu state %d, %d programs", mstate(), u32(S.V_NPROG)))
  if not ok then return end
  wait(2)
  local want = os.getenv("MT_PROGRAM")
  wait(3)  -- (as card() does: a press at once, as the list first shows, is not taken)
  local i = open_to(want)
  if i == nil then result("start", false, "no program named " .. want); return end
  local r = rec(i)
  local dir, size = cstr(r + S.PR_DIR, 16), u32(r + S.PR_APPSZ)
  ok = select(i)
  local c0 = u32(S.SVC + S.SV_CALLS)
  -- every word of the application area the trampoline writes (its copy and its zeros), and what it writes
  -- past the file's end: the whole area must be written, and with zeros after the file but the launch block
  local seen, nseen, nonzero = {}, 0, 0
  local function tr(p) return p >= S.T_CODE and p < S.T_CODE + S.T_CODE_MAX end
  MT_LAUNCHTAP = sp:install_write_tap(S.APP_BASE, S.CNV_END - 1, "launch", function(offset, data, mask)
    if not tr(pc()) then return end
    local w = (offset - S.APP_BASE) // 4
    if not seen[w] then seen[w] = true; nseen = nseen + 1 end
    if offset >= S.APP_BASE + ((size + 3) & ~3) and offset < S.LB_ADDR and (data & mask) ~= 0 then nonzero = nonzero + 1 end
  end)
  local fw, back = u32(S.V_LCDSAVE), false   -- the firmware's start address written back before the program runs
  MT_STARTTAP = sp:install_write_tap(S.LCDC + 0x42, S.LCDC + 0x43, "lcdstart", function(offset, data, mask)
    if ((data & mask) >> ((offset & 2) * 8)) & 0xFFFF == fw & 0xFFFF then back = true end
  end)
  btn("R5")                           -- RUN
  ok = ok and wait_until(function() return not menu_up() end, 30)
  wait(1)
  MT_STARTTAP:remove()
  result("lcd-run", back, string.format("RUN: the firmware's LCD start %05X written back before the program (the LCD's now %05X)", fw, lcd_start()))
  local lb = S.LB_ADDR
  local started = ok and u32(lb + S.LB_MAGIC) == S.LAUNCH_MAGIC and u32(lb + S.LB_CHECK) == S.LAUNCH_CHECK
    and cstr(lb + S.LB_DIR, 16) == dir and cstr(lb + S.LB_PREFIX, 16) == dir .. "\\" and cstr(lb + S.LB_PATH, 32) == "C:\\" .. dir
    and u32(lb + S.LB_SIZE) == size and u32(S.APP_BASE + S.AH_SIZE) == size and u32(S.T_DATA + S.TD_RESULT) == 0
    and u32(LV_STATE) == 1 and u32(S.SVC + S.SV_CALLS) > c0
  result("start", started, string.format("RUN on %q: APP_BASE holds %q (%d bytes), launch block %08X dir %q prefix %q path %q name %q; trampoline result %d; loader state %d, calls %d -> %d",
    want, appname(), u32(S.APP_BASE + S.AH_SIZE), u32(lb), cstr(lb + S.LB_DIR, 16), cstr(lb + S.LB_PREFIX, 16), cstr(lb + S.LB_PATH, 32),
    cstr(lb + S.LB_NAME), u32(S.T_DATA + S.TD_RESULT), u32(LV_STATE), c0, u32(S.SVC + S.SV_CALLS)))
  MT_LAUNCHTAP:remove()
  local words = (S.CNV_END - S.APP_BASE) // 4
  result("area", nseen == words and nonzero == 0, string.format("the trampoline wrote %d of the application area's %d words (the program, then zeros), %d non-zero writes between the program's end and the launch block",
    nseen, words, nonzero))
  local done = os.getenv("MT_DONE")
  if not done then return end
  local da, dv = done:match("(%w+)=(%w+)")
  da, dv = tonumber(da), tonumber(dv)
  ok = wait_until(function() return u32(da) == dv end, tonumber(os.getenv("MT_DONE_S") or "1800"))
  result("finished", ok, string.format("the program's word %08X = %d at t=%.0f s", da, u32(da), now()))
  ok = wait_until(function() return u32(LV_STATE) == 3 end, 120)   -- its hold, then 0xFE
  continue_next(YES)                  -- YES: the loader loads the root's KN7APP.BIN: the menu
  ok = ok and wait_until(function() return menu_up() and mstate() == S.ST_MENU end, 90)
  wait(2)
  result("back", ok and u32(S.V_NPROG) > 0, string.format("YES at \"Continue Next?\": %q again, state %d, %d programs, launch block now %08X",
    appname(), mstate(), u32(S.V_NPROG), u32(S.LB_ADDR)))
  ended("leave", function() btn("R4") end)
  phase = "after"
end

-- leave (Felipe 2026-11-02): a program started from the menu that goes back to it by itself at its quit (Another World:
-- technics-anotherworld kn7000/src/chain.s) gives the menu back with no firmware message and no "Continue Next?".
-- MT_PROGRAM is started with RUN (MT_GAME_UP "addr=value": its word that says it runs) and quit with EXIT held: the
-- menu must be back, its list shown, and the firmware's titles never "Continue Next?" (0x000F004C) nor its message
-- (0x000F0003). Every title the firmware takes is logged with its time; snapshots 0.2, 0.5, 1, 2 and 4 s after EXIT.
-- (Leaving the menu itself goes to the main screen with neither: README.md "Ending"; card() checks it with ended().)
local function leave()
  local seen, watch = {}, false
  MT_TITLES = emu.add_machine_frame_notifier(function()
    if not watch then return end
    local t = u32(TITLE)
    if t ~= seen.last then seen[#seen + 1] = string.format("%05X@%.2f", t, now() - seen.t0); seen.last = t end
  end)
  local function bad() for _, x in ipairs(seen) do if x:match("^F004C@") or x:match("^F0003@") then return true end end; return false end
  local ok = to_menu()
  result("menu", ok, string.format("menu state %d, %d programs", mstate(), u32(S.V_NPROG)))
  if not ok then return end
  wait(3)
  local want = os.getenv("MT_PROGRAM") or "Another World"
  local i = open_to(want)
  if i == nil then result("game", false, "no program named " .. want); return end
  select(i)
  M.video:snapshot()                  -- the program's row selected
  -- from RUN on, a line whenever the LCD's start address or a word of MT_WATCH ("addr,addr,...") changes, with its
  -- time; snapshots 0.1 .. 4 s after RUN (what shows between the menu and the program's first picture)
  local wl = {}
  for a in (os.getenv("MT_WATCH") or ""):gmatch("%w+") do wl[#wl + 1] = tonumber(a) end
  local t_run, lastw = now(), nil
  MT_RUNWATCH = emu.add_machine_frame_notifier(function()
    local v = { string.format("start %05X", lcd_start()) }
    for _, a in ipairs(wl) do v[#v + 1] = string.format("%08X=%X", a, u32(a)) end
    local line = table.concat(v, " ")
    if line ~= lastw then log(string.format("run+%.3f s: %s", now() - t_run, line)); lastw = line end
  end)
  btn("R5")                           -- RUN
  for _, d in ipairs({ 0.1, 0.2, 0.3, 0.4, 1, 2 }) do wait(d); M.video:snapshot() end
  local ga, gv = (os.getenv("MT_GAME_UP") or ""):match("(%w+)=(%w+)")
  ga, gv = tonumber(ga), tonumber(gv)
  ok = wait_until(function() return not menu_up() end, 30) and (not ga or wait_until(function() return u32(ga) == gv end, 120))
  MT_RUNWATCH = nil
  result("game", ok, string.format("RUN on %q: %q runs (word %s = %s)", want, appname(), tostring(ga), ga and u32(ga) or "-"))
  wait(5)
  seen = { t0 = now(), last = u32(TITLE) }; watch = true
  local t0 = now()
  press("CPC_SEG11", 0x80, 2.0)       -- EXIT held: the program quits
  ok = wait_until(function() return menu_up() and mstate() == S.ST_MENU end, 60)
  local dt = now() - t0
  for _, d in ipairs({ 0.2, 0.3, 0.5, 1, 2 }) do wait(d); M.video:snapshot() end
  wait(2)
  watch = false
  result("back", ok and not bad() and u32(S.V_NPROG) > 0, string.format("EXIT held in %q: the menu %s %.1f s after the press, %d programs; the firmware's titles %s",
    want, ok and "up" or "NOT up", dt, u32(S.V_NPROG), #seen > 0 and table.concat(seen, " ") or "unchanged"))
  phase = "after"
end

-- end: the menu up, then LEAVE (ended()); run_menu_tests.sh's END_D gives the test builds that end as before
-- (END_WITH_FE) or with ChangeMode and 0xFE (END_FE_AFTER_MODE), to see how those end.
local function endonly()
  local ok = to_menu()
  result("menu", ok, string.format("%q, menu state %d, %d programs", appname(), mstate(), u32(S.V_NPROG)))
  if not ok then return end
  wait(3)
  ended("leave", function() btn("R4") end)
  phase = "after"
end

local function buttons()
  local ok = to_menu()
  result("menu", ok, string.format("menu state %d (it reads no button: BUTTONS_USED %d)", mstate(), S.BUTTONS_USED or -1))
  if not ok then return end
  wait(3)
  local function ic23() return sp:read_range(0x84000000, 0x8403FFFF, 8) end
  local function diff(a, b)
    local d = {}
    for i = 1, #a do if a:byte(i) ~= b:byte(i) then d[#d + 1] = string.format("%05X", i - 1) end end
    return table.concat(d, ",")
  end
  local order = { "L1", "L2", "L3", "L4", "L5", "R1", "R2", "R3", "R4", "R5", "PREV", "NEXT", "PGUP", "PGDN", "EXIT" }
  local lines, allgood = {}, true
  for _, b in ipairs(order) do
    local h0, l0, c0 = ic23(), T.fwlcd, u32(S.V_CALLS)
    local seen = btn(b, 0.4)
    wait(2.5)
    local d, lcd, calls = diff(h0, ic23()), T.fwlcd - l0, u32(S.V_CALLS) - c0
    local good = seen and d == "" and lcd == 0 and calls > 10 and menu_up()
    allgood = allgood and good
    lines[#lines + 1] = string.format("%s: %s IC23 %s, firmware LCD stores %d, converter calls %d", b,
      seen and "seen," or "NOT SEEN,", d == "" and "unchanged" or ("CHANGED at " .. d), lcd, calls)
    log("button " .. lines[#lines])
    M.video:snapshot()
  end
  result("buttons", allgood, table.concat(lines, "; "))
end

local function finish()
  wait(3)
  report()
  if _G.PREFILL_END then _G.PREFILL_END(OUT) end
  log(string.format("%d checks, %d failed (t=%.0f s); presses the emulated panel lost and the harness repeated: %d", #results, fails, now(), LOST))
  if POWER then
    for _, fl in pairs(M.ioport.ports[":POWER"].fields) do fl:set_value(1) end
  else
    M:exit()
  end
end

local co = coroutine.create(function()
  if MODE == "card" then card() elseif MODE == "fallback" then fallback() elseif MODE == "run" then run()
  elseif MODE == "buttons" then buttons() elseif MODE == "leave" then leave() elseif MODE == "end" then endonly() end
  finish()
  while true do coroutine.yield() end
end)
MT_TICK = emu.add_machine_frame_notifier(function()
  if coroutine.status(co) ~= "dead" then
    local ok, err = coroutine.resume(co)
    if not ok then log("ERROR " .. tostring(err)); report(); M:exit() end
  end
end)

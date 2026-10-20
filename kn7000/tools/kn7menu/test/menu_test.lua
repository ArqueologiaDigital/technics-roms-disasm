-- (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
--
-- menu_test.lua -- the program menu in MAME (run_menu_tests.sh runs it): the owner's loader floppy in the
-- drive, a copy of the real KN7000's SD card with a card layout in its root, -bios v13 (program 893). Every
-- check prints "menu_test: <name> PASS|FAIL detail"; the write taps' report goes to MT_OUT/taps.txt.
--
-- MT_MODE:
--   card      the card make card builds: the list (names, folders, sizes, icons in RAM and on the LCD)
--             equals fatscan.py's (MT_EXPECT); the left buttons pick rows, PART SELECT moves, LCDR 2 / LCDR 1
--             and PAGE DOWN / PAGE UP turn pages; the menu draws itself again after something else drew
--             on the LCD; holding EXIT leaves, "Continue Next?" YES brings the menu back (the loader loads
--             it again); LEAVE (LCDR 4), then NO, leaves STYLE CONVERT.
--   fallback  a card of malformed and missing manifests and icons, a long-named folder, a folder without a
--             program, a damaged and a foreign KN7APP.BIN: the list equals fatscan.py's, and RUN on the
--             damaged and the foreign one is refused with the message, the menu staying.
--   run       start MT_PROGRAM (a name in the list) with RUN (MT_TAP: a tap script of the program's own to load
--             first, cnv_romdump test/cpu_tap.lua for pass 9; its PREFILL_END(MT_OUT) is called at the end): the launch block, the program's own header at
--             APP_BASE, the converter calls going to it; with MT_DONE ("addr=value", the program's own
--             "finished" word) wait for it to finish and end (its hold, 0xFE, EXIT, "Continue Next?" YES):
--             the menu is back; then LEAVE and NO.
--   buttons   a menu that reads no button (-D BUTTONS_USED=0): each candidate button is pressed in turn;
--             what each changed in IC23 (the panel settings), whether the firmware drew on the LCD, and
--             whether the converter went on being called.
-- MT_SYMS: test/syms.py's table. MT_PANEL: PANEL_CPR of the BIOS (893 0x5006BE4C), to confirm each press
-- in the firmware's own bitmap. MT_POWER=1: POWER OFF at the end (else exit).
local M = manager.machine
local cpu = M.devices[":maincpu"]
local sp = cpu.spaces["program"]
local S = dofile(os.getenv("MT_SYMS"))
local MODE = os.getenv("MT_MODE") or "card"
local OUT = os.getenv("MT_OUT") or "."
local EXPECT = os.getenv("MT_EXPECT") and dofile(os.getenv("MT_EXPECT")) or nil
local PANEL = tonumber(os.getenv("MT_PANEL") or "")
local POWER = (os.getenv("MT_POWER") or "") ~= ""
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

local function to_menu()              -- DISK MENU, STYLE CONVERT (left button 3), OK (right button 4) until loaded
  wait_until(function() return now() > 30 end, 60)
  press("CPR_SEG1", 0x04); wait(5)
  press("CPL_SEG0", 0x20); wait(7)
  phase = "converter"
  for i = 1, 8 do
    press("CPR_SEG6", 0x01)
    if wait_until(function() return u32(LV_STATE) == 1 end, 8) then break end
    log(string.format("OK press %d not taken at t=%.0f s; again", i, now()))
  end
  return wait_until(function() return menu_up() and mstate() >= S.ST_MENU end, 120)
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
    if sp:read_u16(S.FB + (y0 + y) * S.FB_STRIDE + (8 + x) * 2) ~= sp:read_u16(p + (y * 32 + x) * 2) then return false end
  end end
  return true
end
local function check_list(tag)
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
  while u32(S.V_TOP) + S.ROWS <= i do btn("R2"); wait(1) end
  while u32(S.V_TOP) > i do btn("R1"); wait(1) end
  btn("L" .. (i - u32(S.V_TOP) + 1)); wait(1)
  return u32(S.V_SEL) == i
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

-- ---- the modes ---------------------------------------------------------------------------------
local function card()
  local ok = to_menu()
  result("menu", ok and u32(S.V_PANEL) == PANEL, string.format("the loader (state %d) runs %q; menu state %d, panel %08X, ms counter %08X, calls %d",
    u32(LV_STATE), appname(), mstate(), u32(S.V_PANEL), u32(S.V_MS), u32(S.V_CALLS)))
  if not ok then return end
  wait(3)
  check_list("list")
  local good, d = sel_is(0, "first page")
  result("screen", good and u32(S.V_NREDRAW) <= 3, d .. string.format("; full redraws after the firmware's paint %d", u32(S.V_NREDRAW)))
  local steps = {}
  local function step(b, want, label) btn(b); wait(1); local g, dd = sel_is(want, label); steps[#steps + 1] = (g and "" or "NOT ") .. dd; return g end
  local n = u32(S.V_NPROG)
  local all = step("L3", 2, "LCDL 3") and step("NEXT", 3, "PART SELECT RIGHT 1") and step("PREV", 2, "PART SELECT LEFT")
  if n > S.ROWS then
    all = step("R2", S.ROWS, "LCDR 2 (page down)") and step("R1", 0, "LCDR 1 (page up)")
      and step("PGDN", S.ROWS, "PAGE DOWN") and step("PGUP", 0, "PAGE UP") and all
    all = step("L5", 4, "LCDL 5") and step("NEXT", 5, "PART SELECT RIGHT 1 onto page 2") and step("PREV", 4, "PART SELECT LEFT back") and all
  end
  result("navigate", all, table.concat(steps, "; "))
  local r0 = u32(S.V_NREDRAW)         -- something else draws on the LCD: the menu draws itself again
  for y = 100, 140 do for x = 0, 639, 2 do sp:write_u32(S.FB + y * S.FB_STRIDE + x * 2, 0xFFFFFFFF) end end
  wait(2)
  good, d = page_on_lcd()
  result("repaint", u32(S.V_NREDRAW) > r0 and good, string.format("full redraws %d -> %d; %s", r0, u32(S.V_NREDRAW), d))
  press("CPC_SEG11", 0x80, 2.0)       -- hold EXIT: leave
  ok = wait_until(function() return mstate() == S.ST_END or not menu_up() end, 5)
  local calls = u32(S.SVC + S.SV_CALLS)
  continue_next(YES)                  -- YES: the loader loads C:\KN7APP.BIN, the menu, again
  ok = ok and wait_until(function() return menu_up() and mstate() == S.ST_MENU and u32(S.SVC + S.SV_CALLS) < calls end, 90)
  wait(2)
  result("again", ok and u32(S.V_NPROG) == n, string.format("EXIT held: the menu ended; YES: the loader started it again (calls %d, menu state %d, %d programs)",
    u32(S.SVC + S.SV_CALLS), mstate(), u32(S.V_NPROG)))
  btn("R4")                           -- LEAVE
  ok = wait_until(function() return mstate() == S.ST_END end, 5)
  continue_next(NO)
  phase = "after"
  calls = u32(S.SVC + S.SV_CALLS); wait(5)
  result("leave", ok and u32(S.SVC + S.SV_CALLS) == calls, "LEAVE, NO: STYLE CONVERT left, the converter is not called any more (snapshot: main screen)")
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
  btn("R4")
  wait_until(function() return mstate() == S.ST_END end, 5)
  continue_next(NO)
  phase = "after"
end

local function run()
  local ok = to_menu()
  if os.getenv("MT_TAP") then dofile(os.getenv("MT_TAP")) end    -- e.g. cpu_tap.lua: the probe's own accounting
  result("menu", ok, string.format("menu state %d, %d programs", mstate(), u32(S.V_NPROG)))
  if not ok then return end
  wait(2)
  local want = os.getenv("MT_PROGRAM")
  local i = index_of(want)
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
  btn("R5")                           -- RUN
  ok = ok and wait_until(function() return not menu_up() end, 30)
  wait(1)
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
  btn("R4")
  wait_until(function() return mstate() == S.ST_END end, 5)
  continue_next(NO)
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
  elseif MODE == "buttons" then buttons() end
  finish()
  while true do coroutine.yield() end
end)
MT_TICK = emu.add_machine_frame_notifier(function()
  if coroutine.status(co) ~= "dead" then
    local ok, err = coroutine.resume(co)
    if not ok then log("ERROR " .. tostring(err)); report(); M:exit() end
  end
end)

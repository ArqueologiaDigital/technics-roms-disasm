-- led_boot_tap.lua: log every write to the KN5000 main CPU's control-panel LED images during boot.
--   0x8F18..0x8F27  CPANEL_LED_IMAGE      (rows 0..14 wanted; written by the LED handler lists)
--   0x8F28..0x8F37  CPANEL_LED_IMAGE_SENT (rows already sent; written by CPanel_LED_FlushImage
--                                          right after it queues the row's frame with Set_LEDs)
-- and every byte pushed into the LED event queue (CPANEL_LED_EVENT_QUEUE, 0x20137, 128-byte ring;
-- write pointer word at 0x20133) is not tapped: the SENT image is the record of what went out.
-- Output: lines "LED t=<seconds> sent row=<n> old=<hex> new=<hex>" on stdout (emu.print_info).
local mach = manager.machine
local sp = mach.devices[":maincpu"].spaces["program"]
local function now() return mach.time.seconds + mach.time.attoseconds / 1e18 end
local last = {}
_G._tap_sent = sp:install_write_tap(0x8F28, 0x8F37, "ledsent", function(offset, data, mask)
  -- 16-bit bus: data/mask cover the even/odd byte pair
  for b = 0, 1 do
    local m = (mask >> (8 * b)) & 0xFF
    if m ~= 0 then
      local addr = (offset & ~1) + b
      local v = (data >> (8 * b)) & 0xFF
      local row = addr - 0x8F28
      if row >= 0 and row < 16 and last[row] ~= v then
        emu.print_info(string.format("LED t=%.4f sent row=%d old=%s new=0x%02X pc=%06X",
          now(), row, last[row] and string.format("0x%02X", last[row]) or "--", v,
          mach.devices[":maincpu"].state["PC"].value))
        last[row] = v
      end
    end
  end
  return data
end)
local stop = tonumber(os.getenv("LEDTAP_SECONDS") or "30")
_G._tap_frame = emu.register_frame_done(function()
  if now() > stop then
    local s = ""
    for r = 0, 15 do s = s .. string.format("%02X ", sp:read_u8(0x8F18 + r)) end
    emu.print_info("LED final image rows 0..15: " .. s)
    mach:exit()
  end
end)

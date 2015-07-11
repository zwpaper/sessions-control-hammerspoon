--Sessions control--
--[[
A script for hammerspoon(Mac)

Description:
Use a set of hotkeys to control some sessions which is a set of windows.
You can easily minimize all windows of a session, and unminimize the another one.
We will also save the full screen status, will set window full screen if it was.

Author: PapEr (zw.paper@gmail.com)
--]]


require('sessions_head')

-- init
sessionsRead()

key_fn = {'cmd','alt','ctrl'}
key_session_show = 'P'
key_session_pre = '['
key_session_next = ']'
key_win_add_to_curr = 'L'
key_win_del_from_curr = ';'

-- Show sessions list
hs.hotkey.bind(key_fn, key_session_show, sessionsShow)

-- Switch to previous session
hs.hotkey.bind(key_fn, key_session_pre, function()
	local i = current - 1
	if current == 1 then i = #sessions end
	sessionSwitch(i)
end)

-- Switch to next session
hs.hotkey.bind(key_fn, key_session_next, function()
	local i = current + 1
	if current == #sessions then i = 1 end
	sessionSwitch(i)
end)


--Add current window into session
hs.hotkey.bind(key_fn, key_win_add_to_curr, delWinFromCurrent)


hs.hotkey.bind(key_fn, key_win_del_from_curr, addWinToCurrent)

for i = 1, #sessions do
	hs.hotkey.bind(key_fn, tostring(i), function() sessionSwitch(i) end)
end

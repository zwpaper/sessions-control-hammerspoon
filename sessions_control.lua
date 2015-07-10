--Sessions control--
--[[
A script for hammerspoon(Mac)

Description:
Use a set of hotkeys to control some sessions which is a set of windows.
You can easily minimize all windows of a session, and unminimize the another one.
We will also save the full screen status, will set window full screen if it was.

Author: PapEr (zw.paper@gmail.com)
--]]

--[[
ToDo:
* Detect if there is a save file, if not create a default
* Add a new session
* delete a session
* jump to a session easily
* show windows in current session

MayBe:
* Change session to a table like
	{{win, isFull}, {...}, name=name_of_session}
	and use ipairs to find window
--]]



require('sessions_head')

-- init
sessionsRead()


--Show sessions list
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'I', sessionsShow)


--Add current window into session
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'O', function()
	local win = hs.window.focusedWindow()
	if win:id() then
		if findInList(sessions[current][index_windows], win) then
			hs.notify.new({title='Add window to session', informativeText='Already added'}):send():release()
			return
		end
		local status = {}
		table.insert(status, win)
		table.insert(status, win:isFullScreen())
		table.insert(sessions[current][index_windows], status)
		hs.notify.new({title='Add window to session',
					  informativeText=win:title() .. ' added' .. ' (All: '.. #sessions[current][index_windows] .. ')'})
					 :send():release()
	else
		hs.notify.new({title='Add window to session', informativeText='No focused window'}):send():release()
	end

end)


hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'P', function()
	local win = hs.window.focusedWindow()
	if win:id() then
		local key = findInList(sessions[current][index_windows], win)
		if key then
			table.remove(sessions[current][index_windows], key)
			hs.notify.new({title='Del window from session',
						  informativeText=win:title() .. ' Deleted' .. ' (All: '.. #sessions[current][index_windows] .. ')'})
						 :send():release()
		else
			hs.notify.new({title='Del window from session', informativeText='Not in this session'}):send():release()
		end
	else
		hs.notify.new({title='Add window to session', informativeText='No focused window'}):send():release()
	end

end)


function sessionSwitchPrv()
	local i = current - 1
	if current == 1 then i = #sessions end
	sessionSwitch(i)
end
hs.hotkey.bind({'cmd','alt','ctrl'}, '[', sessionSwitchPrv)


function sessionSwitchNext()
	local i = current + 1
	if current == #sessions then i = 1 end
	sessionSwitch(i)
end
hs.hotkey.bind({'cmd','alt','ctrl'}, ']', sessionSwitchNext)

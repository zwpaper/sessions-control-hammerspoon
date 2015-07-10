--Sessions control function file--
--[[
Author: PapEr (zw.paper@gmail.com)
--]]

--[[
--example of sessions
sessions = {
	{'scraper', {}},
	{'hammerspoon', {}},
	{'github', {}},
	{'wear', {}},
	{'work', {}}
}
-- each window is saved as {win, isFullScreen}
--]]

--[[
const
--]]
--index for each sessions
index_session = 1
index_windows = 2

--index for each windows
index_win = 1
index_isFull = 2

--[[
Variable
--]]
current = 1
local path_session_save = hs.configdir .. '/sessions.sav'


--[[
Functions
--]]
-- session handling
function sessionsShow()
	if #sessions ~= 0 then
		local msg = ''
		for k, v in pairs(sessions) do
			if current == k then msg = msg .. '->' end
			msg = msg .. v[index_session] .. '\t'
		end
		hs.notify.new({title='Sessions List:', informativeText=msg}):send():release()
	else
		hs.notify.new({title='Sessions List:', informativeText='No session'}):send():release()
	end
end


function sessionSwitch(new)
	hs.window.animationDuration = 0
	for k, v in pairs(sessions[current][index_windows]) do
		if v[index_win]:isVisible() then
			sessions[current][index_windows][k][index_isFull] = v[index_win]:isFullScreen()
			if v[index_win]:isFullScreen() then
				v[index_win]:setFullScreen(false)
				hs.timer.doAfter(2, function() v[index_win]:minimize() end);
			else
				v[index_win]:minimize()
			end
		elseif not hs.window.windowForID(v[index_win]:id()) then
			table.remove(sessions[current], k)
		end
	end

	for k, v in pairs(sessions[new][index_windows]) do
		if v[index_win]:isMinimized() then v[index_win]:unminimize() end
		if v[index_isFull] then hs.timer.doAfter(1, function() v[index_win]:setFullScreen(true) end) end
	end
	current = new
	hs.notify.new({title='Change session',
				  informativeText=current.. ': ' .. sessions[new][index_session] .. ' actived'})
				 :send():release()
	sessionsSave(sessions)
end


function sessionsRead()
	local sessions_file = assert(io.open(path_session_save, "r"))
	sessions = {}
	local close_win_counter = 0
	for line in sessions_file:lines() do
		if line:sub(1, 1) == '{' then
			if #line < 2 then
				hs.notify.new({title='Read Error', informativeText='No session name after "{"'}):send():release()
				error('No session name after "{"')
			else
				table.insert(sessions, {line:sub(2, -1), {}})
			end
		elseif line:sub(1, 1) == '}' then
			if #line ~= 1 then
				hs.notify.new({title='Read Error', informativeText='Session not end with "}"'}):send():release()
				error('Session not end with "}"')
			end
			if close_win_counter ~= 0 then
				hs.notify.new({title='Read Sessions',
							  informativeText=close_win_counter .. ' in ' .. sessions[#sessions][index_session] .. ' closed'})
				 			 :send():release()
				close_win_counter = 0
			end
		elseif line:sub(1, 1) == '>' then
			current = tonumber(line:match('%d+', 2))
		else
			local id = line:match('%d+')
			local isFull = line:match('%d', -1)
			if not (id and isFull) then
				hs.notify.new({title='Read Error', informativeText='Data in sav file is wrong'}):send():release()
				error('Read windows error!')
			end

			local window = hs.window.windowForID(tonumber(id))
			if not window then
				close_win_counter = close_win_counter + 1
			else
				if isFull == '1' then
					isFull = true
				elseif isFull == '0' then
					isFull = false
				else
					hs.notify.new({title='Read Error', informativeText=isFull .. ' is not a valid value, unset fullscreen'})
								 :send():release()
					isFull = false
					-- error('Read is_window_full_screen error!')
				end
				table.insert(sessions[#sessions][index_windows], {window, isFull})
			end

		end
	end

	if current > #sessions or current < 1 then
		hs.notify.new({title='Read Error', informativeText=current .. ' is not a valid session number'}):send():release()
		error('session number error!')
	end
	sessionsShow()
end


function sessionsSave(se)
-- use a '{session ' start a scope,
-- each line as a win
-- end a scope using '}'
	local session_to_save = ''
	for k, v in pairs(se) do
		local one_session = '{' .. v[index_session] .. '\n'
		for key, val in pairs(v[index_windows]) do
			one_session = one_session .. val[index_win]:id() .. ':' .. (val[index_isFull] and '1' or '0') .. '\n'
		end
		one_session = one_session .. '}' .. '\n'
		session_to_save = session_to_save .. one_session
	end

	session_to_save = session_to_save .. '>' .. current .. '\n'

	local sessions_file = assert(io.open(path_session_save, "w"))
	sessions_file:write(session_to_save)
	sessions_file:flush()
	sessions_file:close()
end


-- utils
function findInList(list, item)
	if list then
		for k, v in pairs(list) do
			if item:id() == v[1]:id() then return k end
		end
	end
	return nil
end

local addonName = "CLOVERFINDER";
local addonNameLower = string.lower(addonName);
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['FAMFANFAN'] = _G['ADDONS']['FAMFANFAN'] or {};
_G['ADDONS']['FAMFANFAN'][addonName] = _G['ADDONS']['FAMFANFAN'][addonName] or {};
local g = _G['ADDONS']['FAMFANFAN'][addonName];
local acutil = require('acutil');
g.settingsFileLoc = "../addons/"..addonNameLower.."/settings.json";
g.recordsFileLoc = "../addons/"..addonNameLower.."/records.json";
if not g.loaded then
	g.check = {};
	g.boss = {};
	g.records = {};
	g.settings = {
		version = "2.0.3c",
		language = "japanese",
		enable = true,
		soundAlert = true,
		showLocation = true,
		buff = {
			["148"] = false,
			["271"] = false,
			["2022"] = false,
			["5028"] = true,
			["5079"] = true,
			["5086"] = true,
			["5087"] = true,
			["5105"] = true,
			["BOSS"] = true
		},
		ChatBoss = {
			["party"] = true,
			["guild"] = false
		},
		ChatClover = {
			["party"] = true,
			["guild"] = false
		}
	};
	g.text = {
		["japanese"] = "を発見！",
		["english"] = "spotted!!"
	}
	g.clover = {
		{
			["id"] = 5028,
			["icon"]="icon_item_jewelrybox",
			["bg"]="gacha_01",
			["color"]={
				["japanese"]="金色",
				["english"]="Gold"
			},
			checkFn=function(buff) return buff.arg2 == 1 end
		},
		{
			["id"] = 5028,
			["icon"]="icon_item_jewelrybox",
			["bg"]="gacha_02",
			["color"]={
				["japanese"]="銀色",
				["english"]="Silver"
			},
			checkFn=nil
		},
		{
			["id"] = 5079,
			["icon"]="icon_expup_total",
			["bg"]="gacha_01",
			["color"]={
				["japanese"]="青色",
				["english"]="Blue"
			},
			checkFn=nil
		},
		{
			["id"] = 5086,
			["icon"]="icon_state_medium",
			["bg"]="gacha_03",
			["color"]={
				["japanese"]="赤色",
				["english"]="Red"
			},
			checkFn=nil
		},
		{
			["id"] = 5087,
			["icon"]="icon_fieldboss",
			["bg"]="gacha_03",
			["color"]={
				["japanese"]="エリート",
				["english"]="Elite"
			},
			checkFn=nil
		},
		{
			["id"] = 5105,
			["icon"]="icon_state_stop",
			["bg"]="gacha_03",
			["color"]={
				["japanese"]="エリート",
				["english"]="Challenge"
			},
			checkFn=nil
		}
	};
end

function CLOVER_S2B(s)
	if s == "on" then
		return true;
	end
	return false;
end

function CLOVER_B2S(b)
	if b then
		return "enable";
	end
	return "disable";
end

function CLOVERFINDER_BOSS_COMMAND(command)
	local cmd = "";
	local msg = "";
	if #command > 0 then
		cmd = string.lower(table.remove(command, 1));
	else
		msg = "/boss [BOSS NAME]";
		return ui.MsgBox(msg,"","Nope");
	end
	local fmDate = nil;
	local AMPM = "";
	local iCount = 0;
	for handle, value in pairs(g.records) do
		if string.find(string.lower(value.name), cmd) then
			msg = msg.."ID: "..handle.."{nl}";
			msg = msg.."Name: "..value.name.."{nl}";
			msg = msg.."Level: "..value.level.."{nl}";
			msg = msg.."Spot: "..value.location.."{nl}";
			fmDate = os.date("*t", value.spotTime);
			if fmDate.hour > 12 then
				fmDate.hour = fmDate.hour - 12;
				AMPM = "PM";
			else
				AMPM = "AM";
			end
			msg = msg.."Time: "..fmDate.day.."/"..fmDate.month.."/"..fmDate.year.." "..fmDate.hour..":"..fmDate.min..":"..fmDate.sec.." "..AMPM.."{nl}{nl}";
			iCount = iCount +1;
		end
	end
	if iCount > 0 then
		ui.MsgBox(msg,"","Nope");
	else
		CHAT_SYSTEM("[CLOVERFINDER] cannot found boss: "..cmd);
	end
	return;
end

function CLOVERFINDER_MAIN_COMMAND(command)
	local cmd = "";
	if #command > 0 then
		cmd = string.lower(table.remove(command, 1));
	else
		local msg = "/clover on/off{nl}";
		msg = msg.. "Clover Finder enable/disable{nl}";
		msg = msg.. "/clover bossparty on/off{nl}"
		msg = msg.. "/clover party on/off{nl}"
		msg = msg.. "/clover bossguild on/off{nl}"
		msg = msg.. "/clover guild on/off{nl}"
		msg = msg.. "inform for to party or guild{nl}"
		msg = msg.. "/clover loc on/off{nl}"
		msg = msg.. "inform to target location{nl}"
		msg = msg.. "/clover sound on/off{nl}"
		msg = msg.. "turn on/off Alert sound{nl}"
		msg = msg.. "/clover [Mob Color] on/off{nl}"
		msg = msg.. "turn on/off monster color alert{nl}"
		msg = msg.. "Gold, Silver, Blue, Red, Elite, Purple, Boss{nl}"
		msg = msg.. "/clover color on/off{nl}"
		msg = msg.. "turn on/off all color setting{nl}"
		msg = msg.. "/clover lang japanese{nl}"
		msg = msg.. "japanese{nl}"
		msg = msg.. "/clover lang english{nl}"
		msg = msg.. "english"
		return ui.MsgBox(msg,"","Nope");
	end

	if cmd == "on" or cmd == "off" then
		local arg = CLOVER_S2B(cmd);
		g.settings.enable = arg;
		CHAT_SYSTEM("[CLOVERFINDER] status: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "sound") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.soundAlert = arg;
		CHAT_SYSTEM("[CLOVERFINDER] sound Alert: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "location" or cmd == "loc") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.showLocation = arg;
		CHAT_SYSTEM("[CLOVERFINDER] show location: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "gold" or cmd == "silver") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff["5028"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert gold and silver monster: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "blue") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff["5079"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert blue monster: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "red") and #command > 0 then --5086
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff["5086"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert red monster: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "elite") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff["5087"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert elite monster: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "purple" or cmd == "challenge") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff["5105"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert challenge monster: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "boss") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff["BOSS"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert boss monster: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "party") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.ChatClover["party"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert clover in party: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "guild") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.ChatClover["guild"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert clover in guild: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "bossparty") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.ChatBoss["party"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert boss in party: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "bossguild") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.ChatBoss["guild"] = arg;
		CHAT_SYSTEM("[CLOVERFINDER] Alert boss in guild: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "color") and #command > 0 then
		local arg = CLOVER_S2B(string.lower(table.remove(command, 1)));
		g.settings.buff = {
			["5028"] = arg,
			["5079"] = arg,
			["5086"] = arg,
			["5087"] = arg,
			["5105"] = arg,
			["BOSS"] = arg
		}
		CHAT_SYSTEM("[CLOVERFINDER] all monster Alert: "..CLOVER_B2S(arg));
		acutil.saveJSON(g.settingsFileLoc, g.settings);
		return;
	elseif (cmd == "language" or cmd == "lang") and #command > 0 then
		local arg = string.lower(table.remove(command, 1));
		if arg == "jp" or arg == "ja" then
			arg = "japanese";
		elseif arg == "en" or arg == "eng" then
			arg = "english";
		end
		if arg == "japanese" or arg == "english" then
			g.settings.language = arg;
			CHAT_SYSTEM("[CLOVERFINDER] set language: "..arg);
			acutil.saveJSON(g.settingsFileLoc, g.settings);
			return;
		end
	end
	CHAT_SYSTEM("[CLOVERFINDER] Invalid Command");
end

function CLOVER_TIME()
	local serverTime = geTime.GetServerSystemTime();
	local gameTime = os.time({
		year = serverTime.wYear,
		month = serverTime.wMonth,
		day = serverTime.wDay,
		hour = serverTime.wHour,
		min = serverTime.wMinute,
		sec = serverTime.wSecond
	});
	return gameTime;
end

function CLOVER_FREMOVE(frameName)
	local objFrame = ui.GetFrame(frameName);
	if (objFrame ~= nil) then
		objFrame = nil;
		ui.DestroyFrame(frameName);
	end
end

function CLOVER_BUFF(id, handle, checkFn)
	local buffCount = info.GetBuffCount(handle);
	for i = 0, buffCount - 1 do
		local buff = info.GetBuffIndexed(handle, i);
		if buff.buffID == id then
			if not g.settings.buff[tostring(id)] then
				return false;
			elseif checkFn ~= nil then
				return checkFn(buff);
			end
			return true;
		end
	end
	return false;
end

function CLOVER_CHECK(handle,actor,iesObj)
	if (string.find(iesObj.ClassName, "F_boss") or string.find(iesObj.ClassName, "FD_boss")) and g.settings.buff["BOSS"] then
		if g.boss[tostring(handle)] == nil or os.clock() - g.boss[tostring(handle)] > 3600 then
			local lang = g.settings.language or "japanese";
			local text = g.text[lang] or "を発見！";
			local level = info.GetLevel(handle);
			local actorPos = actor:GetPos();
			local mapName = session.GetMapName();
			local mapCls = GetClass("Map", mapName);
			local place = MAKE_LINK_MAP_TEXT(mapName, actorPos.x, actorPos.z);
			text = iesObj.Name.." [Lv."..level.."] "..place.." "..text;
			if g.settings.ChatBoss["party"] then
				ui.Chat("/p "..text);
			end
			if g.settings.ChatBoss["guild"] then
				ui.Chat("/g "..text);
			end
			if g.settings.soundAlert then
				imcSound.PlaySoundEvent("sys_levelup");
			end
			g.records[tostring(iesObj.ClassID)] = {
				name = iesObj.Name,
				level = level,
				location = mapCls.Name,
				spotTime = CLOVER_TIME()
			};
			g.boss[tostring(handle)] = os.time();
			acutil.saveJSON(g.recordsFileLoc , g.records);
		end
	else
		for _, buff in ipairs(g.clover) do
			if CLOVER_BUFF(buff.id, handle, buff.checkFn) == true then
				local lang = g.settings.language or "japanese";
				local colorName = buff.color[lang] or "よくわからんけどすごそうな感じ";
				local text = g.text[lang] or "を発見！";
				if g.settings.showLocation then
					local actorPos = actor:GetPos();
					local place = MAKE_LINK_MAP_TEXT(session.GetMapName(), actorPos.x, actorPos.z);
					text = colorName.." "..iesObj.Name.." "..place.." "..text;
				else
					text = colorName.." "..iesObj.Name.." "..text;
				end
				if g.settings.ChatClover["party"] then
					ui.Chat("/p "..text);
				end
				if g.settings.ChatClover["guild"] then
					ui.Chat("/g "..text);
				end
				if g.settings.soundAlert then
					imcSound.PlaySoundEvent("sys_levelup");
				end
				local popup = ui.CreateNewFrame("hair_gacha_popup", "test"..handle, 0);
				popup:ShowWindow(1);
				popup:EnableHitTest(0);
				local bonusimg = GET_CHILD_RECURSIVELY(popup, "bonusimg");
				bonusimg:ShowWindow(0);
				local itembgimg = GET_CHILD_RECURSIVELY(popup, "itembgimg");
				local itemimg = GET_CHILD_RECURSIVELY(popup, "itemimg");
				itemimg:SetImage(buff.icon);
				itembgimg:SetImage(buff.bg);
				itemimg:SetColorTone("CCFFFFFF");
				itembgimg:SetColorTone("CCFFFFFF");
				FRAME_AUTO_POS_TO_OBJ(popup, handle, - popup:GetWidth() / 2, -100, 3, 1);
				break;
			end
		end
	end
end

function CLOVER_UPDATE(frame, msg, str, handle)
	if not g.settings.enable then
		return;
	end
	local spottemp = {};
	for _, value in pairs(g.check) do
		value.alive = false;
	end
	local list, count = SelectBaseObject(GetMyPCObject(), 700, "ENEMY");
	for i = 1 , count do
		local obj = list[i];
		local actor = tolua.cast(obj, "CFSMActor");
		local handle = actor:GetHandleVal();
		if g.check[tostring(handle)] == nil then
			g.check[tostring(handle)] = {
				alive = true,
				checked = false
			};
		else
			g.check[tostring(handle)].alive = true;
		end
		local iesObj = GetBaseObjectIES(obj);
		if not g.check[tostring(handle)].checked then
			CLOVER_CHECK(handle,actor,iesObj);
			g.check[tostring(handle)].checked = true;
		end
	end
	for handle, value in pairs(g.check) do
		if not value.alive then
			table.insert(spottemp, handle)
		end
	end
	for _, handle in ipairs(spottemp) do
		g.check[tostring(handle)] = nil;
		CLOVER_FREMOVE("test"..handle);
	end
end

function CLOVERFINDER_ON_INIT(addon, frame)
	acutil.slashCommand("/clover", CLOVERFINDER_MAIN_COMMAND);
	acutil.slashCommand("/boss", CLOVERFINDER_BOSS_COMMAND);
	if not g.loaded then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		if err then
		else
			g.settings = t;
		end
		local t, err = acutil.loadJSON(g.recordsFileLoc, g.records);
		if err then
		else
			g.records = t;
		end
		g.loaded = true;
	end
	acutil.saveJSON(g.settingsFileLoc, g.settings);
	acutil.saveJSON(g.recordsFileLoc, g.records);
	addon:RegisterMsg('FPS_UPDATE', 'CLOVER_UPDATE');
end
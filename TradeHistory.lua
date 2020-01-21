TL_PLAYER_CODE = "|cff00ccff";
TL_GOLD_CODE = "|cffffff00";
TL_SILVER_CODE = "|cffc0c0c0";
TL_COPPER_CODE = "|cff993300";

local frame = CreateFrame("FRAME", "EventTestFrame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("TRADE_ACCEPT_UPDATE");

local function eventHandler(self, event, ...)
	if ( event == "TRADE_ACCEPT_UPDATE" ) then
		local arg1, arg2 = ...;
		TradeLog_SetAcceptState(arg1, arg2);
	end
end
frame:SetScript("OnEvent", eventHandler);

function TradeLog_SetAcceptState(playerState, targetState)
	local g, s, c, string, arg1, arg2; local mod = ","; local last = 0; local j = 0;
	if ( playerState == 1 ) and ( targetState == 1 ) then
		-- Adds a row to the array
		--TRADE_LOG[TL_PLAYER][0] = TRADE_LOG[TL_PLAYER][0] + 1;

		-- Kicks off the string with "[MM/DD/YY HH:MM] [You] trade..."
		string = TradeLog_AddTime()..TL_PLAYER_CODE.."[You]"..FONT_COLOR_CODE_CLOSE.." trade";

		-- Finds the last slot and number filled for your Items
		for i = 1, 7 do
			-- 1-6 Your items
			local name, texture, numItems, isUsable, enchantment = GetTradePlayerItemInfo(i);
			if ( name ) and not ( i == 7 )  then
				j = j + 1;		-- Number of items you trade
				last = i;		-- Last item you trade
			end
			-- 7 is the enchant slot, we need to grab your Target's slot
			name, texture, numItems, quality, isUsable, enchantment = GetTradeTargetItemInfo(i);
			if ( enchantment ) and ( i == 7 ) then
				j = j + 1;
				last = i;
			end
		end

		-- Loops through adding the name of items in the chat window "[MM/DD/YY HH:MM] [You] trade, 20x [Runecloth], [Golden Pearl]..."
		if ( j == 0 ) and ( GetPlayerTradeMoney() == 0 ) then
			string = string.." nothing";
		else
			for i = 1, 7 do
				arg1 = GetTradePlayerItemLink(i);
				name, texture, numItems, isUsable, enchantment = GetTradePlayerItemInfo(i);
				if ( i == last ) and ( j > 1 ) and ( GetPlayerTradeMoney() == 0 ) then
					mod = " and";
				end
				if ( arg1 ) and not ( i == 7 ) and not ( numItems == 1 ) then
					string = string..mod.." "..numItems.."x "..arg1;
				elseif ( arg1 ) and not ( i == 7 ) and ( numItems == 1 ) then
					string = string..mod.." "..arg1;
				end
				name, texture, numItems, quality, isUsable, enchantment = GetTradeTargetItemInfo(i);
				if ( enchantment ) and (i == 7) then
					string = string..mod.." "..enchantment;
				end
			end
		end

		-- If you are trading money "[MM/DD/YY HH:MM] [You] trade, 20x [Runecloth], [Golden Pearl] and 10g 25s 5c..."
		if not ( GetPlayerTradeMoney() == 0 ) then
			g = floor(GetPlayerTradeMoney()/10000);
			s = floor((GetPlayerTradeMoney() - g * 10000)/100);
			c = GetPlayerTradeMoney() - g * 10000 - s * 100;
			if ( j > 0 ) then
				mod = " and";
			end
			string = string..mod.." "..TL_GOLD_CODE..g.."g "..FONT_COLOR_CODE_CLOSE..TL_SILVER_CODE..s.."s "..FONT_COLOR_CODE_CLOSE..TL_COPPER_CODE..c.."c"..FONT_COLOR_CODE_CLOSE;
		end

		-- Target's name "[MM/DD/YY HH:MM] [You] trade, 20x [Runecloth], [Golden Pearl] and 10g 25s 5c while [TargetName] trades.."
		string = string.." while "..RED_FONT_COLOR_CODE.."["..UnitName("NPC").."]"..FONT_COLOR_CODE_CLOSE.." trades";

		-- Resets a few of the variables used above
		j = 0; mod = ",";
		
		-- Finds the last slot and number filled for Target's Items
		for i = 1, 7 do
			-- 1-6 Your Target's items
			name, texture, numItems, quality, isUsable, enchantment = GetTradeTargetItemInfo(i);
			if ( name ) and not ( i == 7 )  then
				j = j + 1;		-- Number of items you trade
				last = i;		-- Last item you trade
			end
			-- 7 is the enchant slot, we need to grab your slot
			name, texture, numItems, isUsable, enchantment = GetTradePlayerItemInfo(i);
			if ( enchantment ) and ( i == 7 ) then
				j = j + 1;
				last = i;
			end
		end

		-- Target's traded items "[MM/DD/YY HH:MM] [You] trade, 20x [Runecloth], [Golden Pearl] and 10g 25s 5c for [TargetName's], [Pristine Black Diamond] and [Swiftness Potion]."
		if ( j == 0 ) and ( GetTargetTradeMoney() == 0 ) then
			string = string.." nothing";
		else
			for i = 1, 7 do
				arg1 = GetTradeTargetItemLink(i);
				name, texture, numItems, quality, isUsable, enchantment = GetTradeTargetItemInfo(i);
				if ( i == last ) and ( j > 1 ) and ( GetTargetTradeMoney() == 0 ) then
					mod = " and";
				end
				if ( arg1 ) and not ( i == 7 ) and not ( numItems == 1 ) then
					string = string..mod.." "..numItems.."x "..arg1;
				elseif ( arg1 ) and not ( i == 7 ) and ( numItems == 1 ) then
					string = string..mod.." a "..arg1;
				end
				name, texture, numItems, isUsable, enchantment = GetTradePlayerItemInfo(i);
				if ( enchantment ) and (i == 7) then
					string = string..mod.." "..enchantment;
				end
			end
		end

		-- Same as first money trade check, but for target's money
		if not ( GetTargetTradeMoney() == 0 ) then
			g = floor(GetTargetTradeMoney()/10000);
			s = floor((GetTargetTradeMoney() - g * 10000)/100);
			c = GetTargetTradeMoney() - g * 10000 - s * 100;
			if ( j > 0 ) then
				mod = " and";
			end
			string = string..mod.." "..TL_GOLD_CODE..g.."g "..FONT_COLOR_CODE_CLOSE..TL_SILVER_CODE..s.."s "..FONT_COLOR_CODE_CLOSE..TL_COPPER_CODE..c.."c"..FONT_COLOR_CODE_CLOSE;
		end

		string = string..".";

		if ( TL_DISPLAY == 4 ) then
			TradeLogText:AddMessage(string);
		end
		print(string);

		--TRADE_LOG[TL_PLAYER][TRADE_LOG[TL_PLAYER][0]] = string;
	end
end
function TradeLog_AddTime()
	-- !!!IMPORTANT!!! THIS IS THE LOCAL DATE, NOT SERVER DATE!!! --
	local h,m = GetGameTime();
	local timestamp = format("%02d:%02d",h,m);
	return NORMAL_FONT_COLOR_CODE.."["..date("%m/%d/%y").." "..timestamp.."] "..FONT_COLOR_CODE_CLOSE;
end
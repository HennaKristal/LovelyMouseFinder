import "Turbine";
import "Turbine.UI.Lotro";

-- Missing/outdated enumeration values
Turbine.UI.Lotro.Action.EnterKey = 162;
Turbine.UI.Lotro.Action.ToggleHUD = Turbine.UI.Lotro.Action.UI_Toggle;
Turbine.UI.Lotro.Action.RotateCharacter = 19;
Turbine.Gameplay.EffectCategory.Tactical = 256;
Turbine.Gameplay.Attributes.MinstrelStance.Harmony = nil;
Turbine.Gameplay.Attributes.MinstrelStance.Warspeech = nil;
Turbine.Gameplay.Attributes.MinstrelStance.Melody = 0;
Turbine.Gameplay.Attributes.MinstrelStance.Dissonance = 1;
Turbine.Gameplay.Attributes.MinstrelStance.Resonance = 2;
Turbine.Gameplay.Attributes.MinstrelStance.None = 3;
Turbine.ChatType.EventBroadcast = 33;
Turbine.Language.Russian = 268435463; -- removed in Update 22 and again in Update 34
Turbine.Language.Portuguese = Turbine.Language.Russian + 1;

-- Adding missing values to the Turbine.UI.Lotro.Action enumeration:
for key, value in pairs({
   RightMouseButton = 19,
   ToggleDebugHUD = 42,
   ToggleDebugConsole = 43,
   BackspaceKey = 99,
   EnterKey = 162,
   CursorPreviousLine = 29,
   CursorCharRight = 108,
   CursorCharLeft = 127,
   CursorNextLine = 113,
   CursorPreviousPage = 146,
   CursorNextPage = 49,
   CursorStartOfLine = 58,
   CursorEndOfLine = 57,
   CursorWordLeft = 163,
   CursorWordRight = 37,
   DeleteKey = 75,
   CutText = 8,
   CopyText = 170,
   PasteText = 100,
}) do
   if (Turbine.UI.Lotro.Action[key] == nil) then
      Turbine.UI.Lotro.Action[key] = value;
   end
end

-- Add the Turbine.UI.Display.SizeChanged event.
displaySizeListener = Turbine.UI.Window();
displaySizeListener:SetVisible(true);
displaySizeListener:SetStretchMode(0);
displaySizeListener:SetSize(1, 1);
displaySizeListener:SetWantsUpdates(true);
displaySizeListener:SetStretchMode(1);
displaySizeListener:SetWantsUpdates(true);
function displaySizeListener:Update()
    displaySizeListener:SetSize(2, 2);
    self.ignoreSizeChangedEvents = 0;
    self:SetWantsUpdates(false);
    self.Update = self._Update;
    self.SizeChanged = self._SizeChanged;
end
function displaySizeListener:_Update()
    self:SetWantsUpdates(false);
    DoCallbacks(Turbine.UI.Display, "SizeChanged");
end
function displaySizeListener:_SizeChanged()
    if (self.ignoreSizeChangedEvents > 0) then
        self.ignoreSizeChangedEvents = self.ignoreSizeChangedEvents - 1;
        return;
    end
    self:SetSize(2, 2);
    self.ignoreSizeChangedEvents = 1;
    -- Need to wait until the next Update() cycle before reporting.
    self:SetWantsUpdates(true);
end

-- digits = number of fractional digits wanted (default is 0)
function _G.round(x, digits)
    digits = 10 ^ (digits or 0);
    return math.floor(x * digits + 0.5) / digits;
end

-- Copies the source table into the destination table (or a new table, if 'destTable' is absent).
-- Subtables are duplicated.
-- Returns the destination table.
function _G.DeepTableCopy(sourceTable, destTable)
    if (destTable == nil) then
        destTable = {};
    end
    if (type(sourceTable) ~= "table") then
        error("DeepTableCopy(): sourceTable is " .. type(sourceTable), 2);
    elseif (type(destTable) ~= "table") then
        error("DeepTableCopy(): destTable is " .. type(destTable), 2);
    end
    for k, v in pairs(sourceTable) do
        if (type(v) == "table") then
            destTable[k] = { };
            DeepTableCopy(v, destTable[k]);
        else
            destTable[k] = v;
        end
    end
    return destTable;
end

-- Copies the source table into the destination table (or a new table, if 'destTable' is absent).
-- Subtables are shared (not duplicated).
-- Returns the destination table.
function _G.ShallowTableCopy(sourceTable, destTable)
    if (destTable == nil) then
        destTable = {};
    end
    if (type(sourceTable) ~= "table") then
        error("ShallowTableCopy(): sourceTable is " .. type(sourceTable), 2);
    elseif (type(destTable) ~= "table") then
        error("ShallowTableCopy(): destTable is " .. type(destTable), 2);
    end
    for k, v in pairs(sourceTable) do
        destTable[k] = v;
    end
    return destTable;
end

function _G.Puts(str)
    local prefix = "";
    if (_G.PutsPrefix) then
        prefix = _G.PutsPrefix;
    end
    Turbine.Shell.WriteLine(prefix .. tostring(str));
end

-- Returns a compact Lua representation of a table.  Has optional 'maxdepth' arg to prevent runaway recursion.
function _G.Serialize(obj, maxdepth)
    if (type(maxdepth) == "number") then
        maxdepth = maxdepth - 1;
    end
    if (type(obj) == "boolean") then
        if (obj) then
            return "true";
        else
            return "false";
        end
    elseif (type(obj) == "number") then
        local text = tostring(obj);
        -- Change floating-point numbers to English format
        return string.gsub(text, ",", ".");
    elseif (type(obj) == "string") then
        return string.format("%q", obj);
    elseif (type(obj) == "table") then
        if ((type(maxdepth) == "number") and (maxdepth < 0)) then
            return tostring(obj);
        else
            local text = "{";
            local i = 1;
            for key in sorted_keys(obj) do
                local value = Serialize(obj[key], maxdepth);
                if (value ~= nil) then
                    local item = value .. ",";
                    if (key ~= i) then
                        local index = Serialize(key, maxdepth);
                        item = "[" .. index .. "]=" .. item;
                    else
                        i = i + 1;
                    end
                    text = text .. item;
                end
            end
            text = string.gsub(text, ",$", "");
            text = text .. "}";
--text = tostring(obj) .. ":" .. text;
            return text;
        end
    else
--Turbine.Shell.WriteLine("unknown type " .. tostring(type));
        return tostring(obj);
    end
end

-- Returns a multi-line Lua representation of a table.  Has optional 'maxdepth' arg to prevent runaway recursion.
function _G.PrettyPrint(obj, prefix, maxdepth)
    if (type(maxdepth) == "number") then
        maxdepth = maxdepth - 1;
    end
    if (type(obj) == "boolean") then
        if (obj) then
            return "true";
        else
            return "false";
        end
    elseif (type(obj) == "number") then
        local text = tostring(obj);
        -- Change floating-point numbers to English format
        return string.gsub(text, ",", ".");
    elseif (type(obj) == "string") then
        return string.format("%q", obj);
    elseif (type(obj) == "table") then
        if ((type(maxdepth) == "number") and (maxdepth < 0)) then
            return tostring(obj);
        else
            local text = "{\n";
            local newPrefix = prefix .. "   ";
            local i = 1;
            local count = 0;
            for key in sorted_keys(obj) do
                local value = PrettyPrint(obj[key], newPrefix, maxdepth);
                if (value ~= nil) then
                    local item = value .. ";";
                    if (key ~= i) then
                        local index = Serialize(key, maxdepth);
                        item = "[" .. index .. "] = " .. item;
                    else
                        i = i + 1;
                    end
                    text = text .. newPrefix .. item .. "\n";
                    count = count + 1;
                end
            end
            if (count == 0) then
                text = "{}";
            else
                text = string.gsub(text, ",$", "");
                text = text .. prefix .. "}";
            end
--text = tostring(obj) .. ":" .. text;
            return text;
        end
    else
--Turbine.Shell.WriteLine("unknown type " .. tostring(type));
        return tostring(obj);
    end
end

-- Prepares a table for saving.  Workaround for Turbine.PluginData.Save() bug.
function _G.ExportTable(obj)
    if (type(obj) == "number") then
        local text = tostring(obj);
        -- Change floating-point numbers to English format
        return "#" .. string.gsub(text, ",", ".");
    elseif (type(obj) == "string") then
        return "$" .. obj;
    elseif (type(obj) == "table") then
        local newTable = {};
        for i, v in pairs(obj) do
            newTable[ExportTable(i)] = ExportTable(v);
        end
        return newTable;
    else
        return obj;
    end
end

-- Prepares a loaded table for use.  Workaround for Turbine.PluginData.Save() bug.
function _G.ImportTable(obj)
    if (type(obj) == "string") then
        local prefix = string.sub(obj, 1, 1);
        if (prefix == "$") then
            return string.sub(obj, 2);
        elseif (prefix == "#") then
			-- need to run it through interpreter, since tonumber() may only accept ","
			return loadstring("return " .. string.sub(obj, 2))();
        else -- shouldn't happen
            return obj;
        end
    elseif (type(obj) == "table") then
        local newTable = {};
        for i, v in pairs(obj) do
            newTable[ImportTable(i)] = ImportTable(v);
        end
        return newTable;
    else
        return obj;
    end
end

function _G.GetAssetSize(id)
    local temp = Turbine.UI.Control();
    temp:SetBackground(id);
    temp:SetStretchMode(2);
    return temp:GetWidth(), temp:GetHeight();
end

function _G.AddCallback(object, event, callback)
    if (object == nil) then
        error("First argument to AddCallback() is nil", 2);
    else
        if (object[event] == nil) then
            object[event] = callback;
        else
            if (type(object[event]) == "table") then
                table.insert(object[event], callback);
            else
                object[event] = {object[event], callback};
            end
        end
    end
    return callback;
end

-- New versions of RemoveCallback() and DoCallbacks() that tolerate removing an event handler from within an event handler:
-- Note: This function can leave empty elements in the callback table.
function _G.RemoveCallback(object, event, callback)
    if (callback == nil) then
        return;
    end
    local handlers = object[event];
    if (handlers == callback) then
        object[event] = nil;
    elseif (type(handlers) == "table") then
        local f, i;
        repeat
            i, f = next(handlers, i);
            if (f == callback) then
                handlers[i] = nil;
            end
        until (i == nil);
        i, f = next(handlers);
        if (i == nil) then
            -- Table is empty; set to nil
            object[event] = nil;
        elseif (next(handlers, i) == nil) then
            -- Table has only one function; replace the table with the function itself
            object[event] = f;
        end
    end
end

function _G.DoCallbacks(object, event, ...)
    local handlers = object[event];
    if (type(handlers) == "function") then
        handlers(object, ...);
    elseif (type(handlers) == "table") then
        if (next(handlers) == nil) then
            -- If all handlers have been removed, remove the table.
            object[event] = nil;
        else
            local f, i;
            repeat
                i, f = next(handlers, i);
                if (type(f) == "function") then
                    f(object, ...);
                end
            until (i == nil);
        end
    end
end

-- For iterating over the keys of a hash table in a for loop
function _G.keys(tableVar)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'keys' (table expected, got " .. type(tableVar) .. ")", 2);
    end
    local state = { ["tableVar"] = tableVar, ["index"] = nil };
    local function iterator(state)
        state.index = next(state.tableVar, state.index);
        return state.index;
    end
    return iterator, state, nil;
end

-- For iterating over the values of a hash table in a for loop
function _G.values(tableVar)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'values' (table expected, got " .. type(tableVar) .. ")", 2);
    end
    local state = { ["tableVar"] = tableVar, ["index"] = nil };
    local function iterator(state)
        state.index, value = next(state.tableVar, state.index);
        return value;
    end
    return iterator, state, nil;
end

-- For iterating over the keys of a hash table in a for loop, after sorting the keys
function _G.sorted_keys(tableVar)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'keys' (table expected, got " .. type(tableVar) .. ")", 2);
    end
    local state = { ["sortedKeys"] = {}, ["index"] = nil };
    for key in keys(tableVar) do
        table.insert(state.sortedKeys, key);
    end
    local sortFunc = function(a, b)
        if ((type(a) == type(b)) and ((type(a) == "number") or (type(a) == "string"))) then
            return a < b;
        else
            return tostring(a) < tostring(b);
        end
    end
    table.sort(state.sortedKeys, sortFunc);
    local function iterator(state)
        state.index, value = next(state.sortedKeys, state.index);
        return value;
    end
    return iterator, state, nil;
end

-- Searches the given table for the specified value, returning the corresponding key
function _G.Search(tableVar, value)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'Search' (table expected, got " .. type(tableVar) .. ")", 2);
    end
    for i, v in pairs(tableVar) do
        if (v == value) then
            return i;
        end
    end
end

-- Return a table with the keys and values swapped.
-- If values are repeated, then the new table will have fewer elements than the old.
function _G.InvertTable(tableVar)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'InvertTable' (table expected, got " .. type(tableVar) .. ")", 2);
    end
    local newTable = {};
    for i, v in pairs(tableVar) do
        newTable[v] = i;
    end
    return newTable;
end

-- Returns true if an item is equipped.
-- If 'itemSlot' is specified, the search is restricted to a single equipment slot.
-- If 'itemName' is not specified, any item will be accepted.
-- Note: There is currently no way to distinguish between items with the same
--       name..
function _G.IsEquipped(itemName, itemSlot)
    local slot, item = LovelyMouseFinder.Utils.Watcher.GetEquippedItem(itemName, itemSlot);
    return (slot ~= nil);
end

function _G.Unequip(itemSlot, itemSlotName, targetBagSlot)
    local lp = Turbine.Gameplay.LocalPlayer:GetInstance();
    local bags = lp:GetBackpack();
    local equippedItems = lp:GetEquipment();
    local item = equippedItems:GetItem(itemSlot);
    if (item == nil) then
--        Turbine.Shell.WriteLine("You're not wearing a " .. itemSlotName .. ".");
        return false;
    end
    if (targetBagSlot == nil) then
        for index = 1, bags:GetSize() do
            if (bags:GetItem(index) == nil) then
                targetBagSlot = index;
                break;
            end
        end
    end
    if ((targetBagSlot == nil) or (bags:GetItem(targetBagSlot) ~= nil)) then
--        Turbine.Shell.WriteLine("You do not have enough room in your bags to unequip your " .. itemSlotName .. ".");
        return false;
    end
    bags:PerformItemDrop(item, targetBagSlot, false);
--    Turbine.Shell.WriteLine("You unequip your " .. itemSlotName .. " into bag slot " .. tostring(bagSlot) .. ".");
    return true;
end

function _G.CenterWindow(window)
    local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
    local windowWidth, windowHeight = window:GetSize();
    local left = math.floor((displayWidth - windowWidth) / 2);
    local top = math.floor((displayHeight - windowHeight) / 2);
    window:SetPosition(left, top);
end

-- Finds a unique position for a new window, so it doesn't coincide with existing windows.
-- 'existingWindows' is a list whose values are windows; the keys can be anything.
function _G.SetUniquePosition(window, existingWindows)
    if ((type(window) ~= "table") or (not window.Activate)) then
        error("Window required in argument 1", 2);
    end
    if (type(existingWindows) ~= "table") then
        error("Table required in argument 2", 2);
    end
    local left, top = window:GetPosition();
    local xMax = Turbine.UI.Display.GetWidth() - window:GetWidth();
    local yMax = Turbine.UI.Display.GetHeight() - window:GetHeight();
    local unique;
    repeat
        left = (left + 16) % xMax;
        top = (top + 16) % yMax;
        unique = true;
        for _, otherWindow in pairs(existingWindows) do
            local otherLeft, otherTop = otherWindow:GetPosition();
            if ((left == otherLeft) and (top == otherTop)) then
                unique = false;
                break;
            end
        end
    until (unique);
    window:SetPosition(left, top);
end

-- Creates an alert window with a scrollable text box in it.
function _G.Alert(title, contents, okButton, font)
    local window = Turbine.UI.Lotro.Window();
    window:SetVisible(true);
    window:SetSize(400, 300);
    window:SetText(title);
    window:SetResizable(true);

    window.label = Turbine.UI.Label();
    window.label:SetParent(window);
    if (not font) then
        font = Turbine.UI.Lotro.Font.Verdana10;
    end
    window.label:SetFont(font);
    window.label:SetBackground(0x411348A7);
    window.label:SetPosition(14, 47);
    window.label:SetText(contents);
    window.label:SetSelectable(true);
    
    window.scrollBar = Turbine.UI.Lotro.ScrollBar();
    window.scrollBar:SetParent(window);
    window.scrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
    window.scrollBar:SetWidth(10);
    window.scrollBar:SetTop(47);
    window.label:SetVerticalScrollBar(window.scrollBar);

    window.buttons = {};
    if (okButton) then
        local button = Turbine.UI.Lotro.Button();
        window.buttons[okButton] = button;
        button:SetText(okButton);
        button:SetParent(window);
        button:SetSize(100, 20);
        button.leftOffset = -50;
    end
    
    window.SizeChanged = function(w)
        width, height = w:GetSize();
        w.label:SetSize(width - 27, height - 80);
        w.scrollBar:SetHeight(height - 80);
        w.scrollBar:SetLeft(width - 14);
        for name, button in pairs(w.buttons) do
            local center = math.floor(0.5 + width / 2);
            button:SetPosition(center + button.leftOffset, height - 30);
        end
    end
    window:SizeChanged();
    
    if (not _G.alertWindows) then _G.alertWindows = {} end
    window.winIndex = #_G.alertWindows + 1;
    window:SetPosition(window.winIndex * 6, window.winIndex * 27);
    table.insert(_G.alertWindows, window.winIndex, window);

    window.Closing = function(sender)
        table.remove(_G.alertWindows, sender.winIndex);
    end
    
    return window;
end

-- Encodes binary into printable characters (using only ASCII codes 46-110).
-- Starting at 46 skips past the hyphen, which causes word-wrapping in TextBoxes.
function _G.Bin2Text(data)
    data = data .. string.rep(string.char(0), 2); -- pad with null characters, if needed
    local string_byte, string_char = string.byte, string.char; -- local is faster than global
    local minChar = 46;
    local result, j, X1, X2, X3, Y1, Y2, Y3, Y4 = "", 1;
    for i = 1, #data - 2, 3 do
        X1, X2, X3 = string_byte(data, i, i + 2);
        Y1 = bit.brshift(X1, 2) + minChar;
        Y2 = bit.blshift(bit.band(X1, 3), 4) + bit.brshift(X2, 4) + minChar;
        Y3 = bit.blshift(bit.band(X2, 15), 2) + bit.brshift(X3, 6) + minChar;
        Y4 = bit.band(X3, 63) + minChar;
        result = result .. string_char(Y1, Y2, Y3, Y4);
        j = j + 4;
    end
    return result;
end

-- Decodes a string encoded with Bin2Text() back into binary.
function _G.Text2Bin(data)
    local string_byte, string_char = string.byte, string.char; -- local is faster than global
    local minChar = 46;
    local result, j, X1, X2, X3, X4, Y1, Y2, Y3 = "", 1;
    for i = 1, #data - 3, 4 do
        X1, X2, X3, X4 = string_byte(data, i, i + 3);
        X1, X2, X3, X4 = X1 - minChar, X2 - minChar, X3 - minChar, X4 - minChar;
        Y1 = bit.blshift(X1, 2) + bit.brshift(X2, 4);
        Y2 = bit.blshift(bit.band(X2, 15), 4) + bit.brshift(X3, 2);
        Y3 = bit.blshift(bit.band(X3, 3), 6) + X4;
        result = result .. string_char(Y1, Y2, Y3);
        j = j + 3;
    end
    -- Remove up to two trailing null characters.
    return string.gsub(result, "%z$", "", 2);
end

-- Decodes a string encoded with Bin2Text() back into binary.
function _G.Text2Bin_old(data)
    local X = {string.byte(data, 1, -1)};
    local result, j, Y1, Y2, Y3 = "", 1;
    local minChar = 46;
    for i = 1, #X - 3, 4 do
        local X1, X2, X3, X4 = X[i] - minChar, X[i + 1] - minChar, X[i + 2] - minChar, X[i + 3] - minChar;
        Y1 = bit.blshift(X1, 2) + bit.brshift(X2, 4);
        Y2 = bit.blshift(bit.band(X2, 15), 4) + bit.brshift(X3, 2);
        Y3 = bit.blshift(bit.band(X3, 3), 6) + X4;
        result = result .. string.char(Y1, Y2, Y3);
        j = j + 3;
    end
    -- Remove up to two trailing null characters.
    return string.gsub(result, "%z$", "", 2);
end

-- Enable ENTER and ESC key event handlers for a window, which are only in
-- effect when the window is active.
function _G.EnableEnterEscHandling(window)
    window:SetWantsKeyEvents(true);
    AddCallback(window, "Activated", function(w)
        w:SetWantsKeyEvents(true);
    end);
    -- It is necessary to delay the SetWantsKeyEvents(false) until the next
    -- update cycle after the "Deactivated" event is received, because the
    -- order in which the Escape keypress and the Deactivate event are
    -- received varies.
    window._delayedDeactivate = function(w)
        w:SetWantsKeyEvents(false);
        RemoveCallback(w, "Update", w._delayedDeactivate);
        w:SetWantsUpdates(w._wantedUpdates);
    end
    AddCallback(window, "Deactivated", function(w)
        w._wantedUpdates = w:GetWantsUpdates();
        AddCallback(w, "Update", w._delayedDeactivate);
        w:SetWantsUpdates(true);
    end);
    AddCallback(window, "KeyDown", function(w, args)
        if (args.Action == Turbine.UI.Lotro.Action.EnterKey) then
            DoCallbacks(w, "EnterKeyPressed");
        elseif (args.Action == Turbine.UI.Lotro.Action.Escape) then
            DoCallbacks(w, "EscapeKeyPressed");
        end
    end);
end

-- Workaround for localized number format differences
local original_tonumber = _G.tonumber;
function _G.tonumber(str)
    if (str) then
        local num = original_tonumber(str);
        if (not num) then
            str = string.gsub(str, "%.", ",", 1);
            num = original_tonumber(str);
        end
        if (not num) then
            str = string.gsub(str, ",", ".", 1);
            num = original_tonumber(str);
        end
        return num;
    end
end

-- Mapping to translate from UTF-8 (in which this file is encoded) into
-- Windows code page 1252 (used in Shortcut data fields):
utf2win, win2utf = {}, {};
for n, c in pairs({
    "€", "⌂", "‚", "ƒ", "„", "…", "†", "‡", "ˆ", "‰", "Š", "‹", "Œ", "⌂", "Ž", "⌂",
    "⌂", "‘", "’", "“", "”", "•", "–", "—", "˜", "™", "š", "›", "œ", "⌂", "ž", "Ÿ",
    " ", "¡", "¢", "£", "¤", "¥", "⌂", "§", "¨", "©", "ª", "«", "¬", "⌂", "®", "¯",
    "°", "±", "²", "³", "´", "µ", "¶", "·", "¸", "¹", "º", "»", "¼", "½", "¾", "¿",
    "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï",
    "Ð", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "×", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "Þ", "ß",
    "à", "á", "â", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï",
    "ð", "ñ", "ò", "ó", "ô", "õ", "ö", "÷", "ø", "ù", "ú", "û", "ü", "ý", "þ", "ÿ"
}) do
    utf2win[c] = string.char(n + 127);
    win2utf[string.char(n + 127)] = c;
end
function string.toWindows(str)
    return str:gsub("[\226]..", utf2win):gsub("[\203\194\195\197\198].", utf2win);
end
function string.toUtf(str)
    return str:gsub(".", win2utf);
end

DANFwindow = Turbine.UI.Window();
function _G.DoAtNextFrame(func)
    if (not DANFwindow.Update) then
        DANFwindow.Update = {
            function(win)
                win:SetWantsUpdates(false)
                win.Update = nil;
            end
        }
    end
    table.insert(DANFwindow.Update, func);
    DANFwindow:SetWantsUpdates(true);
end
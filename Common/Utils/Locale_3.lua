Locale = class(Turbine.Object);

function Locale:Constructor(language)

    -- We don't need separate treatment for U.S. and British English.
    if (language == Turbine.Language.EnglishGB) then
        language = Turbine.Language.English;
    end
    self.language = language;

    -- Global table for containing localized text strings
    self.text = {};

    self.contextDelimiter = "/";
    self:SetContext("/");
end

function Locale:AddText(newText)
    local function merge(src, dest)
        for k, v in pairs(src) do 
            if (type(v) == "table") then
                if (dest[k] == nil) then
                    dest[k] = {};
                end
                merge(v, dest[k]);
            else
                dest[k] = v;
            end
        end
    end
    merge(newText, self.text);
end

function Locale:SetLanguage(language)
    if (not language) then
        language = self:GetClientLanguage();
    end
    self.language = language;
    DoCallbacks(self, "LanguageChanged");
end

function Locale:GetLanguage()
    return self.language;
end

function Locale:SetContext(newContext)
--Puts("Entering context " .. newContext .. "; " .. Turbine.Engine.GetCallStack());
    local previousContext = self.contextStr;
    if (string.sub(newContext, 1, 1) == self.contextDelimiter) then
        self.context = self.text;
        self.contextStr = self.contextDelimiter;
        newContext = string.sub(newContext, 2, -1);
    end
    for c in string.gmatch(newContext, "[^" .. self.contextDelimiter .. "]+") do
        if (not self.context[c]) then
            Puts("Can't find " .. c .. " in " .. self.contextStr .. "\n" .. Turbine.Engine.GetCallStack());
            break;
        end
        self.context = self.context[c];
        self.contextStr = self.contextStr .. c .. self.contextDelimiter;
    end
    return previousContext;
end

function Locale:GetContext()
    return self.contextStr;
end

function Locale:GetNumber(itemName)
    return tonumber(self:GetText(itemName));
end

function Locale:GetText(itemName)
    if (type(itemName) ~= "string") then
        error("Argument (" .. Serialize(itemName) .. ") is not a string.", 2);
    end
    context, remainder = string.match(itemName, "^(.*" .. self.contextDelimiter .. ")([^" .. self.contextDelimiter .. "]+)$");
    if (context) then
        -- Temporarily change to the new context, get item, then return to previous context
        local prevContext = self:SetContext(context);
        local text = self:GetText(remainder);
        self:SetContext(prevContext);
        return text;
    end
    local item = self.context[itemName];
    if (not item) then
        return "(" .. tostring(itemName) .. " not found)";
    end
    local value = item[self.language];
    if (not value) then
        value = "(" .. itemName .. " not localized)";
    elseif (value == "?") then
        value = item[Turbine.Language.English];
        if (type(value) == "string") then
            value = value .. "†";
        end
    end
    return value;
end

-- Returns the item for the game client's native language, regardless of SetLanguage()
-- Good for chat window parsing and shell commands.
function Locale:GetClientLanguageText(itemName)

    -- Temporarily change the language to the game client's language
    local selectedLanguage = self.language;
    self.language = self:GetClientLanguage();
    
    -- Get the requested item
    local value = self:GetText(itemName);
    
    -- Restore the selected language
    self.language = selectedLanguage;
    
    return value;
end

-- Returns the game client's native language, regardless of SetLanguage()
function Locale:GetClientLanguage()
    local language = Turbine.Engine.GetLanguage();
    if (language == Turbine.Language.EnglishGB) then
        language = Turbine.Language.English;
    end
    return language;
end

function Locale:GetItem(text)
    for name, translations in pairs(self.context) do
        if (translations[self.language] == text) then
            return name;
        elseif (translations[Turbine.Language.English] .. "†" == text) then
            return name;
        end
    end
    return nil;
end

function Locale:GetItems(context)
    local prevContext = self:GetContext();
    if (context) then
        self:SetContext(context);
    end
    local items = {};
    for name, translations in pairs(self.context) do
        table.insert(items, name);
    end
    if (context) then
        self:SetContext(prevContext);
    end
    return items;
end

function Locale:GetSortedTexts(context)
    local prevContext = self:GetContext();
    if (context) then
        self:SetContext(context);
    end
    local items = {};
    for item in keys(self.context) do
        table.insert(items, self:GetText(item));
    end
    table.sort(items);
    if (context) then
        self:SetContext(prevContext);
    end
    return items;
end

LovelyMouseFinder = LovelyMouseFinder or {};
LovelyMouseFinder.Utils = LovelyMouseFinder.Utils or {};
LovelyMouseFinder.Utils.Locale = Locale;

-- Create a single instance of this object
if (not _G.L) then
    _G.L = Locale(Turbine.Engine.GetLanguage());
--_G.L = Locale(Turbine.Language.French);
--_G.L = Locale(Turbine.Language.German);
end

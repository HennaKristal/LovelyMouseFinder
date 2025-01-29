-- Shorthand for languages
local en = Turbine.Language.English;
local fr = Turbine.Language.French;
local de = Turbine.Language.German;
local ru = Turbine.Language.Russian;

local text = {};

-- Hello message that appears when plugin is loaded
text.HelloMessage = {
    [en] = "<u><rgb=#DAA520>Mouse Finder v<version>, by Thurallor</rgb></u>";
    [de] = "<u><rgb=#DAA520>Mouse Finder v<version> von Thurallor</rgb></u>";
    [fr] = "?";
    [ru] = "<u><rgb=#DAA520>Mouse Finder v<version> от Thurallor</rgb></u>__"
};

-- Options panel strings
text.OptionsPanel = {};

-- Add translations to the global database (see LovelyMouseFinder.Common.Utils.Locale.lua)
L:AddText(text);

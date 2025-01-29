import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";

local importPath = getfenv(1)._.Name;
local commonPath = string.gsub(importPath, "%.UI%.ColorPicker_[0-9]+$", "");

--import (commonPath .. ".Turbine");
--import (commonPath .. ".Utils");
--import (commonPath .. ".UI.RadioButton");
import (importPath .. ".Locale");
import (importPath .. ".Slider");
import (importPath .. ".Palette");
import (importPath .. ".SwatchBar");
import (importPath .. ".ColorPicker");

LovelyMouseFinder = LovelyMouseFinder or {};
LovelyMouseFinder.UI = LovelyMouseFinder.UI or {};
LovelyMouseFinder.UI.ColorPicker = ColorPicker;

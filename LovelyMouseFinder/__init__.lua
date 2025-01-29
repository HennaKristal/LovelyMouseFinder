-- Standard Turbine libraries
import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";

local importPath = getfenv(1)._.Name;
local LovelyMouseFinderPath = string.gsub(importPath, "%.LovelyMouseFinder$", "");

-- LovelyMouseFinder's libraries
local commonPath = LovelyMouseFinderPath .. ".Common";
import (commonPath .. ".Turbine");
import (commonPath .. ".Utils.Locale_3");
import (commonPath .. ".Utils.Color_1");
import (commonPath .. ".Utils.Utils_11");
import (commonPath .. ".UI.RadioButton_2");
import (commonPath .. ".UI.ColorPicker_4");

-- Friend Alert source files
import (importPath .. ".Locale");
import (importPath .. ".Settings");
import (importPath .. ".Main");

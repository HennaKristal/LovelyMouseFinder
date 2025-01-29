-- Default settings
defaultSettings = {
    scale = 1.0;
    showOnlyInCombat = true;
    speed = 1;
    dividedSpeed = 1;
    persistTime = 1.0;
    color = Turbine.UI.Color.White;
    cycleColors = false;
    colorCycleSpeed = 10.0;
};
settings = {};
DeepTableCopy(defaultSettings, settings);

optionsPanel = Turbine.UI.Control();

-- Function for drawing the options panel
function UpdateOptionsPanel()
    local prevContext = L:SetContext("/OptionsPanel");
    local font = Turbine.UI.Lotro.Font.Verdana12;
    local left, top, width = 10, 10, 300;
    local columnWidth = math.floor(width / 2);
    
    if (not optionsPanel.showOnlyInCombat) then
        optionsPanel.showOnlyInCombat = Turbine.UI.Lotro.CheckBox();
        optionsPanel.showOnlyInCombat:SetParent(optionsPanel);
        optionsPanel.showOnlyInCombat:SetSize(width, 16);
        optionsPanel.showOnlyInCombat:SetPosition(left, top);
        optionsPanel.showOnlyInCombat:SetFont(font);
        optionsPanel.showOnlyInCombat:SetCheckAlignment(Turbine.UI.ContentAlignment.MiddleLeft);        
        optionsPanel.showOnlyInCombat:SetText("Show only when in combat");
        optionsPanel.showOnlyInCombat.CheckedChanged = function(box)
            settings.showOnlyInCombat = box:IsChecked();
            DoCallbacks(optionsPanel, "SettingsChanged");
        end

        local function add_horizontal_line(top)
            top = top + 24
            local line = Turbine.UI.Control();
            line:SetParent(optionsPanel);
            line:SetPosition(0, top);
            line:SetSize(width + (left * 2), 1);
            line:SetBackColor(Turbine.UI.Color(41/255, 48/255, 72/255));
            return top + 8;
        end
        
        top = add_horizontal_line(top);
        optionsPanel.speedLabel = Turbine.UI.Label();
        optionsPanel.speedLabel:SetParent(optionsPanel);
        optionsPanel.speedLabel:SetSize(width, 16);
        optionsPanel.speedLabel:SetPosition(left, top);
        optionsPanel.speedLabel:SetFont(font);
        optionsPanel.speedLabel:SetText("Rotation speed");
        
        top = top + 16;
        optionsPanel.speed = Turbine.UI.Lotro.ScrollBar();
        optionsPanel.speed:SetParent(optionsPanel);
        optionsPanel.speed:SetSize(width, 10);
        optionsPanel.speed:SetPosition(left, top);
        optionsPanel.speed:SetMinimum(0);
        optionsPanel.speed:SetMaximum(100);
        optionsPanel.speed.ValueChanged = function(bar)
            settings.speed = bar:GetValue();
            settings.dividedSpeed = 1 / settings.speed;
            DoCallbacks(optionsPanel, "SettingsChanged");
        end

        top = add_horizontal_line(top);
        optionsPanel.persistTimeLabel = Turbine.UI.Label();
        optionsPanel.persistTimeLabel:SetParent(optionsPanel);
        optionsPanel.persistTimeLabel:SetSize(width, 16);
        optionsPanel.persistTimeLabel:SetPosition(left, top);
        optionsPanel.persistTimeLabel:SetFont(font);
        optionsPanel.persistTimeLabel:SetText("Time to persist when movement stops");
        
        top = top + 16;
        optionsPanel.persistTime = Turbine.UI.Lotro.ScrollBar();
        optionsPanel.persistTime:SetParent(optionsPanel);
        optionsPanel.persistTime:SetSize(width, 10);
        optionsPanel.persistTime:SetPosition(left, top);
        optionsPanel.persistTime:SetMinimum(0);
        optionsPanel.persistTime:SetMaximum(100);
        optionsPanel.persistTime.ValueChanged = function(bar)
            settings.persistTime = bar:GetValue() / 10;
            DoCallbacks(optionsPanel, "SettingsChanged");
        end

        top = add_horizontal_line(top);
        optionsPanel.scaleLabel = Turbine.UI.Label();
        optionsPanel.scaleLabel:SetParent(optionsPanel);
        optionsPanel.scaleLabel:SetSize(width, 16);
        optionsPanel.scaleLabel:SetPosition(left, top);
        optionsPanel.scaleLabel:SetFont(font);
        optionsPanel.scaleLabel:SetText("Size");
        
        top = top + 16;
        optionsPanel.scale = Turbine.UI.Lotro.ScrollBar();
        optionsPanel.scale:SetParent(optionsPanel);
        optionsPanel.scale:SetSize(width, 10);
        optionsPanel.scale:SetPosition(left, top);
        optionsPanel.scale:SetMinimum(5);
        optionsPanel.scale:SetMaximum(100);
        optionsPanel.scale.ValueChanged = function(bar)
            settings.scale = 2 * bar:GetValue() / 100;
            DoCallbacks(optionsPanel, "SettingsChanged");
        end
        
        top = add_horizontal_line(top);
        optionsPanel.cycleColors = Turbine.UI.Lotro.CheckBox();
        optionsPanel.cycleColors:SetParent(optionsPanel);
        optionsPanel.cycleColors:SetSize(width, 16);
        optionsPanel.cycleColors:SetPosition(left, top);
        optionsPanel.cycleColors:SetFont(font);
        optionsPanel.cycleColors:SetCheckAlignment(Turbine.UI.ContentAlignment.MiddleLeft);        
        optionsPanel.cycleColors:SetText("Cycle colors continuously");
        optionsPanel.cycleColors.CheckedChanged = function(box)
            settings.cycleColors = box:IsChecked();
            UpdateOptionsPanel();
            DoCallbacks(optionsPanel, "SettingsChanged");
        end

        top = top + 16;
        optionsPanel.colorLabel = Turbine.UI.Label();
        optionsPanel.colorLabel:SetParent(optionsPanel);
        optionsPanel.colorLabel:SetSize(width, 16);
        optionsPanel.colorLabel:SetPosition(left, top);
        optionsPanel.colorLabel:SetFont(font);
        optionsPanel.colorLabel:SetText("Color");
        
        top = top + 16;
        optionsPanel.color = Turbine.UI.Control();
        optionsPanel.color:SetParent(optionsPanel);
        optionsPanel.color:SetSize(50, 16);
        optionsPanel.color:SetPosition(left, top);
        optionsPanel.color.MouseClick = function()
            EditColor(settings.color, function(newColor)
                settings.color = newColor;
                DoCallbacks(optionsPanel, "SettingsChanged");
            end);
        end
        optionsPanel.colorCycleSpeed = Turbine.UI.Lotro.ScrollBar();
        optionsPanel.colorCycleSpeed:SetParent(optionsPanel);
        optionsPanel.colorCycleSpeed:SetSize(width, 10);
        optionsPanel.colorCycleSpeed:SetPosition(left, top);
        optionsPanel.colorCycleSpeed:SetMinimum(0);
        optionsPanel.colorCycleSpeed:SetMaximum(100);
        optionsPanel.colorCycleSpeed.ValueChanged = function(bar)
            settings.colorCycleSpeed = bar:GetValue() / 10;
            DoCallbacks(optionsPanel, "SettingsChanged");
        end
        optionsPanel.colorCycleSpeed.position = {optionsPanel.colorCycleSpeed:GetPosition()};

        top = add_horizontal_line(top);
        local resetButton = Turbine.UI.Lotro.Button();
        resetButton:SetParent(optionsPanel);
        resetButton:SetText("Reset to defaults");
        resetButton:SetWidth(175);
        resetButton:SetPosition(left, top);
        resetButton.Click = function()
            DeepTableCopy(defaultSettings, settings);
            UpdateOptionsPanel();
            DoCallbacks(optionsPanel, "SettingsChanged");
        end;
        top = top + resetButton:GetHeight();
        
        optionsPanel:SetSize(width, top);
    end
    
    optionsPanel.showOnlyInCombat:SetChecked(settings.showOnlyInCombat);
    optionsPanel.persistTime:SetValue(settings.persistTime * 10);
    optionsPanel.speed:SetValue(settings.speed);
    optionsPanel.scale:SetValue(100 * settings.scale / 2);
    optionsPanel.color:SetBackColor(settings.color);
    optionsPanel.cycleColors:SetChecked(settings.cycleColors);
    optionsPanel.colorCycleSpeed:SetValue(settings.colorCycleSpeed * 2);
    if (settings.cycleColors) then
        optionsPanel.colorLabel:SetText("Color cycle speed");
        optionsPanel.color:SetVisible(false);
        optionsPanel.colorCycleSpeed:SetParent(optionsPanel);        
        optionsPanel.colorCycleSpeed:SetPosition(unpack(optionsPanel.colorCycleSpeed.position));
        optionsPanel.colorCycleSpeed:SetVisible(true);
    else
        optionsPanel.colorLabel:SetText("Color");
        optionsPanel.color:SetVisible(true);
        optionsPanel.colorCycleSpeed:SetParent(nil);
    end

    L:SetContext(prevContext);
end

function EditColor(prevColor, changeFunc)
    if (colorPicker) then
        colorPicker:Close();
    end
    colorPicker = LovelyMouseFinder.UI.ColorPicker(prevColor, "H");
    colorPicker.Accepted = function()
        local newColor = colorPicker:GetColor();
        changeFunc(newColor);
        SaveSettings();
        UpdateOptionsPanel();
        colorPicker = nil;
    end
    colorPicker.Canceled = function()
        colorPicker = nil;
    end
end

function SaveSettings()
--Turbine.Shell.WriteLine("Saving...");
    -- Workaround for Turbine localization bug
    local saveData = ExportTable(settings);
    Turbine.PluginData.Save(Turbine.DataScope.Account, "LovelyMouseFinder", saveData, function()
--Turbine.Shell.WriteLine("Save complete.");
    end);
end

function LoadSettings()
    Turbine.PluginData.Load(Turbine.DataScope.Account, "LovelyMouseFinder", function(loadedData)
--Turbine.Shell.WriteLine("Loading...");
        if (loadedData) then
            -- Workaround for Turbine localization bug
            loadedData = ImportTable(loadedData);
            DeepTableCopy(loadedData, settings);
            settings.color = Turbine.UI.Color(settings.color.A, settings.color.R, settings.color.G, settings.color.B);
            UpdateOptionsPanel();
            DoCallbacks(optionsPanel, "SettingsChanged");
--Turbine.Shell.WriteLine("Load complete.");
        end
    end);
end

-- Display the default settings
UpdateOptionsPanel();

-- Create the "options" tab in the plugin manager.
plugin.GetOptionsPanel = function()
    return optionsPanel;
end

Turbine.Plugin.Load = LoadSettings;
Turbine.Plugin.Unload = SaveSettings;

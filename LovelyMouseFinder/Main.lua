import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";

win = Turbine.UI.Window();
win:SetBackground("LovelyMouseFinder/LovelyMouseFinder/images/heart_12.tga");
win:SetVisible(true);
win:SetStretchMode(2);
win:RegisterForGlobalScaling();
win:SetScale(settings.scale);
win:SetStretchMode(1);
win:SetBackColorBlendMode(Turbine.UI.BlendMode.Color);
win:SetMouseVisible(false);
win:SetZOrder(2147483647);
win:SetWantsUpdates(true);
win.nativeWidth, win.nativeHeight = win:GetSize();
win.animMaxFrames = 12;
win.anim = win.animMaxFrames;
win.lastUpdateTime = Turbine.Engine.GetGameTime();

AddCallback(optionsPanel, "SettingsChanged", function()
    win:SetBackColor(LovelyMouseFinder.Utils.Color(settings.color.A, settings.color.R, settings.color.G, settings.color.B));
    win.width, win.height = settings.scale * win.nativeWidth, settings.scale * win.nativeHeight;
    win:SetSize(win.width, win.height);
    local x, y = Turbine.UI.Display:GetMousePosition();
    win:SetPosition(x - win.width / 2, y - win.height / 2);
end);

function win:Update()
    local x, y = Turbine.UI.Display:GetMousePosition();
    self:SetPosition(x - self.width / 2, y - self.height / 2);

    if (settings.speed > 0) then
        local currentTime = Turbine.Engine.GetGameTime();
        local timeDiff = currentTime - self.lastUpdateTime;
        local framesPassed = math.floor(timeDiff * settings.speed);

        if (framesPassed >= 1 and timeDiff >= 0.05) then
            self.anim = self.anim + framesPassed;
            if self.anim > self.animMaxFrames then self.anim = self.anim % self.animMaxFrames end
            if self.anim == 0 then self.anim = 1; end
            self:SetBackground("LovelyMouseFinder/LovelyMouseFinder/images/heart_" .. self.anim .. ".tga");
            self.lastUpdateTime = currentTime;
        end
    end
end

-- Apply defaults immediately, even when there is no saved settings file.
DoCallbacks(optionsPanel, "SettingsChanged");

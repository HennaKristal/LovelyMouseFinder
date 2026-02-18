import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";

local hello = L:GetText("/HelloMessage");
hello = string.gsub(hello, "<version>", plugin:GetVersion());
Puts(hello);

win = Turbine.UI.Window();
--win:SetSize(480, 480);
win:SetBackground("LovelyMouseFinder/LovelyMouseFinder/images/Low/heart_12.tga");
win:SetVisible(true);
win:SetStretchMode(2);
win.nativeWidth, win.nativeHeight = win:GetSize();
win:SetVisible(false);
win:SetBackColorBlendMode(Turbine.UI.BlendMode.Color);
win:SetMouseVisible(false);
win:SetZOrder(2147483647);
win.backColor = LovelyMouseFinder.Utils.Color(1, 1, 1);
win.rotateAngle = 0;
win.hueAngle = 0;
win.anim = 36;
win.nextAnimTime = 0;
win.lastUpdateTime = 0;

player = Turbine.Gameplay.LocalPlayer:GetInstance();
AddCallback(player, "InCombatChanged", function(sender, args)
    win.inCombat = player:IsInCombat();
    if (win.inCombat) then
        win.x, win.y = Turbine.UI.Display:GetMousePosition();
        win:SetWantsUpdates(true);
    end
end);

AddCallback(optionsPanel, "SettingsChanged", function()
    win:SetWantsUpdates(true);
    win.backColor = LovelyMouseFinder.Utils.Color(settings.color.A, settings.color.R, settings.color.G, settings.color.B);
    if (not settings.cycleColors) then
        win:SetBackColor(win.backColor);
    end
    win.width, win.height = settings.scale * win.nativeWidth, settings.scale * win.nativeHeight;
    win:SetVisible(false);
    win.displayStartTime = nil;
    win.x, win.y = nil, nil;
    win:SetWantsUpdates(true);
end);

function win:Update()
    local currentGameTime = Turbine.Engine.GetGameTime()
    local x, y = Turbine.UI.Display:GetMousePosition();
    self.moved = ((self.x ~= x) or (self.y ~= y));
    self.x, self.y = x, y;

    if (self.moved) then
        if (not self.displayStartTime) then
            self:SetVisible(true);
            win:SetStretchMode(1);
            win:SetSize(win.width, win.height);
        end
        self:SetPosition(x - self.width / 2, y - self.height / 2);
        self.displayStartTime = currentGameTime;
    elseif (self.displayStartTime) then
        if (currentGameTime - self.displayStartTime >= settings.persistTime) then

            if settings.persistTime ~= 10 then
                self.displayStartTime = nil;
                self:SetVisible(false);
            end

            if (settings.showOnlyInCombat and not self.inCombat) then
                self:SetWantsUpdates(false);
                self.displayStartTime = nil;
                self:SetVisible(false);
            end
        end
    end

    if (self.displayStartTime) then

        if (settings.speed > 0) then
            local currentTime = currentGameTime
            local timeDiff = currentTime - win.lastUpdateTime
            local framesPassed = math.floor(timeDiff / settings.dividedSpeed)

            if framesPassed >= 1 and timeDiff >= 0.05 then
                self.anim = self.anim + framesPassed;
                if self.anim > 12 then self.anim = self.anim % 12 end
                if self.anim == 0 then self.anim = 1; end
                win:SetBackground("LovelyMouseFinder/LovelyMouseFinder/images/Low/heart_" .. win.anim .. ".tga")
                win.lastUpdateTime = currentTime
            end
        end

        if (settings.cycleColors) then
            self.hueAngle = self.hueAngle + settings.colorCycleSpeed;
            self.backColor:SetHSV((self.hueAngle % 360) / 360, 1, 1);
            self:SetBackColor(self.backColor);
        end
    end
end

/*--------------------------------------------------
todo
gib decal
face on decap
config menu
custon cap
ragdoll blacklist

--------------------------------------------------*/



/*
local frame = vgui.Create("DFrame")
frame:SetSize(500, 320)
frame:Center()
frame:SetTitle("")
frame:MakePopup()

-- Fonts
surface.CreateFont("MenuTitle", {
    font = "Roboto",
    size = 24,
    weight = 700
})

surface.CreateFont("MenuText", {
    font = "Roboto",
    size = 18,
    weight = 500
})

-- Frame
frame.Paint = function(self, w, h)
    draw.RoundedBox(12, 0, 0, w, h, Color(24, 24, 30))
    draw.RoundedBox(12, 0, 0, w, 45, Color(40, 45, 60))

    draw.SimpleText("⚙ Settings", "MenuTitle", 15, 22, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local sliders = {
    {"Volume", 0, 100, 80},
    {"Brightness", 0, 100, 60},
    {"Mouse Sensitivity", 1, 20, 10},
}

local y = 65

for _, data in ipairs(sliders) do
    local slider = vgui.Create("DNumSlider", frame)
    slider:SetPos(20, y)
    slider:SetSize(460, 50)

    slider:SetText("")
    slider:SetMin(data[2])
    slider:SetMax(data[3])
    slider:SetDecimals(0)
    slider:SetValue(data[4])

    -- Draw the label
    slider.Paint = function(self, w, h)
        draw.SimpleText(data[1], "MenuText", 0, 0, color_white)
    end

    -- Slider bar
    slider.Slider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, h / 2 - 2, w, 4, Color(70, 70, 80))
    end

    -- Slider knob
    slider.Slider.Knob.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 170, 255))
    end

    -- Number box
    slider.TextArea.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 45))
        self:DrawTextEntryText(color_white, Color(0,170,255), color_white)
    end

    slider.TextArea:SetTextColor(color_white)
    slider.TextArea:SetCursorColor(color_white)
    slider.TextArea:SetHighlightColor(Color(0,170,255))

    function slider:OnValueChanged(val)
        print(data[1], math.Round(val))
    end

    y = y + 70
end

*/
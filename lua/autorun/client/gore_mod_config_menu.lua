local fontName

if system.IsLinux() then
    -- On Linux, use the font file name.
    fontName = "smash.ttf"
else
    -- On Windows/macOS, use the font's internal name.
    fontName = "smash"
end

surface.CreateFont( "smash", {
	font = fontName, -- On Windows/macOS, use the font-name which is shown to you by your operating system Font Viewer. On Linux, the font-name *may* work, but using the file name is more reliable
	extended = false,
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
local faded_black = Color(0, 0, 0, 200) -- The color black but with 200 Alpha
function GoremodOpenConfirmMenu()
	if not LocalPlayer():IsListenServerHost() then return end
	local DermaPanel = vgui.Create("DFrame") -- The name DermaPanel to store the value DFrame.
	DermaPanel:SetSize(ScrW() * 0.5, ScrH() * 0.5)
	DermaPanel:Center() -- Centers the panel.
	DermaPanel:SetTitle("") -- Set the title to nothing.
	DermaPanel:SetDraggable(false) -- Makes it so you can't drag it.
	DermaPanel:MakePopup() -- Makes it so you can move your mouse on it.

	-- Paint function w, h = how wide and tall it is.
	DermaPanel.Paint = function(self, w, h)
	    -- Draws a rounded box with the color faded_black stored above.
	    draw.RoundedBox(2, 0, 0, w, h, faded_black)
	    -- Draws text in the color white.
	    draw.SimpleText("Derma Frame", "smash", 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
local checkbox = window:Add( "DCheckBox" ) -- Create the checkbox
checkbox:SetPos( 25, 50 ) -- Set the position
checkbox:SetValue( true ) -- Initial "ticked" value
end

list.Set("DesktopWindows", "goremodconfig", {
	title = "goremodconfig",
	icon = "gui/effects/bloodimpact.png",
	init = function(icon, window)
	if IsValid(window) then 
		window:Remove() 
	end
	GoremodOpenConfirmMenu()
end
})
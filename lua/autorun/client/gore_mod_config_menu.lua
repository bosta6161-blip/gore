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
	size = 20,
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
local color_red = Color(255, 0, 0)
local faded_black = Color(0, 0, 0, 200) -- The color black but with 200 Alpha
local function foo(arguments)
	local tabGeneral = vgui.Create("DScrollPanel", sheet)
tabGeneral:Dock(FILL)
local formGeneral = vgui.Create("DForm", tabGeneral)
formGeneral:Dock(TOP)
formGeneral:SetName("General Options")

formGeneral:Help("")
formGeneral:CheckBox( "gore enable", "gore_enable" )
formGeneral:CheckBox( "live dismenber EXPEREMENTAL", "live_dismenber_EXPEREMENTAL" )
formGeneral:NumSlider( "limb_health_multiplier", "limb_health_multiplier", -10, 10 )
formGeneral:NumSlider( "root_bone_health_multiplier", "root_bone_health_multiplier", -10, 10 )
end
function GoremodOpenConfirmMenu()
	if not LocalPlayer():IsListenServerHost() then return end
	local width = ScrW() * 0.5
	local height = ScrH() * 0.5
	local DermaPanel = vgui.Create("DFrame") -- The name DermaPanel to store the value DFrame.
	DermaPanel:SetSize(width,height)
	DermaPanel:Center() -- Centers the panel.
	DermaPanel:SetTitle("") -- Set the title to nothing.
	DermaPanel:SetDraggable(false) -- Makes it so you can't drag it.
	DermaPanel:MakePopup() -- Makes it so you can move your mouse on it.
	local sheet = vgui.Create("DPropertySheet", DermaPanel)
	sheet:Dock(FILL) -- Makes the tab system fill the entire window
	DermaPanel.Paint = function(self, w, h)
	    -- Draws a rounded box with the color faded_black stored above.
	    draw.RoundedBox(4, 0, 0, w, h, faded_black)
	    -- Draws text in the color white.
	    draw.SimpleText("goremod config", "smash",width/2,2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	local panel1 = vgui.Create( "DPanel", sheet )
	sheet:AddSheet( "test", panel1, "icon16/cross.png" )
	panel1.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h,faded_black) end 
	local formGeneral = vgui.Create("DForm", panel1)
	formGeneral:Dock(TOP)
	formGeneral:SetName("General Options")

	formGeneral:CheckBox( "gore enable", "gore_enable" )
	formGeneral:CheckBox( "live dismenber EXPEREMENTAL", "live_dismenber_EXPEREMENTAL" )
	formGeneral:NumSlider( "limb_health_multiplier", "limb_health_multiplier", -10, 10 )
	formGeneral:NumSlider( "root_bone_health_multiplier", "root_bone_health_multiplier", -10, 10 )

	local panel2 = vgui.Create( "DPanel", sheet )
	sheet:AddSheet( "test 2", panel2, "icon16/tick.png" )
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
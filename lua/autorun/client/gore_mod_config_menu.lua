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
function GoremodOpenConfirmMenu()

    local frame = vgui.Create("DFrame")
	local width = ScrW() * 0.5
	local height = ScrH() * 0.5
    frame:SetSize(width, height)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35))
		draw.SimpleText("goremod config", "smash",width/2,2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    -- Sidebar
    local sidebar = vgui.Create("DScrollPanel", frame)
    sidebar:Dock(LEFT)
    sidebar:SetWide(180)

    sidebar.Paint = function(self, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 25), true, false, true, false)
    end

    -- Content panel
    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(45, 45, 45))
    end

    local function ShowPage(title)

        content:Clear()
		if title == "Settings" then
			local DermaCheckbox = content:Add( "DCheckBoxLabel" ) -- Create the checkbox

			DermaCheckbox:SetText("gore enable")					-- Set the text next to the box
			DermaCheckbox:SetValue( true )						-- Initial value
			DermaCheckbox:SetFont("smash")
			DermaCheckbox:SetTextColor(color_white)
			DermaCheckbox:SizeToContents()						-- Make its size the same as the contents
			DermaCheckbox:SetConVar("gore_enable")				-- Change a ConVar when the box it ticked/unticked
		else
        local label = vgui.Create("DLabel", content)
        label:SetFont("Trebuchet24")
        label:SetText(title)
        label:SetTextColor(color_white)
        label:Dock(TOP)
        label:DockMargin(20, 20, 0, 20)
        label:SizeToContents()		
		end




    end

    local pages = {
        "Home",
        "Settings",
        "Players",
        "Weapons",
        "About"
    }

    for _, name in ipairs(pages) do

        local btn = sidebar:Add("DButton")
        btn:Dock(TOP)
        btn:DockMargin(8, 8, 8, 0)
        btn:SetTall(40)
        btn:SetText("")

        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(70,120,255) or Color(45,45,45)
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(name, "DermaDefaultBold", 15, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        btn.DoClick = function()
            ShowPage(name)
        end

    end

    -- Close button
    local close = vgui.Create("DButton", frame)
    close:SetSize(30, 30)
    close:SetPos(frame:GetWide() - 35, 5)
    close:SetText("X")
    close.DoClick = function()
        frame:Close()
    end

    ShowPage("Home")

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
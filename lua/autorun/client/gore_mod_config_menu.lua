

surface.CreateFont( "smash", {
	font = "smash", -- On Windows/macOS, use the font-name which is shown to you by your operating system Font Viewer. On Linux, the font-name *may* work, but using the file name is more reliable
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
local function gore_mod_Add_CheckBox(parent,text,convas_name)
    local checkbox = vgui.Create("DCheckBoxLabel", parent)
    checkbox:SetText(text)
    checkbox:SetFont("smash")
    checkbox:SetValue(GetConVar(convas_name):GetBool())						-- Initial value
    checkbox:SetTextColor(color_white)
    checkbox:Dock(TOP)
    checkbox:DockMargin(20,2,20,0)
    checkbox:SizeToContents()
	checkbox:SetConVar(convas_name)				-- Change a ConVar when the box it ticked/unticked
end
local function gore_mod_Add_label(parent,text,tiny)
    local label = vgui.Create("DLabel", parent)
    if not tiny then
        label:SetFont("smash")
        label:DockMargin(20,20,20,10)
    else
        label:DockMargin(20,5,20,10)
    end
    label:SetText(text)
    label:Dock(TOP)

    label:SizeToContents()
end
local function gore_mod_Add_slider(parent,text,convas_name,min,max,notdecimal)
    local slider = vgui.Create("DNumSlider", parent)
    slider:Dock(TOP)
    slider:DockMargin(20,5,20,0)
    slider:SetText("")
    slider:SetMin(min)
    slider:SetMax(max)
    if notdecimal then
        slider:SetDecimals(0)
    else
        slider:SetDecimals(1)
    end

    slider:SetValue(GetConVar(convas_name):GetInt())	
	slider:SetConVar(convas_name)		
    slider.Paint = function(self, w, h)
        draw.SimpleText(text, "smash", 0, 0, color_white)
    end

end
function GoremodOpenConfirmMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 600)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30,30,30))
    end

    -- Sidebar
    local sidebar = vgui.Create("DPanel", frame)
    sidebar:Dock(LEFT)
    sidebar:SetWide(180)

    sidebar.Paint = function(self, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(40,40,40), true, false, true, false)
    end

    -- Main Content
    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)

    content.Paint = function(self, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(50,50,50), false, true, false, true)
    end

    local function OpenPage(name)
        content:Clear()
        gore_mod_Add_label(content,name)
        if name == "General" then
            gore_mod_Add_CheckBox(content,"gore is enable!","goremod_enable")
            gore_mod_Add_label(content,"Disable Noob gore mod.",true)
            gore_mod_Add_CheckBox(content,"Gib ragdoll!","goremod_can_gib_only_npc_corpse")
            gore_mod_Add_label(content,"Disable gore to only ragdolls spawned by NPCs/nextbots/players.",true)
            gore_mod_Add_CheckBox(content,"can destroy bodies","goremod_can_gib_ragdoll")
            gore_mod_Add_label(content,"After you kill the NPC, you can't destroy the body, this can help with performance when there's a lot going on.",true)
            gore_mod_Add_CheckBox(content,"can NPC explode","goremod_can_npc_explode")
            gore_mod_Add_label(content,"Disable NPC explode when die from explosion",true)
            gore_mod_Add_CheckBox(content,"cannibalism","goremod_cannibalism")
            gore_mod_Add_label(content,"Eat gibs to restore life",true)
            gore_mod_Add_CheckBox(content,"ragdoll has gore models","goremod_ragdoll_has_gap_models")
        elseif name == "experimental" then
            gore_mod_Add_CheckBox(content,"dismember living NPC","goremod_live_dismenber_EXPEREMENTAL")
            gore_mod_Add_label(content,"NPC can lose limbs in combat.",true)
            gore_mod_Add_CheckBox(content,"burned corpse effect","goremod_burned_corpse_effect_EXPEREMENTAL")
            gore_mod_Add_label(content,"Replace the NPC model when it dies from a burn.",true)
            gore_mod_Add_CheckBox(content,"dissolve efect","goremod_dissolve_efect_EXPEREMENTAL")
            gore_mod_Add_label(content,"When the NPC dissolves, it turns to dust.",true)
            gore_mod_Add_CheckBox(content,"Acid efect","goremod_acid_efect_EXPEREMENTAL")
            gore_mod_Add_label(content,"When the NPC dissolves, it turns to skeleton.",true)
            gore_mod_Add_CheckBox(content,"sawblade slice","goremod_sawblade_slice_EXPEREMENTAL")
            gore_mod_Add_label(content,"just like zombies.",true)
        elseif name == "Ragdoll Option" then
            gore_mod_Add_slider(content,"limb health multiplier","goremod_limb_health_multiplier",-10,10)
            gore_mod_Add_label(content,"multiplies the health of the members.",true)
            gore_mod_Add_slider(content,"root bone health multiplier","goremod_root_bone_health_multiplier",-10,10)
            
            gore_mod_Add_CheckBox(content,"Crush damege slice ragdoll","goremod_DMG_CRUSH_slice_ragdoll")
            gore_mod_Add_label(content,"Disable ragdoll sliced when is crush",true)
            gore_mod_Add_CheckBox(content,"Disable ragdoll colision","goremod_Disable_ragdoll_colision")
            gore_mod_Add_label(content,"Remove corpse colision",true)
        elseif name == "Gib Option" then
            gore_mod_Add_label(content,"Set value to max to make gib never fade" )
            gore_mod_Add_slider(content,"gib fade time","goremod_gib_fade_time",0,999)
            gore_mod_Add_label(content,"gib fade time.",true )
            gore_mod_Add_slider(content,"Ragdoll limb fade time","goremod_sliced_ragdoll_fade_time",0,999 )
            gore_mod_Add_label(content,"Ragdoll limb fade time",true )

            gore_mod_Add_slider(content,"limb limit","goremod_sliced_ragdoll_limit",0,50,true)
            gore_mod_Add_label(content,"Ragdoll limb can be espensive",true )
            gore_mod_Add_slider(content,"Gib limit","goremod_gib_limit",0,6700,true)
        elseif name == "Blood Option" then
            gore_mod_Add_CheckBox(content,"goremod_blood","goremod_blood")
            gore_mod_Add_slider(content,"Blood sound volume","nextgenblood4_squirt_sound_volume",0,2)
        elseif name == "About" then
            local text = vgui.Create("DLabel", content)
            text:SetText("My Config Menu\nVersion 1.0")
            text:Dock(TOP)
            text:DockMargin(20,10,20,0)
            text:SizeToContents()
            
            local reset = vgui.Create("DButton", content)
            reset:Dock(TOP)
            reset:DockMargin(20,20,20,0)
            reset:SetTall(40)
            reset:SetText("Reset Configuration")

            reset.DoClick = function()

                RunConsoleCommand("myaddon_enabled", "1")
                RunConsoleCommand("myaddon_brightness", "50")

                notification.AddLegacy("Configuration Reset!", NOTIFY_GENERIC, 3)
                surface.PlaySound("garrysmod/save_load"..math.random(1,3)..".wav")
                --surface.PlaySound("buttons/button15.wav")
            end

        end
    end

    local pages = {
        "General",
        "Ragdoll Option",
        "Gib Option",
        "Blood Option",
        "experimental",
        "About"
    }

    for _, page in ipairs(pages) do
        local btn = vgui.Create("DButton", sidebar)
        btn:Dock(TOP)
        btn:SetTall(50)
        btn:DockMargin(8, 8, 8, 0)
        btn:SetText("")
        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(70,120,255) or Color(45,45,45)
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(page, "DermaDefaultBold", 15, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            OpenPage(page)
        end
    end
    OpenPage("General")
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
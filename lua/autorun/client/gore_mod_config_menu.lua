-- Client copy of the server-authoritative NPC blacklist.
LambdaGoreNPCBlacklist = LambdaGoreNPCBlacklist or {}

net.Receive("LambdaGore_BlacklistSync", function()
    LambdaGoreNPCBlacklist = {}

    local count = net.ReadUInt(16)
    for _ = 1, count do
        LambdaGoreNPCBlacklist[net.ReadString()] = true
    end

    if IsValid(LambdaGoreNPCBlacklistView) then
        LambdaGoreNPCBlacklistView:Refresh()
    end
end)

local function LambdaGore_SendBlacklistAction(action, model)
    net.Start("LambdaGore_BlacklistAction")
        net.WriteString(action)
        net.WriteString(model or "")
    net.SendToServer()
end

concommand.Add("lambda_gore_blacklist_sync", function()
    LambdaGore_SendBlacklistAction("request", "")
end)



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
            gore_mod_Add_label(content,"Disable Lambda Gore.",true)
            gore_mod_Add_CheckBox(content,"Can destroy map ragdoll!","goremod_can_gib_only_npc_corpse")
            gore_mod_Add_label(content,"Disable gore to only ragdolls spawned by NPCs/nextbots/players.",true)
            gore_mod_Add_CheckBox(content,"can destroy bodies","goremod_can_gib_ragdoll")
            gore_mod_Add_label(content,"After you kill the NPC, you can't destroy the body, this can help with performance when there's a lot going on.",true)
            gore_mod_Add_CheckBox(content,"cannibalism","goremod_cannibalism")
            gore_mod_Add_label(content,"Eat gibs to restore life",true)
            gore_mod_Add_CheckBox(content,"ragdoll has gore models","goremod_ragdoll_has_gap_models")
            gore_mod_Add_label(content,"",true)
            gore_mod_Add_slider(content,"Killshot_dismember_ratio","goremod_killshot_dismember_ratio",0.1,1)
            gore_mod_Add_label(content,"the higher this is, the harder it is to dismember with a killshot",true)
            gore_mod_Add_label(content,"",true)
            gore_mod_Add_slider(content,"NPC explode type","goremod_npc_explode_type",1,3,true)
            gore_mod_Add_label(content,"1 - normal   2 - limb exposion  3 - dissable",true)

            local reset = vgui.Create("DButton", content)
            reset:Dock(BOTTOM)
            reset:DockMargin(20,20,20,0)
            reset:SetTall(40)
            reset:DockMargin(20,5,20,10)
            reset:SetText("")
            reset.Paint = function(self, w, h)
                local col = reset:IsHovered() and Color(70,120,255) or Color(56,56,56)
                draw.RoundedBox(6, 0, 0, w, h, col)
                draw.SimpleText("Reset Configuration", "DermaDefaultBold", 15, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            reset.DoClick = function()

                RunConsoleCommand("goremod_enable", "1")
                RunConsoleCommand("goremod_can_gib_only_npc_corpse", "1")
                RunConsoleCommand("goremod_can_gib_ragdoll", "1")
                RunConsoleCommand("goremod_npc_explode_type", "1")

                RunConsoleCommand("goremod_limb_health_multiplier", "1")
                RunConsoleCommand("goremod_root_bone_health_multiplier", "1")

                RunConsoleCommand("goremod_DMG_CRUSH_slice_ragdoll", "1")
                RunConsoleCommand("goremod_Disable_ragdoll_colision", "1")
                RunConsoleCommand("goremod_gib_fade_time", "67") 
                RunConsoleCommand("goremod_sliced_ragdoll_fade_time", "30")
                RunConsoleCommand("goremod_ragdoll_has_gap_models", "1") 
                RunConsoleCommand("goremod_sliced_ragdoll_limit", "25")
                RunConsoleCommand("goremod_gib_limit", "500")

                RunConsoleCommand("goremod_blood", "1")

                RunConsoleCommand("goremod_cannibalism", "1")
                RunConsoleCommand("goremod_debug", "0")
                RunConsoleCommand("goremod_live_dismenber_EXPEREMENTAL", "0")
                RunConsoleCommand("goremod_burned_corpse_effect_EXPEREMENTAL", "0")
                RunConsoleCommand("goremod_dissolve_efect_EXPEREMENTAL", "0")
                RunConsoleCommand("goremod_acid_efect_EXPEREMENTAL", "0")
                RunConsoleCommand("goremod_sawblade_slice_EXPEREMENTAL", "0")
                RunConsoleCommand("goremod_rd_bridge_enable", "0")
                RunConsoleCommand("goremod_live_leg_break", "1")
                RunConsoleCommand("goremod_live_leg_break_angle", "35")
                RunConsoleCommand("goremod_copy_ragdoll_materials", "1")
                RunConsoleCommand("goremod_client_gap_models", "1")
                RunConsoleCommand("goremod_vortigaunt_gore_model", "0")

                -- Core ConVars (Server-side, replicated to clients)
                RunConsoleCommand("goremod_blood_stream_reps_multiplier", "1")
                RunConsoleCommand("goremod_blood_sound_volume", "1")
                RunConsoleCommand("goremod_squirt_sound_volume", "1")
                RunConsoleCommand("goremod_blood_do_decal", "1")

                -- NEW ConVars for customization (Server-side, replicated to clients)
                RunConsoleCommand("goremod_stream_size", "1")
                RunConsoleCommand("goremod_stream_force", "1")
                RunConsoleCommand("goremod_stream_spread", "5")
                RunConsoleCommand("goremod_stream_density", "1")


                notification.AddLegacy("Configuration Reset!", NOTIFY_GENERIC, 3)
                surface.PlaySound("garrysmod/save_load"..math.random(1,3)..".wav")
                --surface.PlaySound("buttons/button15.wav")
            end
        elseif name == "NPC Blacklist" then
            gore_mod_Add_label(content, "Blacklist NPC models")
            gore_mod_Add_label(content, "Blacklisted models are skipped by live dismemberment and corpse gore.", true)

            local entry = vgui.Create("DTextEntry", content)
            entry:Dock(TOP)
            entry:DockMargin(20, 8, 20, 4)
            entry:SetTall(34)
            entry:SetPlaceholderText("models/example/npc.mdl")

            local add = vgui.Create("DButton", content)
            add:Dock(TOP)
            add:DockMargin(20, 4, 20, 4)
            add:SetTall(34)
            add:SetText("Adicionar modelo à lista negra")
            add.DoClick = function()
                local model = string.Trim(string.lower(entry:GetValue() or ""))
                if model ~= "" then
                    LambdaGore_SendBlacklistAction("add", model)
                    entry:SetText("")
                    timer.Simple(0.1, function()
                        LambdaGore_SendBlacklistAction("request", "")
                    end)
                end
            end

            local addTarget = vgui.Create("DButton", content)
            addTarget:Dock(TOP)
            addTarget:DockMargin(20, 4, 20, 8)
            addTarget:SetTall(34)
            addTarget:SetText("Adicionar NPC que estou mirando")
            addTarget.DoClick = function()
                local tr = LocalPlayer():GetEyeTrace()
                if IsValid(tr.Entity) and tr.Entity:IsNPC() then
                    LambdaGore_SendBlacklistAction("add", tr.Entity:GetModel())
                    timer.Simple(0.1, function()
                        LambdaGore_SendBlacklistAction("request", "")
                    end)
                else
                    notification.AddLegacy("Mire em um NPC.", NOTIFY_ERROR, 3)
                end
            end

            local list = vgui.Create("DListView", content)
            list:Dock(FILL)
            list:DockMargin(20, 4, 20, 8)
            list:AddColumn("Modelo")
            list:SetMultiSelect(false)
            LambdaGoreNPCBlacklistView = list

            function list:Refresh()
                self:Clear()
                for model in pairs(LambdaGoreNPCBlacklist) do
                    self:AddLine(model)
                end
            end

            local remove = vgui.Create("DButton", content)
            remove:Dock(BOTTOM)
            remove:DockMargin(20, 4, 20, 4)
            remove:SetTall(34)
            remove:SetText("Remover selecionado")
            remove.DoClick = function()
                local line = list:GetSelectedLine()
                if not line then return end

                local row = list:GetLine(line)
                if not IsValid(row) then return end

                LambdaGore_SendBlacklistAction("remove", row:GetValue(1))
                timer.Simple(0.1, function()
                    LambdaGore_SendBlacklistAction("request", "")
                end)
            end

            local clear = vgui.Create("DButton", content)
            clear:Dock(BOTTOM)
            clear:DockMargin(20, 4, 20, 4)
            clear:SetTall(34)
            clear:SetText("Limpar lista negra")
            clear.DoClick = function()
                Derma_Query(
                    "Remover todos os modelos da lista negra?",
                    "Lambda Gore",
                    "Sim", function()
                        LambdaGore_SendBlacklistAction("clear", "")
                        timer.Simple(0.1, function()
                            LambdaGore_SendBlacklistAction("request", "")
                        end)
                    end,
                    "Cancelar"
                )
            end

            list:Refresh()
            LambdaGore_SendBlacklistAction("request", "")
        elseif name == "experimental" then
            gore_mod_Add_CheckBox(content,"dismember living NPC","goremod_live_dismenber_EXPEREMENTAL")
            gore_mod_Add_label(content,"NPC can lose limbs in combat.",true)
            gore_mod_Add_CheckBox(content,"broken leg pose","goremod_live_leg_injury")
            gore_mod_Add_label(content,"Rotate the calf when a live NPC takes enough leg damage.",true)
            gore_mod_Add_slider(content,"broken leg angle","goremod_live_leg_break_angle",0,90,true)
            gore_mod_Add_label(content,"Maximum visible rotation of the injured leg.",true)
            gore_mod_Add_slider(content,"leg break damage","goremod_live_leg_break_damage",1,200,true)
            gore_mod_Add_label(content,"Accumulated damage needed to break a leg.",true)
            gore_mod_Add_slider(content,"finger curl angle","goremod_live_finger_curl_angle",0,90,true)
            gore_mod_Add_label(content,"Rotation applied to finger/thumb bones after arm damage.",true)
            gore_mod_Add_CheckBox(content,"copy ragdoll materials","goremod_client_gap_models")
            gore_mod_Add_label(content,"Keep skin, face and submaterials on detached limbs.",true)
            gore_mod_Add_CheckBox(content,"Vortigaunt custom gore model","goremod_vortigaunt_gore_model")
            gore_mod_Add_label(content,"Optional bundled Vortigaunt-specific gore model.",true)
            gore_mod_Add_CheckBox(content,"burned corpse effect","goremod_burned_corpse_effect_EXPEREMENTAL")
            gore_mod_Add_label(content,"Replace the NPC model when it dies from a burn.",true)
            gore_mod_Add_CheckBox(content,"dissolve efect","goremod_dissolve_efect_EXPEREMENTAL")
            gore_mod_Add_label(content,"When the NPC dissolves, it turns to dust.",true)
            gore_mod_Add_CheckBox(content,"Acid efect","goremod_acid_efect_EXPEREMENTAL")
            gore_mod_Add_label(content,"When the NPC dissolves, it turns to skeleton.",true)
            gore_mod_Add_CheckBox(content,"sawblade slice","goremod_sawblade_slice_EXPEREMENTAL")
            gore_mod_Add_label(content,"just like zombies.",true)
            gore_mod_Add_CheckBox(content,"Ragdoll Death V2 compatibility bridge enable","goremod_rd_bridge_enable")
            gore_mod_Add_label(content,"add suport for Ragdoll Death V2",true)
            gore_mod_Add_label(content,"This option will conflict with the Enhanced Death Animations Addon" )
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
            gore_mod_Add_CheckBox(content,"Blood effect","goremod_blood")
            gore_mod_Add_label(content,"Disable blood effect.",true)
            gore_mod_Add_CheckBox(content,"Blood spawn decal","goremod_blood_do_decal")
            gore_mod_Add_label(content,"Disable blood decal paint.",true)
            gore_mod_Add_slider(content,"Duration Multiplier","goremod_blood_stream_reps_multiplier",0.1,10 )
            gore_mod_Add_label(content,"How long blood streams last (1 = normal, 10 = very long)",true )
            --gore_mod_Add_slider(content,"Squirt sound volume","goremod_squirt_sound_volume",0,2)
            gore_mod_Add_slider(content,"Blood Spurt Frequency","goremod_stream_density",0.1,5)
            gore_mod_Add_label(content,"How often blood spurts out (0.1 = very frequent spurts, 5 = slow/rare spurts)",true )
            gore_mod_Add_slider(content,"Blood Force","goremod_stream_force",0.1,5)
            gore_mod_Add_label(content,"How far blood shoots out (0.1 = weak, 5 = powerful)",true )
            gore_mod_Add_slider(content,"Blood Stream Size","goremod_stream_size",0.1,10 )
            gore_mod_Add_label(content,"Size multiplier for blood particles (0.1 = tiny, 10 = huge)",true )
            gore_mod_Add_slider(content,"Spread Angle (FOV)","goremod_stream_spread",0,100,true )
            gore_mod_Add_label(content,"Spray cone angle in degrees (0 = straight, 100 = wide)",true )

            gore_mod_Add_slider(content,"Blood sound volume","goremod_blood_sound_volume",0,2)
            gore_mod_Add_label(content,"Volume for blood impact sounds",true )
        end
    end

    local pages = {
        "General",
        "Ragdoll Option",
        "Gib Option",
        "Blood Option",
        "NPC Blacklist",
        "experimental",

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
concommand.Add("goremod_OpenConfirmMenu", function()
	GoremodOpenConfirmMenu()
end)

hook.Add( "PopulateToolMenu", "Add_Goremod_Settings", function()
    spawnmenu.AddToolMenuOption("Options", "Gore", "Lambda Gore 2", "Lambda Gore 2", "", "", function(panel)
        panel:Clear()

        local OpenConfirmMenu = vgui.Create("DButton", panel)
        OpenConfirmMenu:Dock(TOP)
        OpenConfirmMenu:DockMargin(20,20,20,0)
        OpenConfirmMenu:SetTall(40)
        OpenConfirmMenu:SetText("")
        OpenConfirmMenu.Paint = function(self, w, h)
            local col = OpenConfirmMenu:IsHovered() and Color(70,120,255) or Color(56,56,56)
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText("OpenConfirmMenu", "smash", 15, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        OpenConfirmMenu.DoClick = function()
            RunConsoleCommand('goremod_OpenConfirmMenu')
            surface.PlaySound("garrysmod/save_load"..math.random(1,3)..".wav")
        end
	end )
end )

list.Set("DesktopWindows", "goremodconfig", {
	title = "goremodconfig",
	icon = "gui/effects/bloodimpact.png",
	init = function(icon, window)
        if IsValid(window) then 
            window:Remove() 
        end
        RunConsoleCommand('goremod_OpenConfirmMenu')
    end
})

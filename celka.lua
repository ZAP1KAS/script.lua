--self leak

local libs = {
    pui = require 'gamesense/pui',
    ffi_lib = require 'ffi',
    vector_lib = require 'vector',
    aa_func_lib = require 'gamesense/antiaim_funcs',
    base64_lib = require 'gamesense/base64',
    clipboard_lib = require 'gamesense/clipboard',
    c_entity = require 'gamesense/entity',
}

local ref = {
    aimbot = ui.reference('RAGE', 'Aimbot', 'Enabled'),
    enabled = ui.reference('AA', 'Anti-aimbot angles', 'Enabled'),
    yawbase = ui.reference('AA', 'Anti-aimbot angles', 'Yaw base'),
    fsbodyyaw = ui.reference('AA', 'anti-aimbot angles', 'Freestanding body yaw'),
    edgeyaw = ui.reference('AA', 'Anti-aimbot angles', 'Edge yaw'),
    fakeduck = ui.reference('RAGE', 'Other', 'Duck peek assist'),
    forcebaim = ui.reference('RAGE', 'Aimbot', 'Force body aim'),
    safepoint = ui.reference('RAGE', 'Aimbot', 'Force safe point'),
    roll = { ui.reference('AA', 'Anti-aimbot angles', 'Roll') },
    clantag = ui.reference('Misc', 'Miscellaneous', 'Clan tag spammer'),
    ping_spike = {ui.reference('Misc', 'Miscellaneous', 'Ping spike')},
    console_out = ui.reference('Misc', 'Miscellaneous', 'Draw console output'),
    autopeek = {ui.reference('RAGE', 'Other', 'Quick peek assist')},

    pitch = { ui.reference('AA', 'Anti-aimbot angles', 'pitch'), },
    rage = { ui.reference('RAGE', 'Aimbot', 'Enabled') },
    yaw = { ui.reference('AA', 'Anti-aimbot angles', 'Yaw') }, 
    yawjitter = { ui.reference('AA', 'Anti-aimbot angles', 'Yaw jitter') },
    bodyyaw = { ui.reference('AA', 'Anti-aimbot angles', 'Body yaw') },
    freestand = { ui.reference('AA', 'Anti-aimbot angles', 'Freestanding') },
    slow = { ui.reference('AA', 'Other', 'Slow motion') },
    leg_movement = ui.reference('AA', 'Other', 'Leg movement'),
    os = { ui.reference('AA', 'Other', 'On shot anti-aim') },
    dt = { ui.reference('RAGE', 'Aimbot', 'Double tap') },
    dt_fakelag_limit = ui.reference('RAGE', 'Aimbot', 'Double tap fake lag limit'),
    fakelag_limit = ui.reference('RAGE', 'Aimbot', 'Double tap fake lag limit'),
    minimum_damage_override = { ui.reference('RAGE', 'Aimbot', 'Minimum damage override')},

    flEnabled = { ui.reference('AA', 'Fake lag', 'Enabled')},
    flLimit = ui.reference('AA', 'Fake lag', 'Limit'),
    flVariance = ui.reference('AA', 'Fake lag', 'Variance'),
    flAmount = ui.reference('AA', 'Fake lag', 'Amount'),

    gsColor = ui.reference('Misc', 'Settings', 'Menu color'),
}

local ru_trashtalk = {
    {'съебал нахуй, шнырь большедырый', 'легкий хуесос'},
    {'если бы кизару увидел твой ник он бы спросил что это за таджик'},
    {'все что ты делал на хвх это легендарно сосал'},
    {'иди прикупи Nyctophobia а то падаешь', 'ссылку кинуть?'},
    {'хпахпахахахаха', 'ебать я тебе запромежбулил'},
    {'твоя сука носит спид моя сука харли квин'},
    {'бай Nyctophobia уебище', 'иди прикупи'},
    {'N Y C T O P H O B I A', 'лучшая луашка на скит'},
    {'1.', 'ебаный уебок'},
    {'1', 'шлюха'},
    {'t1', 'пидорас ебаный'},
    {'е1'},
    {'пошла нахуй пешка членоедка ебаная'},
    {'Подборка лучших шуток про жирную мамашу | Пикабу'},
    {'ахахахаха ебать ты упал хуесосище'},
    {'1 + 1 = я твою мать ебал'},
    {'целуй мои ноги'},
    {'Я выключаю твое сознание, бомж ебучий.'},
    {'Спасибо за кил, чудище.'},
    {'1p'},
    {'Упал?', 'Привыкай.'},
    {'[f[f[f[f]]]]', ' ебал твою мать'},
    {'1 хуесос'},
    {'N Y C T O P H O B I A или ничего'},
    {'пошла нахуй шалава ебаная'},
    {'твоя мамочка ударилась темечком об мой стол от такого кила'},
    {'1ю'},
    {'ну ты и хуесос'},
    {'N Y C T O P H O B I A'},
    {'твои джитеры жирнее сраки твоей мамаши'},
}

local ru_deathtalk = {
    {'gs09gfddgf90-fgds0-', 'как же ьебе повезло', 'сын шлюхи'},
    {'T<FYSQ CSY IK>{F}', 'тфу нахуй'},
    {'фу нахуй'},
    {'Игрок.', 'сразу бля видно'},
    {'Это был подарок.', 'Следующий раунд - твой конец.'},
    {'Моя смерть — временная.', 'Твоя бесполезность — вечна.'},
    {'Смотри', 'не обоссысь от своей удачи'},
    {'Гордись собой', 'больше такого не повториться.'},
    {'Ты настолько нищий, что даже мой труп лучше играет.'},
    {'куда ты меня в заусенец трекнул уебище'},
    {'ЕБАТЬСЯ РЫЛОМ В ЛАМИНАТ ТЫ МЕНЯ ТРЕКНУЛ'},
    {'Дрочиться полинтусом об ляжку', 'куда тебе'},
}

local delay = 0.03

local primary_weapons = {
	{name='-', command=""},
	{name='AWP', command="buy awp; "},
	{name='Auto-Sniper', command="buy scar20; buy g3sg1; "},
	{name='Scout', command="buy ssg08; "},
}

local secondary_weapons = {
	{name='-', command=""},
	{name='Revolver/Deagle', command="buy deagle; "},
	{name='Berettas', command="buy elite; "},
	{name='Five-seneN/Tec9/CZ', command="buy fn57; "}
}

local gear_weapons = {
	{name='Kevlar', command="buy vest; "},
	{name='Helmet', command="buy vesthelm; "},
	{name='Defuse Kit', command="buy defuser; "},
	{name='Grenade', command="buy hegrenade; "},
	{name='Molotov', command="buy incgrenade; "},
	{name='Smoke', command="buy smokegrenade; "},
	{name='Flashbang x2', command="buy flashbang; "},
	{name='Taser', command="buy taser; "},
}

local table_concat = table.concat
local table_insert = table.insert
local to_number = tonumber
local math_floor = math.floor
local table_remove = table.remove
local string_format = string.format

local function get_names(table)
	local names = {}
	for i=1, #table do
		table_insert(names, table[i]["name"])
	end
	return names
end

local function get_command(table, name)
	for i=1, #table do
		if table[i]["name"] == name then
			return table[i]["command"]
		end
	end
end

local name = ''
local update_info = '11/05/25'

if _USER_NAME == nil then
    name = 'DEVELOPER'
else
    name = _USER_NAME
end

local build = 'DEV'
local brand = [[

]]

client.exec('clear')
client.color_log(200, 180, 100, ' ')
client.color_log(200, 180, 100, brand)
client.color_log(200, 180, 100, ' ')
client.color_log(200, 180, 100, 'Welcome to NYCTOPHOBIA, ', name, '! Your branch is '..build)

states = {'Shared', 'Standing', 'Running', 'Walking' , 'Aerobic', 'Aerobic+', 'Ducking', 'Sneaking'}

groups = {
    group_aa = libs.pui.group('AA', 'Anti-aimbot angles'),
    group_fl = libs.pui.group('AA', 'Fake lag'),
    group_other = libs.pui.group('AA', 'Other'),
}

local rgba_to_hex = function(b, c, d, e)
    return string.format('%02x%02x%02x%02x', b, c, d, e)
end

local function get_skeet_color()
    local r, g, b, a = ui.get(ref.gsColor)
    done_color = rgba_to_hex(r,g,b,a)
    return done_color
end

libs.pui.macros.dot = '\a'..get_skeet_color()..'•  \r'

--region ui

local lua_ui = {
    main = {
        main_checkbox = groups.group_fl:checkbox('\v•\a'..get_skeet_color()..'  Enable NYCTOPHOBIA'),
        tab_selectable = groups.group_fl:combobox('\v•\r  Tab Selectable', {'Ragebot', 'Anti-Aims', 'Visuals', 'Misc'}),
        label1 = groups.group_fl:label('\v•\r  Welcome to \a'..get_skeet_color()..'NYCTOPHOBIA\r '..build..', '..name),
        label2 = groups.group_fl:label('\v•\r  Last update: '..update_info),
    },
    ragebot = {
        ragebot_label = groups.group_aa:label('\a'..get_skeet_color()..'⋆｡°✩ Ragebot Tab: ✩°｡⋆'),
        ragebot_label2 = groups.group_aa:label(' '),
        defensive_fix = groups.group_aa:checkbox('\v•\r  Defensive Fix'),
        ragebot_label6 = groups.group_aa:label(' '),
        hideshot_fix = groups.group_aa:checkbox('\v•\r  Hide-Shots Fix'),
        ragebot_label7 = groups.group_aa:label(' '),
        unsafe_charge = groups.group_aa:checkbox('\v•\r  Allow Unsafe Recharge In Air'),
        ragebot_label3 = groups.group_aa:label(' '),
        airlag = groups.group_aa:checkbox('\v•\r  Air Lag'),
        ragebot_label8 = groups.group_aa:label(' '),
        auto_tp = groups.group_aa:checkbox('\v•\r  Automatic Teleport'),
        auto_tp_key = groups.group_aa:hotkey('\v•\r  Automatic Teleport', true),
        ragebot_label9 = groups.group_aa:label(' '),
        resolver = groups.group_aa:checkbox('\v•\r  NyC Resolver [\aEC3F3FFFdebug\r]'),
        resolver_type = groups.group_aa:combobox('\v•\r  Type', {'Default', '???'}),
        ragebot_label4 = groups.group_aa:label(' '),
        prediction_system = groups.group_aa:checkbox('\v•\r  NyC Prediction System [\aEC3F3FFFdebug\r]'),
        predict_label = groups.group_aa:label('\aEC3F3FFF USE THIS IF YOUR PING < 40'),
        predict_type = groups.group_aa:combobox('\v•\r  Type', {'Default', 'Oh god please no'}),
        predict_label2 = groups.group_aa:label('\aEC3F3FFF use that mode if your ping < 20'),
        predict_weapons = groups.group_aa:multiselect('\v•\r  Weapons', {'AWP', 'Auto', 'Scout'}),
        predict_conditions = groups.group_aa:multiselect('\v•\r  Conditions', {'Standing', 'Walking', 'Ducking', 'Sneaking'}),
        predict_bind = groups.group_aa:hotkey('\v•\r  Bind'),
        ragebot_label5 = groups.group_aa:label(' '),
        airstop = groups.group_aa:hotkey('\v•\r  Air Quick stop'),
    },
    antiaim_misc = {
        aa_select = groups.group_aa:combobox('\v•\r  Select Tab', {'Main', 'Builder'}),
        aa_label1 = groups.group_aa:label(' '),
        aa_label = groups.group_aa:label('\a'..get_skeet_color()..'⋆｡°✩ Anti-Aims Tab: ✩°｡⋆'),
        aa_label2 = groups.group_aa:label(' '),
        yaw_base = groups.group_aa:combobox('\v•\r  Yaw Base', {'At Targets', 'Local View'}),
        aa_label3 = groups.group_aa:label(' '),
        addons = groups.group_aa:multiselect('\v•\r  Tweeks', {'Warmup Anti-Aim', 'Anti Backstab', 'Safe Head', 'Edge Yaw on FD'}),
        aa_label4 = groups.group_aa:label(' '),
        safe_head = groups.group_aa:multiselect('\v•\r  Safe Head', {'Air+C Knife', 'Air+C Zeus', 'High Distance', 'Higher than enemy'}),
        disable_defensive_on_safe = groups.group_aa:checkbox('\v•\r  Disable Defensive AA On Safe Head'),
        aa_label5 = groups.group_aa:label(' '),
        defensive_flick = groups.group_aa:checkbox('\v•\r  '..get_skeet_color()..'Defensive \rFlick Exploit'),
        defensive_flick_type = groups.group_aa:combobox('\v•\r  '..get_skeet_color()..'Defensive \rFlick Type', {'Left', 'Right', 'Custom'}),
        defensive_flick_ticks = groups.group_aa:slider('\v•\r  Ticks', 1, 10, 1, 1),
        defensive_flick_value = groups.group_aa:slider('\v•\r  Value', -110, 110, 0, 1),
        defensive_flick_key = groups.group_aa:hotkey('\v•\r  Flick Exploit Bind'),
        aa_label6 = groups.group_aa:label(' '),
        fake_lags = groups.group_aa:checkbox('\v•\r  Fake-Lags'),
        fake_lags_amount = groups.group_aa:combobox('\v•\r  Type', {'Maximum', 'Dynamic', 'Fluctuate', 'Nyctophobia'}),
        fake_lags_limit = groups.group_aa:slider('\v•\r  Limit', 1, 15, 1),
        fake_lags_variance = groups.group_aa:slider('\v•\r  Variance', 0, 100, 0),
        aa_label7 = groups.group_aa:label(' '),
        key_left = groups.group_aa:hotkey('\v•\r  Manual Left'),
        key_right = groups.group_aa:hotkey('\v•\r  Manual Right'),
        key_forward = groups.group_aa:hotkey('\v•\r  Manual Forward'),

        manuals_manipulations = groups.group_aa:multiselect('\v•\r  Manual Manipulations', {'Static', 'E-Peek'}),

        key_freestand = groups.group_aa:hotkey('\v•\r  Freestanding'),
    },
    other = {
        other_label = groups.group_aa:label('\a'..get_skeet_color()..'⋆｡°✩ Misc Tab: ✩°｡⋆'),
        other2_label = groups.group_aa:label('\a'..get_skeet_color()..'⋆｡°✩ Visuals Tab: ✩°｡⋆'),
        tab_label = groups.group_aa:label(' '),

        cross_ind = groups.group_aa:checkbox('\v•\r  Crosshair Indicators', {255, 160, 160}),
        cross_ind_gradient = groups.group_aa:checkbox('\v•\r  Gradient'),
        cross_ind_label = groups.group_aa:label(' '),
        manual_indicators = groups.group_aa:checkbox('\v•\r  Manual Indicators', {255, 160, 160}),
        manual_indicators_velocity = groups.group_aa:checkbox('\v•\r  Velocity Based'),
        manual_indicators_type = groups.group_aa:combobox('\v•\r  Manual Indicators Type', {'Modern', 'Classic', 'Meme'}),
        manual_indicators_label = groups.group_aa:label(' '),
        velocity_warning = groups.group_aa:checkbox('\v•\r  Velocity Warning', {255, 160, 160}),
        velocity_warning_label = groups.group_aa:label(' '),
        defensive_indicator = groups.group_aa:checkbox('\v•\r  Defensive Indicator', {255, 160, 160}),
        defensive_indicator_label = groups.group_aa:label(' '),
        zeus_warning = groups.group_aa:checkbox('\v•\r  Better Zeus Warning'),
        zeus_warning_label = groups.group_aa:label(' '),
        hitmarker = groups.group_aa:checkbox('\v•\r  Hitmarker', {255, 160, 160}),
        hitmarker_type = groups.group_aa:combobox('\v•\r  Type', {'Plus', 'Circle'}),
        hitmarker_indicators_label = groups.group_aa:label(' '),
        branded_watermark_pos = groups.group_aa:combobox('\v•\r  Branded Watermark', {'Bottom', 'Left', 'Right'}, {255, 160, 160}),

        killsay = groups.group_aa:checkbox('\v•\r  TrashTalk'),
        killsay_label = groups.group_aa:label(' '),
        clan_tag = groups.group_aa:checkbox('\v•\r  Clan-Tag Spammer'),
        clan_tag_label = groups.group_aa:label(' '),
        fast_ladder = groups.group_aa:checkbox('\v•\r  Fast Ladder'),
        aimbot_logs_label = groups.group_aa:label(' '),
        aimbot_logs = groups.group_aa:checkbox('\v•\r  Aimbot Logs'),
        log_type = groups.group_aa:multiselect('\v•\r  Log Types', {'Hit', 'Miss','Center' }),
        aimbot_logs_label2 = groups.group_aa:label(' '),
        animation = groups.group_aa:checkbox('\v•\r  Animation Breaker'),
        animation_ground = groups.group_aa:combobox('\v•\r  Ground', {'Off', 'Static', 'Walking', 'Droch', 'Fipp'}),
        animation_air = groups.group_aa:combobox('\v•\r  Air', {'Off', 'Static', 'Droch', 'Fipp'}),
        animation_label = groups.group_aa:label(' '),
        aspectratio = groups.group_aa:checkbox('\v•\r  Aspect Ratio'),
        aspectratio_value = groups.group_aa:slider('\v•\r  Aspect Ratio Value', 00, 200, 133),
        aspectratio_label = groups.group_aa:label(' '),
        third_person = groups.group_aa:checkbox('\v•\r  Thirdperson Distance'),
        third_person_value = groups.group_aa:slider('\v•\r  Thirdperson Distance Value', 25, 300, 150),
        third_person_label = groups.group_aa:label(' '),
        filter_console = groups.group_aa:checkbox('\v•\r  Filter Console'),
        filter_console_label = groups.group_aa:label(' '),
        fps_boost = groups.group_aa:checkbox('\v•  \aB4B464FFFPS Boost'),
        buy_bot_label = groups.group_aa:label(' '),
        buy_bot = groups.group_aa:checkbox('\v•\r  Buybot'),
        buy_bot_primary = groups.group_aa:combobox('\v•\r  Primary Weapon', get_names(primary_weapons)),
        buy_bot_secondary = groups.group_aa:combobox('\v•\r  Secondary Weapon', get_names(secondary_weapons)),
        buy_bot_other = groups.group_aa:multiselect('\v•\r  Other', get_names(gear_weapons)),
    },
    builder_label = groups.group_aa:label('\a'..get_skeet_color()..'⋆｡°✩ Builder: ✩°｡⋆'),
    condition = groups.group_aa:combobox('\v•\r  States', states),
}

--region builder ui

local antiaim_system = {}

for i=1, #states do
    antiaim_system[i] = {
    enable = groups.group_aa:checkbox('\v•\r  Enable '..states[i]),
    pitch_type = groups.group_aa:combobox('\v•\r  Pitch Type', {'Down', 'Up', 'Custom'}),
    pitch_value = groups.group_aa:slider('\v•\r  Pitch Value', -89, 89, 0, true, '°', 1),
    yaw_type = groups.group_aa:combobox('\v•\r  Yaw Type', {'Static', 'L & R', 'Delay'}),
    yaw_static = groups.group_aa:slider('\n\n\n\n\n\n\n\n\n', -180, 180, 0, true, '°', 1),
    yaw_left = groups.group_aa:slider('\n\n\n\n\n\n\n\n\n\n', -180, 180, 0, true, '°', 1),
    yaw_right = groups.group_aa:slider('\n\n\n\n\n\n\n\n\n\n\n', -180, 180, 0, true, '°', 1),
    yaw_random = groups.group_aa:slider('\v•\r  Randomization', 0, 100, 0, true, '%', 1),
    yaw_delay = groups.group_aa:slider('\v•\r  Delay Ticks', 1, 10, 4, true, 't', 1),
    yaw_delay_random = groups.group_aa:checkbox('\v•\r  Delay Ticks Randomization'),
    mod_type = groups.group_aa:combobox('\v•\r  Yaw Modifier', {'Off', 'Offset', 'Center', 'Random', 'Skitter', '3-Way', '5-Way', 'L & R', 'Delay Center'}),
    mod_dm = groups.group_aa:slider('\n', -180, 180, 0, true, '°', 1),
    mod_dm_left = groups.group_aa:slider('\n\n', -180, 180, 0, true, '°', 1),
    mod_dm_right = groups.group_aa:slider('\n\n\n', -180, 180, 0, true, '°', 1),
    jitter_delay = groups.group_aa:slider('\v•\r  Yaw Modifier Delay Ticks', 1, 10, 4, true, 't', 1),
    yaw_modifer_delay_random = groups.group_aa:checkbox('\v•\r  Yaw Modifier Delay Ticks Randomization'),
    gs_body_yaw_type = groups.group_aa:combobox('\v•\r  Body Yaw', {'Off', 'Opposite', 'Jitter', 'Static'}),
    gs_body_slider = groups.group_aa:slider('\n\n\n\n', -180, 180, 0, true, '°', 1),

    defensive = groups.group_aa:checkbox('\v•\r  Defensive Anti-Aim'),
    defesive_aa_type = groups.group_aa:combobox('\v•\r  Defensive Type', {'Off', 'On Peek', 'Force'}),
    defesive_aa_mode = groups.group_aa:combobox('\v•\r  Defensive Mode', {'Builder', 'Mode'}),
    defesive_aa_mode_type = groups.group_aa:combobox('\v•\r  Defensive Mode Type', {'Off', 'Sinus', 'Ping Based Sinus'}),
    defensive_aa_sinus_yaw = groups.group_aa:slider('\v•\r  Sinus Yaw Value', -180, 180, 0, true, '°', 1),
    defensive_aa_sinus_speed = groups.group_aa:slider('\v•\r  Sinus Speed', 1, 10, 0, true, 'MC', 1),
    defensive_aa_sinus_amplitude = groups.group_aa:slider('\v•\r  Sinus Amplitude', 0, 180, 0, true, '°', 1),
    
    defensive_pitch = groups.group_aa:combobox('\v•\r  Defensive Pitch', {'Off', 'Up', 'Down', 'Half Up', 'Half Down', 'Meta', 'Random', 'Jitter', 'Delay', 'Spin', 'Custom', 'Kazakh'}), --спины сделать
    defensive_pitch_delay = groups.group_aa:slider('\v•\r  Defensive Pitch Delay', 1, 10, 4, true, 't', 1),
    defensive_pitch_value = groups.group_aa:slider('\n\n\n\n\n\n\n', -89, 89, 0, true, '°', 1),
    defensive_pitch_value_2 = groups.group_aa:slider('\n\n\n\n\n\n\n\n', -89, 89, 0, true, '°', 1),
    defensive_pitch_speed = groups.group_aa:slider('\v•\r  Defensive Pitch Speed', 1, 100, 0, true, 'MC', 1),
    defensive_yaw = groups.group_aa:combobox('\v•\r  Defensive Yaw', {'Off', '180', 'Spin', 'Jitter', 'Distortion', 'Sideways', 'Meta', 'Random', 'Delay', 'Custom', 'Secret'}),
    defensive_yaw_delay = groups.group_aa:slider('\v•\r  Defensive Yaw Delay', 1, 10, 4, true, 't', 1),
    defensive_yaw_value_1 = groups.group_aa:slider('\n\n\n\n\n', -180, 180, 0, true, '°', 1),
    defensive_yaw_value_2 = groups.group_aa:slider('\n\n\n\n\n\n', -180, 180, 0, true, '°', 1),
    defensive_yaw_speed = groups.group_aa:slider('\v•\r  Defensive Yaw Speed', 1, 100, 0, true, 'MC', 1),
    }
end

--region dependence

enabled = lua_ui.main.main_checkbox
ragebot_tab = {lua_ui.main.tab_selectable, 'Ragebot'}
aa_tab = {lua_ui.main.tab_selectable, 'Anti-Aims'}
main_aa_tab = {lua_ui.antiaim_misc.aa_select, 'Main'}
builder_aa_tab = {lua_ui.antiaim_misc.aa_select, 'Builder'}
other_tab = {lua_ui.main.tab_selectable, 'Misc'}
visuals_tab = {lua_ui.main.tab_selectable, 'Visuals'}

otherandvisuals_tab = {lua_ui.main.tab_selectable, 'Misc', 'Visuals'}
--main dependence
lua_ui.main.tab_selectable:depend(enabled)
lua_ui.main.label1:depend(enabled)
lua_ui.main.label2:depend(enabled)
--ragebot dependence
lua_ui.ragebot.ragebot_label:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label2:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label3:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label4:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label5:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label6:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label7:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label8:depend(enabled, ragebot_tab)
lua_ui.ragebot.ragebot_label9:depend(enabled, ragebot_tab)
lua_ui.ragebot.defensive_fix:depend(enabled, ragebot_tab)
lua_ui.ragebot.hideshot_fix:depend(enabled, ragebot_tab)
lua_ui.ragebot.unsafe_charge:depend(enabled, ragebot_tab)
lua_ui.ragebot.airlag:depend(enabled, ragebot_tab)
lua_ui.ragebot.auto_tp:depend(enabled, ragebot_tab)
lua_ui.ragebot.auto_tp_key:depend(enabled, ragebot_tab, lua_ui.ragebot.auto_tp)
lua_ui.ragebot.resolver:depend(enabled, ragebot_tab)
lua_ui.ragebot.resolver_type:depend(enabled, ragebot_tab, lua_ui.ragebot.resolver)
lua_ui.ragebot.prediction_system:depend(enabled, ragebot_tab)
lua_ui.ragebot.predict_label:depend(enabled, ragebot_tab, lua_ui.ragebot.prediction_system)
lua_ui.ragebot.predict_type:depend(enabled, ragebot_tab, lua_ui.ragebot.prediction_system)
lua_ui.ragebot.predict_label2:depend(enabled, ragebot_tab, lua_ui.ragebot.prediction_system, {lua_ui.ragebot.predict_type, 'Oh god please no'})
lua_ui.ragebot.predict_weapons:depend(enabled, ragebot_tab, lua_ui.ragebot.prediction_system)
lua_ui.ragebot.predict_conditions:depend(enabled, ragebot_tab, lua_ui.ragebot.prediction_system)
lua_ui.ragebot.predict_bind:depend(enabled, ragebot_tab, lua_ui.ragebot.prediction_system)
lua_ui.ragebot.airstop:depend(enabled, ragebot_tab)
--aa dependence
lua_ui.antiaim_misc.aa_select:depend(enabled, aa_tab)
lua_ui.antiaim_misc.aa_label1:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.aa_label:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.aa_label3:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.aa_label4:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.aa_label5:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.aa_label6:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.aa_label7:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.yaw_base:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.addons:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.safe_head:depend(enabled, aa_tab, main_aa_tab, {lua_ui.antiaim_misc.addons, 'Safe Head'})
lua_ui.antiaim_misc.disable_defensive_on_safe:depend(enabled, aa_tab, main_aa_tab, {lua_ui.antiaim_misc.addons, 'Safe Head'})
lua_ui.antiaim_misc.defensive_flick:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.defensive_flick_type:depend(enabled, aa_tab, lua_ui.antiaim_misc.defensive_flick, main_aa_tab)
lua_ui.antiaim_misc.defensive_flick_ticks:depend(enabled, aa_tab, lua_ui.antiaim_misc.defensive_flick, main_aa_tab)
lua_ui.antiaim_misc.defensive_flick_value:depend(enabled, aa_tab, lua_ui.antiaim_misc.defensive_flick, main_aa_tab, {lua_ui.antiaim_misc.defensive_flick_type, 'Custom'})
lua_ui.antiaim_misc.defensive_flick_key:depend(enabled, aa_tab, lua_ui.antiaim_misc.defensive_flick, main_aa_tab)
lua_ui.antiaim_misc.fake_lags:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.fake_lags_amount:depend(enabled, aa_tab, lua_ui.antiaim_misc.fake_lags, main_aa_tab)
lua_ui.antiaim_misc.fake_lags_limit:depend(enabled, aa_tab, lua_ui.antiaim_misc.fake_lags, main_aa_tab, {lua_ui.antiaim_misc.fake_lags_amount, 'Maximum', 'Dynamic', 'Fluctuate'})
lua_ui.antiaim_misc.fake_lags_variance:depend(enabled, aa_tab, lua_ui.antiaim_misc.fake_lags, main_aa_tab, {lua_ui.antiaim_misc.fake_lags_amount, 'Maximum', 'Dynamic', 'Fluctuate'})
lua_ui.antiaim_misc.key_left:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.key_right:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.key_forward:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.key_freestand:depend(enabled, aa_tab, main_aa_tab)
lua_ui.antiaim_misc.manuals_manipulations:depend(enabled, aa_tab, main_aa_tab)
--other dependence
lua_ui.other.other2_label:depend(enabled, visuals_tab)
lua_ui.other.other_label:depend(enabled, other_tab)
lua_ui.other.tab_label:depend(enabled, otherandvisuals_tab)
lua_ui.other.cross_ind:depend(enabled, visuals_tab)
lua_ui.other.cross_ind_gradient:depend(enabled, visuals_tab, lua_ui.other.cross_ind)
lua_ui.other.cross_ind_label:depend(enabled, visuals_tab)
lua_ui.other.manual_indicators:depend(enabled, visuals_tab)
lua_ui.other.manual_indicators_type:depend(enabled, visuals_tab, lua_ui.other.manual_indicators)
lua_ui.other.manual_indicators_velocity:depend(enabled, visuals_tab, lua_ui.other.manual_indicators)
lua_ui.other.manual_indicators_label:depend(enabled, visuals_tab)
lua_ui.other.velocity_warning:depend(enabled, visuals_tab)
lua_ui.other.defensive_indicator:depend(enabled, visuals_tab)
lua_ui.other.velocity_warning_label:depend(enabled, visuals_tab)
lua_ui.other.defensive_indicator_label:depend(enabled, visuals_tab)
lua_ui.other.zeus_warning:depend(enabled, visuals_tab)
lua_ui.other.zeus_warning_label:depend(enabled, visuals_tab)
lua_ui.other.hitmarker:depend(enabled, visuals_tab)
lua_ui.other.hitmarker_type:depend(enabled, visuals_tab, lua_ui.other.hitmarker)
lua_ui.other.hitmarker_indicators_label:depend(enabled, visuals_tab)
lua_ui.other.branded_watermark_pos:depend(enabled, visuals_tab)
lua_ui.other.killsay:depend(enabled, other_tab)
lua_ui.other.killsay_label:depend(enabled, other_tab)
lua_ui.other.clan_tag:depend(enabled, other_tab)
lua_ui.other.clan_tag_label:depend(enabled, other_tab)
lua_ui.other.fast_ladder:depend(enabled, other_tab)
lua_ui.other.aimbot_logs_label:depend(enabled, other_tab)
lua_ui.other.aimbot_logs:depend(enabled, other_tab)
lua_ui.other.log_type:depend(enabled, other_tab, lua_ui.other.aimbot_logs)
lua_ui.other.aimbot_logs_label2:depend(enabled, other_tab)

lua_ui.other.animation:depend(enabled, other_tab)
lua_ui.other.animation_ground:depend(enabled, other_tab, lua_ui.other.animation)
lua_ui.other.animation_air:depend(enabled, other_tab, lua_ui.other.animation)
lua_ui.other.animation_label:depend(enabled, other_tab)

lua_ui.other.aspectratio:depend(enabled, other_tab)
lua_ui.other.aspectratio_value:depend(enabled, other_tab, lua_ui.other.aspectratio)
lua_ui.other.aspectratio_label:depend(enabled, other_tab)

lua_ui.other.third_person:depend(enabled, other_tab)
lua_ui.other.third_person_value:depend(enabled, other_tab, lua_ui.other.third_person)
lua_ui.other.third_person_label:depend(enabled, other_tab)
lua_ui.other.filter_console:depend(enabled, other_tab)
lua_ui.other.filter_console_label:depend(enabled, other_tab)
lua_ui.other.fps_boost:depend(enabled, other_tab)
lua_ui.other.buy_bot_label:depend(enabled, other_tab)
lua_ui.other.buy_bot:depend(enabled, other_tab)
lua_ui.other.buy_bot_primary:depend(enabled, other_tab, lua_ui.other.buy_bot)
lua_ui.other.buy_bot_secondary:depend(enabled, other_tab, lua_ui.other.buy_bot)
lua_ui.other.buy_bot_other:depend(enabled, other_tab, lua_ui.other.buy_bot)

--builder dependence
lua_ui.condition:depend(enabled, builder_aa_tab, aa_tab)
lua_ui.builder_label:depend(enabled, builder_aa_tab, aa_tab)

for i=1, #states do
    local cond_check = {lua_ui.condition, function() return (i ~= 1) end}
    local tab_cond = {lua_ui.condition, states[i]}
    local cnd_en = {antiaim_system[i].enable, function() if (i == 1) then return true else return antiaim_system[i].enable:get() end end}
    local aa_tab = {lua_ui.main.tab_selectable, 'Anti-Aims'}
    local static = {antiaim_system[i].yaw_type, 'Static'}
    local jitter = {antiaim_system[i].yaw_type, 'L & R', 'Delay'}
    local jit_ch = {antiaim_system[i].mod_type, function() return antiaim_system[i].mod_type:get() ~= 'Off' end}
    local jit_lr = {antiaim_system[i].mod_type, 'L & R', 'Delay Center', 'Random'}
    local jit_static = {antiaim_system[i].mod_type, 'Center', 'Offset', '3-Way', '5-Way', 'Skitter'}
    local def_jit_ch = {antiaim_system[i].def_mod_type, function() return antiaim_system[i].def_mod_type:get() ~= 'Off' end}
    local def_ch = {antiaim_system[i].defensive, true}
    local body_ch = {antiaim_system[i].gs_body_yaw_type, function() return antiaim_system[i].gs_body_yaw_type:get() ~= 'Off' end}
    local def_body_ch = {antiaim_system[i].def_body_yaw_type, function() return antiaim_system[i].def_body_yaw_type:get() ~= 'Off' end}
    local delay_ch = {antiaim_system[i].yaw_type, 'Delay'}
    local yaw_ch = {antiaim_system[i].defensive_yaw, 'Spin'}

    local pitch_ch = {antiaim_system[i].defensive_pitch, 'Custom', 'Jitter', 'Delay', 'Spin'}

    antiaim_system[i].enable:depend(cond_check, tab_cond, aa_tab, builder_aa_tab, enabled)
    antiaim_system[i].pitch_type:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled)
    antiaim_system[i].pitch_value:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, {antiaim_system[i].pitch_type, 'Custom'})
    antiaim_system[i].yaw_type:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled)
    antiaim_system[i].yaw_delay:depend(cnd_en, tab_cond, aa_tab, delay_ch, builder_aa_tab, enabled)
    antiaim_system[i].yaw_static:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, static)
    antiaim_system[i].yaw_left:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, jitter)
    antiaim_system[i].yaw_right:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, jitter)
    antiaim_system[i].yaw_random:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, jitter)
    antiaim_system[i].yaw_delay_random:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, {antiaim_system[i].yaw_type, 'Delay'})
    antiaim_system[i].mod_type:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled)

    antiaim_system[i].mod_dm:depend(cnd_en, tab_cond, aa_tab, jit_ch, builder_aa_tab, jit_static, enabled)
    antiaim_system[i].mod_dm_left:depend(cnd_en, tab_cond, aa_tab, jit_ch, builder_aa_tab, jit_lr, enabled)
    antiaim_system[i].mod_dm_right:depend(cnd_en, tab_cond, aa_tab, jit_ch, builder_aa_tab, jit_lr, enabled)
    antiaim_system[i].jitter_delay:depend(cnd_en, tab_cond, aa_tab, jit_ch, builder_aa_tab, enabled, {antiaim_system[i].mod_type, 'Delay Center'})
    antiaim_system[i].yaw_modifer_delay_random:depend(cnd_en, tab_cond, aa_tab, jit_ch, builder_aa_tab, enabled, {antiaim_system[i].mod_type, 'Delay Center'})

    antiaim_system[i].gs_body_yaw_type:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled)
    antiaim_system[i].gs_body_slider:depend(cnd_en, tab_cond, aa_tab, body_ch, builder_aa_tab, enabled)

    antiaim_system[i].defensive:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled)
    antiaim_system[i].defesive_aa_type:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, antiaim_system[i].defensive)
    antiaim_system[i].defesive_aa_mode:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, antiaim_system[i].defensive)
    antiaim_system[i].defesive_aa_mode_type:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, antiaim_system[i].defensive, {antiaim_system[i].defesive_aa_mode, 'Mode'})
    antiaim_system[i].defensive_aa_sinus_yaw:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, antiaim_system[i].defensive, {antiaim_system[i].defesive_aa_mode, 'Mode'}, {antiaim_system[i].defesive_aa_mode_type, 'Sinus'})
    antiaim_system[i].defensive_aa_sinus_speed:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, antiaim_system[i].defensive, {antiaim_system[i].defesive_aa_mode, 'Mode'}, {antiaim_system[i].defesive_aa_mode_type, 'Sinus'})
    antiaim_system[i].defensive_aa_sinus_amplitude:depend(cnd_en, tab_cond, aa_tab, builder_aa_tab, enabled, antiaim_system[i].defensive, {antiaim_system[i].defesive_aa_mode, 'Mode'}, {antiaim_system[i].defesive_aa_mode_type, 'Sinus'})
    antiaim_system[i].defensive_yaw_value_1:depend(cnd_en, tab_cond, aa_tab, def_ch, builder_aa_tab, enabled, {antiaim_system[i].defensive_yaw, 'Distortion', 'Jitter', 'Custom', 'Spin', 'Delay', 'Secret'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_yaw_value_2:depend(cnd_en, tab_cond, aa_tab, def_ch, builder_aa_tab, enabled, {antiaim_system[i].defensive_yaw, 'Jitter', 'Delay', 'Secret', 'Spin'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_yaw_delay:depend(cnd_en, tab_cond, aa_tab, def_ch, builder_aa_tab, enabled, {antiaim_system[i].defensive_yaw, 'Delay'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_yaw_speed:depend(cnd_en, tab_cond, aa_tab, def_ch, builder_aa_tab, enabled, {antiaim_system[i].defensive_yaw, 'Distortion', 'Spin'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_yaw:depend(cnd_en, tab_cond, aa_tab, def_ch, enabled, builder_aa_tab, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_pitch:depend(cnd_en, tab_cond, aa_tab, def_ch, enabled, builder_aa_tab, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_pitch_value:depend(cnd_en, tab_cond, aa_tab, def_ch, pitch_ch, enabled, builder_aa_tab, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_pitch_value_2:depend(cnd_en, tab_cond, aa_tab, def_ch, enabled, builder_aa_tab, {antiaim_system[i].defensive_pitch, 'Jitter', 'Delay', 'Spin'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_pitch_speed:depend(cnd_en, tab_cond, aa_tab, def_ch, enabled, builder_aa_tab, {antiaim_system[i].defensive_pitch, 'Spin'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
    antiaim_system[i].defensive_pitch_delay:depend(cnd_en, tab_cond, aa_tab, def_ch, enabled, builder_aa_tab, {antiaim_system[i].defensive_pitch, 'Delay'}, {antiaim_system[i].defesive_aa_mode, 'Builder'})
end
--region aa system

local function randomize_value(original_value, percent)
    local min_range = original_value - (original_value * percent / 100)
    local max_range = original_value + (original_value * percent / 100)
    return math.random(min_range, max_range)
end

local function exploit_charged()
    if not ui.get(ref.dt[1]) or not ui.get(ref.dt[2]) or ui.get(ref.fakeduck) then return false end
    if not entity.is_alive(entity.get_local_player()) or entity.get_local_player() == nil then return end
    local weapon = entity.get_prop(entity.get_local_player(), 'm_hActiveWeapon')
    if weapon == nil then return false end
    local next_attack = entity.get_prop(entity.get_local_player(), 'm_flNextAttack') + 0.01
    local checkcheck = entity.get_prop(weapon, 'm_flNextPrimaryAttack')
    if checkcheck == nil then return end
    local next_primary_attack = checkcheck + 0.01
    if next_attack == nil or next_primary_attack == nil then return false end
    return next_attack - globals.curtime() < 0 and next_primary_attack - globals.curtime() < 0
end

local last_sim_time = 0
local native_GetClientEntity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*, int)')
local defensive_until = 0

local function check_charge()
    local lp = entity.get_local_player()
    local m_nTickBase = entity.get_prop(lp, 'm_nTickBase')
    local client_latency = client.latency()
    local shift = math.floor(m_nTickBase - globals.tickcount() - 3 - toticks(client_latency) * .5 + .5 * (client_latency * 10))
    local wanted = -14 + (ui.get(ref.dt_fakelag_limit) - 1) + 3
    return shift <= wanted
end

local defensive_check = {
    lc_left = 0,
    defensive = false,
    tickbase_max = 0,
    last_cmd = 0
}

function reset_def()
    defensive_check = {
        lc_left = 0,
        defensive = false,
        tickbase_max = 0,
        last_cmd = 0
    }
end

client.set_event_callback('predict_command', function(arg_140_0)
    local lp = entity.get_local_player()
	if not lp or defensive_check.last_cmd ~= arg_140_0.command_number then
		return
	end

	local tickbase = entity.get_prop(lp, "m_nTickBase") or 0

	if math.abs(tickbase - defensive_check.tickbase_max) > 64 then
		defensive_check.tickbase_max = 0
	end

	if tickbase > defensive_check.tickbase_max then
		defensive_check.tickbase_max = tickbase
	end

	defensive_check.lc_left = math.min(14, math.max(0, defensive_check.tickbase_max - tickbase - 1))
	defensive_check.defensive = defensive_check.lc_left > 0
end)

client.set_event_callback('run_command', function(cmd)
	defensive_check.last_cmd = cmd.command_number
end)

function is_defensive_active(lp)
    if not check_charge() then return false end
    return defensive_check.defensive
end

function CompensateMovingJitter(jitterAmount)
    local lp = entity.get_local_player()
    if not lp then return jitterAmount end

    local vecvelocity = { entity.get_prop(lp, 'm_vecVelocity') }
    local velocity = math.sqrt(vecvelocity[1]^2+vecvelocity[2]^2)

    if velocity > 5 then
        local factor = math.min(velocity / 250, 1)
        local compensation = jitterAmount * (1 - factor * 0.5)

        if jitterAmount > 0 then
            return math.max(compensation, jitterAmount * 0.5)
        else
            return math.min(compensation, jitterAmount * 0.5)
        end
    else
        return jitterAmount
    end
end

local id = 1   
local function player_state(cmd)
    if not enabled then return end
    local lp = entity.get_local_player()
    if lp == nil then return end

    local vecvelocity = { entity.get_prop(lp, 'm_vecVelocity') }
    local flags = entity.get_prop(lp, 'm_fFlags')
    local velocity = math.sqrt(vecvelocity[1]^2+vecvelocity[2]^2)
    local groundcheck = bit.band(flags, 1) == 1
    local jumpcheck = bit.band(flags, 1) == 0 or cmd.in_jump == 1
    local ducked = entity.get_prop(lp, 'm_flDuckAmount') > 0.7
    local duckcheck = ducked or ui.get(ref.fakeduck)
    local slowwalk_key = ui.get(ref.slow[1]) and ui.get(ref.slow[2])

    if jumpcheck and duckcheck then return 'Aerobic+'
    elseif jumpcheck then return 'Aerobic'
    elseif duckcheck and velocity > 10 then return 'Sneaking'
    elseif duckcheck and velocity < 10 then return 'Ducking'
    elseif groundcheck and slowwalk_key and velocity > 10 then return 'Walking'
    elseif groundcheck and velocity > 5 then return 'Running'
    elseif groundcheck and velocity < 5 then return 'Standing'
    else return 'Shared' end
end

yaw_direction = 0
last_press_t_dir = 0

local run_direction = function()
    if not enabled then return end
    ui.set(ref.freestand[1], true)
    ui.set(ref.freestand[2], lua_ui.antiaim_misc.key_freestand:get() and 'Always on' or 'On hotkey')

    if yaw_direction ~= 0 then
        ui.set(ref.freestand[1], false)
    end

    if lua_ui.antiaim_misc.key_right:get() and last_press_t_dir + 0.2 < globals.curtime() then
        yaw_direction = yaw_direction == 90 and 0 or 90
        last_press_t_dir = globals.curtime()
    elseif lua_ui.antiaim_misc.key_left:get() and last_press_t_dir + 0.2 < globals.curtime() then
        yaw_direction = yaw_direction == -90 and 0 or -90
        last_press_t_dir = globals.curtime()
    elseif lua_ui.antiaim_misc.key_forward:get() and last_press_t_dir + 0.2 < globals.curtime() then
        yaw_direction = yaw_direction == 180 and 0 or 180
        last_press_t_dir = globals.curtime()
    elseif last_press_t_dir > globals.curtime() then
        last_press_t_dir = globals.curtime()
    end
end

anti_knife_dist = function (x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

local function is_vulnerable()
    for _, v in ipairs(entity.get_players(true)) do
        local flags = (entity.get_esp_data(v)).flags
        if bit.band(flags, bit.lshift(1, 11)) ~= 0 then
            return true
        end
    end
    return false
end

local function safe_func()
    ui.set(ref.yawjitter[1], 'Off')
    ui.set(ref.yaw[1], '180')
    ui.set(ref.bodyyaw[1], 'Static')
    ui.set(ref.bodyyaw[2], 1)
    ui.set(ref.yaw[2], 0)
    ui.set(ref.pitch[2], 89)
end

local current_tickcount = 0
local c_tickcount = 0
local to_jitter = false
local to_swap = false
local to_defensive = true
local first_execution = true
local yaw_amount = 0

local function defensive_peek()
    to_defensive = false
end

local function defensive_disabler()
    to_defensive = true
end

local function normalizeAngle(angle)
    return ((angle + 180) % 360) - 180
end

local function normalizePitch(pitch)
    return ((pitch + 89) % 178) - 89
end

function linearInterpolation(a, b, t)
    return a + (b - a) * t
end

function oscillate(time)
    return 180 * math.sin(time)
end

local sinusoidalTime = 0

local function SinusoidalYaw(baseYaw, speed, amplitude)
    sinusoidalTime = sinusoidalTime + speed
    local t = sinusoidalTime
    local halfAmp = amplitude * 0.5
    local sinT = math.sin(t)
    local cos_1_3t = math.cos(t * 1.3)

    local jitter = amplitude * sinT + halfAmp * cos_1_3t

    return normalizeAngle(baseYaw + jitter)
end

local function SinusoidalPitch(speed, amplitude)
    sinusoidalTime = sinusoidalTime + speed
    local t = sinusoidalTime

    local thirdAmp = amplitude / 3
    local sin_0_8t = math.sin(t * 0.8)
    local cos_1_7t = math.cos(t * 1.7)

    local jitter = amplitude * sin_0_8t + thirdAmp * cos_1_7t

    if jitter > 89 then 
        return 89 
    elseif jitter < -89 then 
        return -89 
    else 
        return jitter 
    end
end

delayed_pitch = false
delayed_def_yaw = false
local function aa_setup(cmd)
    local lp = entity.get_local_player()
    if lp == nil then return end
    if not enabled then return end

    if player_state(cmd) == 'Sneaking' and antiaim_system[8].enable:get() then id = 8
    elseif player_state(cmd) == 'Ducking' and antiaim_system[7].enable:get() then id = 7
    elseif player_state(cmd) == 'Aerobic+' and antiaim_system[6].enable:get() then id = 6
    elseif player_state(cmd) == 'Aerobic' and antiaim_system[5].enable:get() then id = 5
    elseif player_state(cmd) == 'Walking' and antiaim_system[4].enable:get() then id = 4
    elseif player_state(cmd) == 'Running' and antiaim_system[3].enable:get() then id = 3
    elseif player_state(cmd) == 'Standing' and antiaim_system[2].enable:get() then id = 2
    else id = 1 end

    ui.set(ref.roll[1], 0)

    if not antiaim_system[id].yaw_delay_random:get() then
        if globals.tickcount() % (antiaim_system[id].yaw_delay:get() * 2) == 0 then
            to_jitter = not to_jitter
        end
    else
        if globals.tickcount() % (math.random(1, antiaim_system[id].yaw_delay:get()) * 2) == 0 then
            to_jitter = not to_jitter
        end
    end

    if is_vulnerable() then
        if first_execution then
            first_execution = false
            to_defensive = true
            client.set_event_callback('setup_command', defensive_disabler)
        end
        if globals.tickcount() % 10 == 9 then
            defensive_peek()
            client.unset_event_callback('setup_command', defensive_disabler)
        end
    else
        first_execution = true
        to_defensive = false
    end

    ui.set(ref.fsbodyyaw, false)
    ui.set(ref.pitch[1], 'Custom')
    ui.set(ref.yawbase, lua_ui.antiaim_misc.yaw_base:get())
    if antiaim_system[id].mod_type:get() == '3-Way' then
        if globals.tickcount() % 3 == 0 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(-antiaim_system[id].mod_dm:get()))
        elseif globals.tickcount() % 3 == 1 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(antiaim_system[id].mod_dm:get()))
        elseif globals.tickcount() % 3 == 2 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(-antiaim_system[id].mod_dm:get()))
        end
    elseif antiaim_system[id].mod_type:get() == '5-Way' then
        if globals.tickcount() % 5 == 0 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(-antiaim_system[id].mod_dm:get()))
        elseif globals.tickcount() % 5 == 1 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(-antiaim_system[id].mod_dm:get()))
        elseif globals.tickcount() % 5 == 2 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(-antiaim_system[id].mod_dm:get()))
        elseif globals.tickcount() % 5 == 3 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(antiaim_system[id].mod_dm:get()))
        elseif globals.tickcount() % 5 == 3 then
            ui.set(ref.yawjitter[1], 'Skitter')
            ui.set(ref.yawjitter[2], CompensateMovingJitter(antiaim_system[id].mod_dm:get()))
        end
    elseif antiaim_system[id].mod_type:get() == 'L & R' then
        ui.set(ref.yawjitter[1], 'Center')
        ui.set(ref.yawjitter[2], CompensateMovingJitter(to_jitter and antiaim_system[id].mod_dm_left:get() or antiaim_system[id].mod_dm_right:get()))
    elseif antiaim_system[id].mod_type:get() == 'Random' then
        ui.set(ref.yawjitter[1], 'Center')
        ui.set(ref.yawjitter[2], CompensateMovingJitter(math.random(antiaim_system[id].mod_dm_left:get(), antiaim_system[id].mod_dm_right:get())))
    elseif antiaim_system[id].mod_type:get() == 'Delay Center' then
        if not antiaim_system[id].yaw_modifer_delay_random:get() then
            if globals.tickcount() % (antiaim_system[id].jitter_delay:get() * 2) == 0 then
                delayed_center = not delayed_center
            end
        else
            if globals.tickcount() % (math.random(1, antiaim_system[id].jitter_delay:get()) * 2) == 0 then
                delayed_center = not delayed_center
            end
        end
        ui.set(ref.yawjitter[1], 'Center')
        ui.set(ref.yawjitter[2], CompensateMovingJitter(delayed_center and antiaim_system[id].mod_dm_left:get() or antiaim_system[id].mod_dm_right:get()))
    else
        ui.set(ref.yawjitter[1], antiaim_system[id].mod_type:get())
        ui.set(ref.yawjitter[2], CompensateMovingJitter(antiaim_system[id].mod_dm:get()))
    end

    
    if antiaim_system[id].yaw_type:get() == 'Delay' then
        ui.set(ref.bodyyaw[1], 'Static')
        ui.set(ref.bodyyaw[2], to_jitter and 1 or -1)
    else
        ui.set(ref.bodyyaw[1], antiaim_system[id].gs_body_yaw_type:get())
        ui.set(ref.bodyyaw[2], antiaim_system[id].gs_body_slider:get())
    end

    if is_defensive_active() then
        ui.set(ref.yaw[1], '180')
    end

    local lp_ping = (client.latency() * 1000)
    
    if antiaim_system[id].defesive_aa_type:get() == 'Force' then 
        cmd.force_defensive = true
    elseif antiaim_system[id].defesive_aa_type:get() == 'On Peek' then 
        cmd.force_defensive = to_defensive
    else
        cmd.force_defensive = false
    end

    local desync_type = entity.get_prop(lp, 'm_flPoseParameter', 11) * 120 - 60
    local desync_side = desync_type > 0

    if is_defensive_active() and antiaim_system[id].defensive:get() then
        kzYaw1 = antiaim_system[id].defensive_yaw_value_1:get() 
        kzYaw2 = antiaim_system[id].defensive_yaw_value_2:get() 

        ui.set(ref.yawjitter[1], 'Off')

        if antiaim_system[id].defesive_aa_mode:get() == 'Mode' then
            if antiaim_system[id].defesive_aa_mode_type:get() == 'Sinus' then
                yaw_amount = SinusoidalYaw(antiaim_system[id].defensive_aa_sinus_yaw:get(), antiaim_system[id].defensive_aa_sinus_speed:get(), antiaim_system[id].defensive_aa_sinus_amplitude:get())
            elseif antiaim_system[id].defesive_aa_mode_type:get() == 'Ping Based Sinus' then
                yaw_amount = normalizeAngle(SinusoidalYaw(-lp_ping, lp_ping/10, lp_ping))
            else
                yaw_amount = 0
            end
        else
            if antiaim_system[id].defensive_yaw:get() == 'Spin' then
                local yaw1 = 0

                if antiaim_system[id].defensive_yaw_value_1:get() == 0 then
                    yaw1 = antiaim_system[id].defensive_yaw_value_1:get() + 1
                else
                    yaw1 = antiaim_system[id].defensive_yaw_value_1:get()
                end

                yaw_amount = normalizeAngle((-math.fmod(globals.curtime() * (antiaim_system[id].defensive_yaw_speed:get()/10 * 360), yaw1 * 2) + antiaim_system[id].defensive_yaw_value_2:get()))
                ui.set(ref.bodyyaw[1], 'Static')
            elseif antiaim_system[id].defensive_yaw:get() == '180' then
                yaw_amount = 180
                ui.set(ref.bodyyaw[1], 'Static')
            elseif antiaim_system[id].defensive_yaw:get() == 'Jitter' then
                ui.set(ref.bodyyaw[1], 'Jitter')
                ui.set(ref.bodyyaw[2], -1)
                yaw_amount = desync_side and antiaim_system[id].defensive_yaw_value_1:get() or antiaim_system[id].defensive_yaw_value_2:get()
            elseif antiaim_system[id].defensive_yaw:get() == 'Delay' then
                if globals.tickcount() % (antiaim_system[id].defensive_yaw_delay:get() * 2) == 0 then
                    delayed_def_yaw = not delayed_def_yaw
                end
                ui.set(ref.bodyyaw[1], 'Static')
                if delayed_def_yaw == true then
                    ui.set(ref.bodyyaw[2], -1)
                else
                    ui.set(ref.bodyyaw[2], 1)
                end
                yaw_amount = delayed_def_yaw and antiaim_system[id].defensive_yaw_value_1:get() or antiaim_system[id].defensive_yaw_value_2:get()
            elseif antiaim_system[id].defensive_yaw:get() == 'Meta' then
                ui.set(ref.bodyyaw[1], 'Jitter')
                ui.set(ref.bodyyaw[2], -1)
                yaw_amount = desync_side and 90 or -90
            elseif antiaim_system[id].defensive_yaw:get() == 'Sideways' then
                ui.set(ref.bodyyaw[1], 'Jitter')
                ui.set(ref.bodyyaw[2], -1)
                yaw_amount = desync_side and 111 or -111
            elseif antiaim_system[id].defensive_yaw:get() == 'Random' then
                ui.set(ref.bodyyaw[1], 'Static')
                yaw_amount = math.random(-180, 180)
            elseif antiaim_system[id].defensive_yaw:get() == 'Distortion' then
                ui.set(ref.bodyyaw[1], 'Static')
                dist_calc_yaw = (math.sin(globals.curtime() * antiaim_system[id].defensive_yaw_speed:get() * antiaim_system[id].defensive_yaw_value_1:get()))
                yaw_amount = math.random(-180, 180)
            elseif antiaim_system[id].defensive_yaw:get() == 'Custom' then
                ui.set(ref.bodyyaw[1], 'Static')
                yaw_amount = antiaim_system[id].defensive_yaw_value_1:get()
            elseif antiaim_system[id].defensive_yaw:get() == 'Secret' then
                ui.set(ref.bodyyaw[1], 'Static')
                yaw_amount = normalizeAngle(linearInterpolation(kzYaw1, kzYaw2, oscillate(math.random(-90,90))))
            else
                ui.set(ref.bodyyaw[1], 'Jitter')
                ui.set(ref.bodyyaw[2], -1)
                yaw_amount = desync_side and antiaim_system[id].yaw_left:get() or antiaim_system[id].yaw_right:get()
            end
        end
    else
        if antiaim_system[id].yaw_type:get() == 'Static' then
            yaw_amount = antiaim_system[id].yaw_static:get()
        else
            yaw_amount = desync_side and randomize_value(antiaim_system[id].yaw_left:get(), antiaim_system[id].yaw_random:get()) or randomize_value(antiaim_system[id].yaw_right:get(), antiaim_system[id].yaw_random:get())
        end
        if antiaim_system[id].pitch_type:get() == 'Down' then
            ui.set(ref.pitch[2], 89)
        elseif antiaim_system[id].pitch_type:get() == 'Up' then
            ui.set(ref.pitch[2], -89)
        else
            ui.set(ref.pitch[2], antiaim_system[id].pitch_value:get())
        end
    end

    if is_defensive_active() and antiaim_system[id].defensive:get() then
        if antiaim_system[id].defesive_aa_mode:get() == 'Mode' then
            if antiaim_system[id].defesive_aa_mode_type:get() == 'Sinus' then
                ui.set(ref.pitch[2], SinusoidalPitch(antiaim_system[id].defensive_aa_sinus_speed:get(), antiaim_system[id].defensive_aa_sinus_amplitude:get()))
            elseif antiaim_system[id].defesive_aa_mode_type:get() == 'Ping Based Sinus' then
                ui.set(ref.pitch[2], normalizePitch(SinusoidalPitch(lp_ping/2.5, lp_ping/2)))
            else
                ui.set(ref.pitch[2], 89)
            end
        else
            if antiaim_system[id].defensive_pitch:get() == 'Custom' then
                ui.set(ref.pitch[2], antiaim_system[id].defensive_pitch_value:get())
            elseif antiaim_system[id].defensive_pitch:get() == 'Up' then
                ui.set(ref.pitch[2], -89)
            elseif antiaim_system[id].defensive_pitch:get() == 'Down' then
                ui.set(ref.pitch[2], 89)
            elseif antiaim_system[id].defensive_pitch:get() == 'Half Up' then
                ui.set(ref.pitch[2], -45)
            elseif antiaim_system[id].defensive_pitch:get() == 'Half Down' then
                ui.set(ref.pitch[2], 45)
            elseif antiaim_system[id].defensive_pitch:get() == 'Spin' then

                local pitch1 = 0

                if antiaim_system[id].defensive_pitch_value:get() == 0 then
                    pitch1 = antiaim_system[id].defensive_pitch_value:get() + 1
                else
                    pitch1 = antiaim_system[id].defensive_pitch_value:get()
                end

                ui.set(ref.pitch[2], (normalizePitch(-math.fmod(globals.curtime() * (antiaim_system[id].defensive_pitch_speed:get()/10 * 360), pitch1 * 2) + antiaim_system[id].defensive_pitch_value_2:get())))
            elseif antiaim_system[id].defensive_pitch:get() == 'Delay' then
                if globals.tickcount() % (antiaim_system[id].defensive_pitch_delay:get() * 2) == 0 then
                    delayed_pitch = not delayed_pitch
                end
                ui.set(ref.pitch[2], delayed_pitch and antiaim_system[id].defensive_pitch_value:get() or antiaim_system[id].defensive_pitch_value_2:get())
            elseif antiaim_system[id].defensive_pitch:get() == 'Jitter' then
                ui.set(ref.bodyyaw[1], 'Jitter')
                ui.set(ref.bodyyaw[2], -1)
                ui.set(ref.pitch[2], desync_side and antiaim_system[id].defensive_pitch_value:get() or antiaim_system[id].defensive_pitch_value_2:get())
            elseif antiaim_system[id].defensive_pitch:get() == 'Meta' then
                ui.set(ref.bodyyaw[1], 'Jitter')
                ui.set(ref.bodyyaw[2], -1)
                ui.set(ref.pitch[2], desync_side and 49 or -49)
            elseif antiaim_system[id].defensive_pitch:get() == 'Random' then
                ui.set(ref.pitch[2], math.random(-89, 89))
            elseif antiaim_system[id].defensive_pitch:get() == 'Kazakh' then
                if yaw_amount > 0 then
                    ui.set(ref.pitch[2], 58)
                else
                    ui.set(ref.pitch[2], -58)
                end
            else
                ui.set(ref.pitch[2], 89)
            end
        end
    end

    if lua_ui.antiaim_misc.manuals_manipulations:get('E-Peek') then
        if yaw_direction == 90 or yaw_direction == -90 or yaw_direction == 180 then
            if is_defensive_active() then
                ui.set(ref.pitch[1], 'Custom')
                ui.set(ref.pitch[2], 0)
                ui.set(ref.bodyyaw[1], 'Static')
                e_peek = -yaw_direction
                cmd.force_defensive = true
            else
                e_peek = 0
            end
        else
            e_peek = 0
        end
    else
        e_peek = 0
    end

    ui.set(ref.yaw[2], yaw_direction == 0 and yaw_amount or yaw_direction + e_peek*2)

    if lua_ui.antiaim_misc.manuals_manipulations:get('Static') then
        if yaw_direction == 90 or yaw_direction == -90 or yaw_direction == 180 then
            ui.set(ref.yawjitter[1], 'Off')
            ui.set(ref.yaw[1], '180')
            if not lua_ui.antiaim_misc.manuals_manipulations:get('E-Peek') then
                ui.set(ref.pitch[2], 89)
            end
            ui.set(ref.yawbase, 'Local view')
        end
    end

    local is_osaa = ui.get(ref.os[2]) and ui.get(ref.os[1])
    local is_dt = ui.get(ref.dt[1]) and ui.get(ref.dt[2])

    if lua_ui.antiaim_misc.fake_lags:get() then
        if lua_ui.ragebot.hideshot_fix:get() and is_osaa and not is_dt then
            ui.set(ref.flEnabled[1], false)
            ui.set(ref.flLimit, 1)
        else
            ui.set(ref.flEnabled[1], true)
            ui.set(ref.flEnabled[2], 'Always On')
            if lua_ui.antiaim_misc.fake_lags_amount:get() == 'Nyctophobia' then

                ui.set(ref.flAmount, 'Maximum')
                ui.set(ref.flLimit, math.random(13, 15))
                ui.set(ref.flVariance, math.random(5, 40))
            else
                ui.set(ref.flAmount, lua_ui.antiaim_misc.fake_lags_amount:get())
                ui.set(ref.flLimit, lua_ui.antiaim_misc.fake_lags_limit:get())
                ui.set(ref.flVariance, lua_ui.antiaim_misc.fake_lags_variance:get())
            end
        end
    else
        ui.set(ref.flEnabled[1], false)
        ui.set(ref.flEnabled[2], false)
    end

    local delayed_flick = false

    if lua_ui.antiaim_misc.defensive_flick:get() and lua_ui.antiaim_misc.defensive_flick_key:get() then
        if globals.tickcount() % (lua_ui.antiaim_misc.defensive_flick_ticks:get() * 2) == 0 then
            delayed_flick = not delayed_flick
        end

        cmd.force_defensive = cmd.command_number % 7 == 0

        if is_defensive_active() then
            ui.set(ref.pitch[2], 89)
            if lua_ui.antiaim_misc.defensive_flick_type:get() == 'Right' then
                ui.set(ref.yaw[2], 90)
                ui.set(ref.bodyyaw[2], delayed_flick and -1 or 1)
            elseif lua_ui.antiaim_misc.defensive_flick_type:get() == 'Left' then
                ui.set(ref.yaw[2], -90)
                ui.set(ref.bodyyaw[2], delayed_flick and 1 or -1)
            elseif lua_ui.antiaim_misc.defensive_flick_type:get() == 'Custom' then
                ui.set(ref.yaw[2], lua_ui.antiaim_misc.defensive_flick_value:get())
                if lua_ui.antiaim_misc.defensive_flick_value:get() < 0 then
                    ui.set(ref.bodyyaw[2], delayed_flick and 1 or -1)
                else
                    ui.set(ref.bodyyaw[2], delayed_flick and -1 or 1)
                end

            end
            ui.set(ref.yawjitter[1], 'Off')
            ui.set(ref.bodyyaw[1], 'Static')
        else
            ui.set(ref.pitch[2], 89)
            ui.set(ref.yawjitter[1], 'Off')
            ui.set(ref.bodyyaw[1], 'Static')
            ui.set(ref.yaw[2], 4)
            ui.set(ref.yaw[1], '180')
            ui.set(ref.bodyyaw[2], 1)
        end
    end
  
    local players = entity.get_players(true)
    if lua_ui.antiaim_misc.addons:get('Warmup Anti-Aim') then
        if entity.get_prop(entity.get_game_rules(), 'm_bWarmupPeriod') == 1 then
            ui.set(ref.yaw[2], math.random(-60, 72))
            ui.set(ref.yawjitter[2], math.random(-10, 10))
            ui.set(ref.bodyyaw[2], math.random(-1, 1))
            ui.set(ref.pitch[1], 'Minimal')
        end
    end

    if lua_ui.antiaim_misc.addons:get('Edge Yaw on FD') then
        if ui.get(ref.fakeduck) then
            ui.set(ref.edgeyaw, true)
        else
            ui.set(ref.edgeyaw, false)
        end
    else
        ui.set(ref.edgeyaw, false)
    end

    local threat = client.current_threat()
    local lp_weapon = entity.get_player_weapon(lp)
    local lp_orig_x, lp_orig_y, lp_orig_z = entity.get_prop(lp, 'm_vecOrigin')
    local flags = entity.get_prop(lp, 'm_fFlags')
    local jumpcheck = bit.band(flags, 1) == 0 or cmd.in_jump == 1
    local ducked = entity.get_prop(lp, 'm_flDuckAmount') > 0.7

    if lua_ui.antiaim_misc.addons:get('Safe Head') then

        if is_defensive_active() and antiaim_system[id].defensive:get() and not lua_ui.antiaim_misc.disable_defensive_on_safe:get() then return end

        if lp_weapon ~= nil then
            if lua_ui.antiaim_misc.safe_head:get('Air+C Knife') then
                if jumpcheck and ducked and entity.get_classname(lp_weapon) == 'CKnife' then
                    safe_func()
                end
            end
            if lua_ui.antiaim_misc.safe_head:get('Air+C Zeus') then
                if jumpcheck and ducked and entity.get_classname(lp_weapon) == 'CWeaponTaser' then
                    safe_func()
                end
            end
            if lua_ui.antiaim_misc.safe_head:get('High Distance') then
                if threat ~= nil then
                    if yaw_direction == 90 or yaw_direction == -90 or yaw_direction == 180 then return end
                    threat_x, threat_y, threat_z = entity.get_prop(threat, 'm_vecOrigin')
                    threat_dist = anti_knife_dist(lp_orig_x, lp_orig_y, lp_orig_z, threat_x, threat_y, threat_z)
                    if threat_dist > 900 then
                        safe_func()
                    end
                end
            end

            if lua_ui.antiaim_misc.safe_head:get('Higher than enemy') then
                if threat ~= nil then
                    if yaw_direction == 90 or yaw_direction == -90 or yaw_direction == 180 then return end
                    threat_x, threat_y, threat_z = entity.get_prop(threat, "m_vecOrigin")
                    threat_dist = lp_orig_z - threat_z
                    if threat_dist > 55 then
                        safe_func()
                    end
                end
            end
        end
    end
                
    if lua_ui.antiaim_misc.addons:get('Anti Backstab') then
        for i=1, #players do
            if players == nil then return end
            enemy_orig_x, enemy_orig_y, enemy_orig_z = entity.get_prop(players[i], 'm_vecOrigin')
            distance_to = anti_knife_dist(lp_orig_x, lp_orig_y, lp_orig_z, enemy_orig_x, enemy_orig_y, enemy_orig_z)
            weapon = entity.get_player_weapon(players[i])
            if weapon == nil then return end
            if entity.get_classname(weapon) == 'CKnife' and distance_to <= 250 then
                ui.set(ref.yaw[2], 180)
                ui.set(ref.yawbase, 'At targets')
            end
        end
    end
end

local function prediction_system(cmd)

end

--region cfg system

local config_items = {lua_ui.ragebot, lua_ui.antiaim_misc, lua_ui.other, antiaim_system}

local package, data, encrypted, decrypted = libs.pui.setup(config_items), '', '', ''
config = {}

config.export = function()
    data = package:save()
    encrypted = libs.base64_lib.encode(json.stringify(data))
    libs.clipboard_lib.set(encrypted)
    print('Exported')
end

config.import = function(input)
    decrypted = json.parse(libs.base64_lib.decode(input ~= nil and input or libs.clipboard_lib.get()))
    package:load(decrypted)
    print('Imported')
end

discord = groups.group_fl:button('Discord Server', function() 
    panorama.open().SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/BquaH5FZGR")
end):depend(enabled)

buttom_import = groups.group_fl:button('Import Config', function() 
    config.import()
end):depend(enabled)

buttom_export = groups.group_fl:button('Export Config', function() 
    config.export()
end):depend(enabled)

buttom_sex = groups.group_fl:button('\a'..get_skeet_color()..'SeX Preset [\aEC3F3FFFdebug\r]', function() 
    config.import('W3sicHJlZGljdF9iaW5kIjpbMSwxNywifiJdLCJhaXJzdG9wIjpbMSwwLCJ+Il0sInVuc2FmZV9jaGFyZ2UiOnRydWUsInJlc29sdmVyIjpmYWxzZSwicHJlZGljdGlvbl9zeXN0ZW0iOmZhbHNlLCJwcmVkaWN0X3dlYXBvbnMiOlsiQVdQIiwiQXV0byIsIlNjb3V0IiwifiJdLCJoaWRlc2hvdF9maXgiOmZhbHNlLCJhdXRvX3RwIjpmYWxzZSwicHJlZGljdF9jb25kaXRpb25zIjpbIlN0YW5kaW5nIiwiV2Fsa2luZyIsIkR1Y2tpbmciLCJTbmVha2luZyIsIn4iXSwiZGVmZW5zaXZlX2ZpeCI6ZmFsc2UsImFpcmxhZyI6ZmFsc2UsImF1dG9fdHBfa2V5IjpbMSwwLCJ+Il0sInByZWRpY3RfdHlwZSI6IkRlZmF1bHQiLCJyZXNvbHZlcl90eXBlIjoiPz8/In0seyJmYWtlX2xhZ3NfYW1vdW50IjoiU2V4Q29yZCIsImFkZG9ucyI6WyJXYXJtdXAgQW50aS1BaW0iLCJBbnRpIEJhY2tzdGFiIiwiU2FmZSBIZWFkIiwiRWRnZSBZYXcgb24gRkQiLCJ+Il0sIm1hbnVhbHNfbWFuaXB1bGF0aW9ucyI6WyJTdGF0aWMiLCJ+Il0sImtleV9sZWZ0IjpbMSw5MCwifiJdLCJkZWZlbnNpdmVfZmxpY2tfdHlwZSI6IkxlZnQiLCJmYWtlX2xhZ3MiOnRydWUsImtleV9mcmVlc3RhbmQiOlsxLDAsIn4iXSwieWF3X2Jhc2UiOiJBdCBUYXJnZXRzIiwiZmFrZV9sYWdzX2xpbWl0IjoxLCJkaXNhYmxlX2RlZmVuc2l2ZV9vbl9zYWZlIjpmYWxzZSwia2V5X2ZvcndhcmQiOlsxLDAsIn4iXSwiZGVmZW5zaXZlX2ZsaWNrX2tleSI6WzEsMCwifiJdLCJrZXlfcmlnaHQiOlsxLDg4LCJ+Il0sImZha2VfbGFnc192YXJpYW5jZSI6MCwiYWFfc2VsZWN0IjoiQnVpbGRlciIsImRlZmVuc2l2ZV9mbGlja192YWx1ZSI6MCwiZGVmZW5zaXZlX2ZsaWNrX3RpY2tzIjoxLCJzYWZlX2hlYWQiOlsiQWlyK0MgS25pZmUiLCJIaWdoZXIgdGhhbiBlbmVteSIsIn4iXSwiZGVmZW5zaXZlX2ZsaWNrIjpmYWxzZX0seyJicmFuZGVkX3dhdGVybWFya19wb3MiOiJCb3R0b20iLCJidXlfYm90X3ByaW1hcnkiOiJBV1AiLCJjcm9zc19pbmQiOnRydWUsImFuaW1hdGlvbiI6dHJ1ZSwibWFudWFsX2luZGljYXRvcnNfdHlwZSI6Ik1vZGVybiIsInRoaXJkX3BlcnNvbl92YWx1ZSI6NjksImZpbHRlcl9jb25zb2xlIjp0cnVlLCJidXlfYm90X290aGVyIjpbIktldmxhciIsIkhlbG1ldCIsIkRlZnVzZSBLaXQiLCJHcmVuYWRlIiwiTW9sb3RvdiIsIlNtb2tlIiwiVGFzZXIiLCJ+Il0sImtpbGxzYXkiOnRydWUsImJyYW5kZWRfd2F0ZXJtYXJrX3Bvc19jIjoiIzlCOTdGRkZGIiwiZmFzdF9sYWRkZXIiOnRydWUsImRlZmVuc2l2ZV9pbmRpY2F0b3IiOnRydWUsImFzcGVjdHJhdGlvIjp0cnVlLCJjcm9zc19pbmRfZ3JhZGllbnQiOmZhbHNlLCJmcHNfYm9vc3QiOnRydWUsIm1hbnVhbF9pbmRpY2F0b3JzIjp0cnVlLCJjbGFuX3RhZyI6dHJ1ZSwiaGl0bWFya2VyX3R5cGUiOiJDaXJjbGUiLCJtYW51YWxfaW5kaWNhdG9yc19jIjoiIzlCOTdGRkZGIiwiY3Jvc3NfaW5kX2MiOiIjOUI5N0ZGRkYiLCJoaXRtYXJrZXJfYyI6IiM5Qjk3RkZGRiIsImRlZmVuc2l2ZV9pbmRpY2F0b3JfYyI6IiM5Qjk3RkZGRiIsImhpdG1hcmtlciI6dHJ1ZSwibWFudWFsX2luZGljYXRvcnNfdmVsb2NpdHkiOnRydWUsInpldXNfd2FybmluZyI6dHJ1ZSwiYWltYm90X2xvZ3MiOnRydWUsImFuaW1hdGlvbl9haXIiOiJTdGF0aWMiLCJidXlfYm90X3NlY29uZGFyeSI6IkZpdmUtc2VuZU5cL1RlYzlcL0NaIiwiYnV5X2JvdCI6dHJ1ZSwiYXNwZWN0cmF0aW9fdmFsdWUiOjEyNSwiYW5pbWF0aW9uX2dyb3VuZCI6IlN0YXRpYyIsInRoaXJkX3BlcnNvbiI6dHJ1ZSwidmVsb2NpdHlfd2FybmluZ19jIjoiIzlCOTdGRkZGIiwibG9nX3R5cGUiOlsiSGl0IiwiTWlzcyIsIn4iXSwidmVsb2NpdHlfd2FybmluZyI6dHJ1ZX0sW3siZW5hYmxlIjpmYWxzZSwieWF3X3R5cGUiOiJTdGF0aWMiLCJtb2RfdHlwZSI6Ik9mZiIsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6MCwiZGVmZW5zaXZlX3lhd19kZWxheSI6NCwiZGVmZW5zaXZlIjpmYWxzZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjowLCJ5YXdfcmlnaHQiOjAsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoX3NwZWVkIjoxLCJkZWZlbnNpdmVfcGl0Y2giOiJPZmYiLCJ5YXdfcmFuZG9tIjowLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjowLCJ5YXdfZGVsYXkiOjQsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6ZmFsc2UsImppdHRlcl9kZWxheSI6NCwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MCwiZGVmZXNpdmVfYWFfdHlwZSI6Ik9mZiIsIm1vZF9kbSI6MCwiZ3NfYm9keV9zbGlkZXIiOjAsInBpdGNoX3ZhbHVlIjowLCJnc19ib2R5X3lhd190eXBlIjoiT2ZmIn0seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiTCAmIFIiLCJtb2RfdHlwZSI6IkNlbnRlciIsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6MCwiZGVmZW5zaXZlX3lhd19kZWxheSI6NCwiZGVmZW5zaXZlIjpmYWxzZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjowLCJ5YXdfcmlnaHQiOjE0LCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaF9zcGVlZCI6MSwiZGVmZW5zaXZlX3BpdGNoIjoiVXAiLCJ5YXdfcmFuZG9tIjoyNSwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwibW9kX2RtX3JpZ2h0IjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3lhdyI6Ik1ldGEiLCJkZWZlc2l2ZV9hYV9tb2RlIjoiQnVpbGRlciIsImRlZmVuc2l2ZV9waXRjaF9kZWxheSI6NCwieWF3X2xlZnQiOi0xMiwieWF3X2RlbGF5Ijo0LCJ5YXdfbW9kaWZlcl9kZWxheV9yYW5kb20iOmZhbHNlLCJqaXR0ZXJfZGVsYXkiOjQsImRlZmVuc2l2ZV9hYV9zaW51c19hbXBsaXR1ZGUiOjAsImRlZmVzaXZlX2FhX3R5cGUiOiJGb3JjZSIsIm1vZF9kbSI6MjUsImdzX2JvZHlfc2xpZGVyIjotMSwicGl0Y2hfdmFsdWUiOjAsImdzX2JvZHlfeWF3X3R5cGUiOiJKaXR0ZXIifSx7ImVuYWJsZSI6dHJ1ZSwieWF3X3R5cGUiOiJEZWxheSIsIm1vZF90eXBlIjoiNS1XYXkiLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZSI6MCwibW9kX2RtX2xlZnQiOjAsImRlZmVuc2l2ZV95YXdfZGVsYXkiOjQsImRlZmVuc2l2ZSI6ZmFsc2UsImRlZmVzaXZlX2FhX21vZGVfdHlwZSI6Ik9mZiIsInlhd19kZWxheV9yYW5kb20iOnRydWUsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjowLCJ5YXdfcmlnaHQiOjI3LCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaF9zcGVlZCI6MSwiZGVmZW5zaXZlX3BpdGNoIjoiT2ZmIiwieWF3X3JhbmRvbSI6MCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwibW9kX2RtX3JpZ2h0IjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3lhdyI6Ik9mZiIsImRlZmVzaXZlX2FhX21vZGUiOiJCdWlsZGVyIiwiZGVmZW5zaXZlX3BpdGNoX2RlbGF5Ijo0LCJ5YXdfbGVmdCI6LTIzLCJ5YXdfZGVsYXkiOjIsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6ZmFsc2UsImppdHRlcl9kZWxheSI6NCwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MCwiZGVmZXNpdmVfYWFfdHlwZSI6Ik9mZiIsIm1vZF9kbSI6MTYsImdzX2JvZHlfc2xpZGVyIjoxLCJwaXRjaF92YWx1ZSI6MCwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciJ9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IlN0YXRpYyIsIm1vZF90eXBlIjoiNS1XYXkiLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjEwLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjowLCJkZWZlbnNpdmVfeWF3X2RlbGF5Ijo0LCJkZWZlbnNpdmUiOnRydWUsImRlZmVzaXZlX2FhX21vZGVfdHlwZSI6IlNpbnVzIiwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjczLCJkZWZlbnNpdmVfYWFfc2ludXNfc3BlZWQiOjQsImRlZmVuc2l2ZV95YXdfdmFsdWVfMSI6LTEwLCJ5YXdfcmlnaHQiOjAsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoX3NwZWVkIjoxLCJkZWZlbnNpdmVfcGl0Y2giOiJEb3duIiwieWF3X3JhbmRvbSI6MCwieWF3X3N0YXRpYyI6LTcsImRlZmVuc2l2ZV95YXdfc3BlZWQiOjEsIm1vZF9kbV9yaWdodCI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjAsImRlZmVuc2l2ZV95YXciOiJKaXR0ZXIiLCJkZWZlc2l2ZV9hYV9tb2RlIjoiQnVpbGRlciIsImRlZmVuc2l2ZV9waXRjaF9kZWxheSI6NCwieWF3X2xlZnQiOjAsInlhd19kZWxheSI6NCwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjoxNDUsImRlZmVzaXZlX2FhX3R5cGUiOiJGb3JjZSIsIm1vZF9kbSI6LTQ2LCJnc19ib2R5X3NsaWRlciI6MSwicGl0Y2hfdmFsdWUiOjAsImdzX2JvZHlfeWF3X3R5cGUiOiJKaXR0ZXIifSx7ImVuYWJsZSI6dHJ1ZSwieWF3X3R5cGUiOiJEZWxheSIsIm1vZF90eXBlIjoiT2ZmIiwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjowLCJkZWZlbnNpdmVfeWF3X2RlbGF5Ijo0LCJkZWZlbnNpdmUiOnRydWUsImRlZmVzaXZlX2FhX21vZGVfdHlwZSI6Ik9mZiIsInlhd19kZWxheV9yYW5kb20iOmZhbHNlLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3IjowLCJkZWZlbnNpdmVfYWFfc2ludXNfc3BlZWQiOjEsImRlZmVuc2l2ZV95YXdfdmFsdWVfMSI6MCwieWF3X3JpZ2h0IjozNCwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2hfc3BlZWQiOjEsImRlZmVuc2l2ZV9waXRjaCI6Ik9mZiIsInlhd19yYW5kb20iOjE1LCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMzAsInlhd19kZWxheSI6MywieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJkZWZlc2l2ZV9hYV90eXBlIjoiRm9yY2UiLCJtb2RfZG0iOjAsImdzX2JvZHlfc2xpZGVyIjoxLCJwaXRjaF92YWx1ZSI6MCwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciJ9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkRlbGF5IiwibW9kX3R5cGUiOiJDZW50ZXIiLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjMsImRlZmVuc2l2ZV9waXRjaF92YWx1ZSI6MCwibW9kX2RtX2xlZnQiOjAsImRlZmVuc2l2ZV95YXdfZGVsYXkiOjQsImRlZmVuc2l2ZSI6dHJ1ZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiU2ludXMiLCJ5YXdfZGVsYXlfcmFuZG9tIjpmYWxzZSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6LTEwNiwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjo2LCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOi03LCJ5YXdfcmlnaHQiOjMyLCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaF9zcGVlZCI6MSwiZGVmZW5zaXZlX3BpdGNoIjoiRG93biIsInlhd19yYW5kb20iOjM0LCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiSml0dGVyIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMjgsInlhd19kZWxheSI6MiwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjo5MiwiZGVmZXNpdmVfYWFfdHlwZSI6IkZvcmNlIiwibW9kX2RtIjoxOSwiZ3NfYm9keV9zbGlkZXIiOi0xLCJwaXRjaF92YWx1ZSI6MCwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciJ9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkwgJiBSIiwibW9kX3R5cGUiOiJDZW50ZXIiLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjUsImRlZmVuc2l2ZV9waXRjaF92YWx1ZSI6MCwibW9kX2RtX2xlZnQiOjAsImRlZmVuc2l2ZV95YXdfZGVsYXkiOjQsImRlZmVuc2l2ZSI6dHJ1ZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjotOSwieWF3X3JpZ2h0IjoxOSwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2hfc3BlZWQiOjEsImRlZmVuc2l2ZV9waXRjaCI6IkRvd24iLCJ5YXdfcmFuZG9tIjowLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjo3LCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiSml0dGVyIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMjMsInlhd19kZWxheSI6NCwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJkZWZlc2l2ZV9hYV90eXBlIjoiRm9yY2UiLCJtb2RfZG0iOjM0LCJnc19ib2R5X3NsaWRlciI6MSwicGl0Y2hfdmFsdWUiOjAsImdzX2JvZHlfeWF3X3R5cGUiOiJKaXR0ZXIifSx7ImVuYWJsZSI6dHJ1ZSwieWF3X3R5cGUiOiJEZWxheSIsIm1vZF90eXBlIjoiT2ZmIiwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjowLCJkZWZlbnNpdmVfeWF3X2RlbGF5Ijo0LCJkZWZlbnNpdmUiOmZhbHNlLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJPZmYiLCJ5YXdfZGVsYXlfcmFuZG9tIjp0cnVlLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3IjowLCJkZWZlbnNpdmVfYWFfc2ludXNfc3BlZWQiOjEsImRlZmVuc2l2ZV95YXdfdmFsdWVfMSI6MCwieWF3X3JpZ2h0IjozMiwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2hfc3BlZWQiOjEsImRlZmVuc2l2ZV9waXRjaCI6Ik9mZiIsInlhd19yYW5kb20iOjEzLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMjgsInlhd19kZWxheSI6MywieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJkZWZlc2l2ZV9hYV90eXBlIjoiT2ZmIiwibW9kX2RtIjowLCJnc19ib2R5X3NsaWRlciI6MSwicGl0Y2hfdmFsdWUiOjAsImdzX2JvZHlfeWF3X3R5cGUiOiJKaXR0ZXIifV1d')
end):depend(enabled)

buttom_default = groups.group_fl:button('Default Preset', function() 
    config.import('W3sicHJlZGljdF9iaW5kIjpbMSwwLCJ+Il0sImFpcnN0b3AiOlsxLDAsIn4iXSwicHJlZGljdF93ZWFwb25zIjpbIn4iXSwicHJlZGljdF9jb25kaXRpb25zIjpbIn4iXSwiZGVmZW5zaXZlX2ZpeCI6dHJ1ZSwicmVzb2x2ZXJfdHlwZSI6Ij8/PyIsInJlc29sdmVyIjp0cnVlLCJwcmVkaWN0aW9uX3N5c3RlbSI6ZmFsc2UsInByZWRpY3RfdHlwZSI6IkRlZmF1bHQifSx7ImZha2VfbGFnc19hbW91bnQiOiJNYXhpbXVtIiwiZGVmZW5zaXZlX2ZsaWNrX2tleSI6WzEsMCwifiJdLCJtYW51YWxzX21hbmlwdWxhdGlvbnMiOlsiU3RhdGljIiwifiJdLCJrZXlfbGVmdCI6WzEsOTAsIn4iXSwic2FmZV9oZWFkIjpbIkFpcitDIEtuaWZlIiwifiJdLCJmYWtlX2xhZ3MiOnRydWUsImtleV9mcmVlc3RhbmQiOlsxLDAsIn4iXSwieWF3X2Jhc2UiOiJBdCBUYXJnZXRzIiwiZGVmZW5zaXZlX3RpY2tzIjoxLCJkZWZlbnNpdmVfZmxpY2tfdmFsdWUiOjAsImtleV9mb3J3YXJkIjpbMSwwLCJ+Il0sImZha2VfbGFnc19saW1pdCI6MTQsImtleV9yaWdodCI6WzEsODgsIn4iXSwiYWRkb25zIjpbIldhcm11cCBBbnRpLUFpbSIsIkFudGkgQmFja3N0YWIiLCJTYWZlIEhlYWQiLCJFZGdlIFlhdyBvbiBGRCIsIn4iXSwiYWFfc2VsZWN0IjoiTWFpbiIsImZha2VfbGFnc192YXJpYW5jZSI6MTAsImRlZmVuc2l2ZV9mbGlja190aWNrcyI6MSwiZGVmZW5zaXZlX2ZsaWNrX3R5cGUiOiJMZWZ0IiwiZGVmZW5zaXZlX2ZsaWNrIjpmYWxzZX0seyJicmFuZGVkX3dhdGVybWFya19wb3MiOiJCb3R0b20iLCJidXlfYm90X3ByaW1hcnkiOiJBV1AiLCJjcm9zc19pbmQiOnRydWUsImFuaW1hdGlvbiI6dHJ1ZSwibWFudWFsX2luZGljYXRvcnNfdHlwZSI6Ik1vZGVybiIsInRoaXJkX3BlcnNvbl92YWx1ZSI6NTAsImJ1eV9ib3Rfb3RoZXIiOlsiS2V2bGFyIiwiSGVsbWV0IiwiRGVmdXNlIEtpdCIsIkdyZW5hZGUiLCJNb2xvdG92IiwiU21va2UiLCJUYXNlciIsIn4iXSwia2lsbHNheSI6dHJ1ZSwiYW5pbWF0aW9uX2dyb3VuZCI6IlN0YXRpYyIsImZhc3RfbGFkZGVyIjp0cnVlLCJkZWZlbnNpdmVfaW5kaWNhdG9yIjp0cnVlLCJhc3BlY3RyYXRpbyI6ZmFsc2UsImNyb3NzX2luZF9ncmFkaWVudCI6dHJ1ZSwiZnBzX2Jvb3N0Ijp0cnVlLCJtYW51YWxfaW5kaWNhdG9ycyI6dHJ1ZSwiY2xhbl90YWciOnRydWUsImhpdG1hcmtlcl90eXBlIjoiQ2lyY2xlIiwibWFudWFsX2luZGljYXRvcnNfYyI6IiNGRkEwQTBGRiIsIm1hbnVhbF9pbmRpY2F0b3JzX3ZlbG9jaXR5X2MiOiIjRkZBMEEwRkYiLCJoaXRtYXJrZXJfYyI6IiNGRkEwQTBGRiIsImRlZmVuc2l2ZV9pbmRpY2F0b3JfYyI6IiNGRkEwQTBGRiIsImhpdG1hcmtlciI6dHJ1ZSwiemV1c193YXJuaW5nIjp0cnVlLCJtYW51YWxfaW5kaWNhdG9yc192ZWxvY2l0eSI6dHJ1ZSwiYWltYm90X2xvZ3MiOnRydWUsImJyYW5kZWRfd2F0ZXJtYXJrX3Bvc19jIjoiI0ZGQTBBMEZGIiwiY3Jvc3NfaW5kX2MiOiIjRkZBMEEwRkYiLCJidXlfYm90X3NlY29uZGFyeSI6IkZpdmUtc2VuZU5cL1RlYzlcL0NaIiwiYnV5X2JvdCI6ZmFsc2UsImFzcGVjdHJhdGlvX3ZhbHVlIjoxMjUsInRoaXJkX3BlcnNvbiI6ZmFsc2UsImFuaW1hdGlvbl9haXIiOiJTdGF0aWMiLCJ2ZWxvY2l0eV93YXJuaW5nX2MiOiIjRkZBMEEwRkYiLCJsb2dfdHlwZSI6WyJIaXQiLCJNaXNzIiwifiJdLCJ2ZWxvY2l0eV93YXJuaW5nIjp0cnVlfSxbeyJlbmFibGUiOmZhbHNlLCJ5YXdfdHlwZSI6IlN0YXRpYyIsIm1vZF90eXBlIjoiT2ZmIiwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjowLCJkZWZlbnNpdmVfeWF3X2RlbGF5Ijo0LCJkZWZlbnNpdmUiOmZhbHNlLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJPZmYiLCJ5YXdfZGVsYXlfcmFuZG9tIjpmYWxzZSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6MCwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjoxLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOjAsInlhd19yaWdodCI6MCwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2giOiJPZmYiLCJ5YXdfcmFuZG9tIjowLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjowLCJkZWZlc2l2ZV9hYV90eXBlIjoiT2ZmIiwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJ5YXdfZGVsYXkiOjQsIm1vZF9kbSI6MCwiZ3NfYm9keV9zbGlkZXIiOjAsInBpdGNoX3ZhbHVlIjowLCJnc19ib2R5X3lhd190eXBlIjoiT2ZmIn0seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiTCAmIFIiLCJtb2RfdHlwZSI6IkNlbnRlciIsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6MCwiZGVmZW5zaXZlX3lhd19kZWxheSI6NCwiZGVmZW5zaXZlIjp0cnVlLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJTaW51cyIsInlhd19kZWxheV9yYW5kb20iOmZhbHNlLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3IjoxODAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MiwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjowLCJ5YXdfcmlnaHQiOjIzLCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaCI6Ik9mZiIsInlhd19yYW5kb20iOjEwLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6Ik1vZGUiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMzIsImRlZmVzaXZlX2FhX3R5cGUiOiJGb3JjZSIsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6ZmFsc2UsImppdHRlcl9kZWxheSI6NCwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MzYsInlhd19kZWxheSI6NCwibW9kX2RtIjoxNCwiZ3NfYm9keV9zbGlkZXIiOjEsInBpdGNoX3ZhbHVlIjowLCJnc19ib2R5X3lhd190eXBlIjoiSml0dGVyIn0seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiRGVsYXkiLCJtb2RfdHlwZSI6IkNlbnRlciIsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6MCwiZGVmZW5zaXZlX3lhd19kZWxheSI6NCwiZGVmZW5zaXZlIjpmYWxzZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjowLCJ5YXdfcmlnaHQiOjM0LCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaCI6Ik9mZiIsInlhd19yYW5kb20iOjEwLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMjgsImRlZmVzaXZlX2FhX3R5cGUiOiJPZmYiLCJ5YXdfbW9kaWZlcl9kZWxheV9yYW5kb20iOmZhbHNlLCJqaXR0ZXJfZGVsYXkiOjQsImRlZmVuc2l2ZV9hYV9zaW51c19hbXBsaXR1ZGUiOjAsInlhd19kZWxheSI6MiwibW9kX2RtIjoxNCwiZ3NfYm9keV9zbGlkZXIiOjEsInBpdGNoX3ZhbHVlIjowLCJnc19ib2R5X3lhd190eXBlIjoiU3RhdGljIn0seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiTCAmIFIiLCJtb2RfdHlwZSI6Ik9mZiIsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6MCwiZGVmZW5zaXZlX3lhd19kZWxheSI6NCwiZGVmZW5zaXZlIjp0cnVlLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJPZmYiLCJ5YXdfZGVsYXlfcmFuZG9tIjpmYWxzZSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6MCwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjoxLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOjAsInlhd19yaWdodCI6MzYsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoIjoiUmFuZG9tIiwieWF3X3JhbmRvbSI6MzUsInlhd19zdGF0aWMiOjAsImRlZmVuc2l2ZV95YXdfc3BlZWQiOjEsIm1vZF9kbV9yaWdodCI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjAsImRlZmVuc2l2ZV95YXciOiJSYW5kb20iLCJkZWZlc2l2ZV9hYV9tb2RlIjoiQnVpbGRlciIsImRlZmVuc2l2ZV9waXRjaF9kZWxheSI6NCwieWF3X2xlZnQiOi00OCwiZGVmZXNpdmVfYWFfdHlwZSI6IkZvcmNlIiwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJ5YXdfZGVsYXkiOjQsIm1vZF9kbSI6MCwiZ3NfYm9keV9zbGlkZXIiOjEsInBpdGNoX3ZhbHVlIjowLCJnc19ib2R5X3lhd190eXBlIjoiSml0dGVyIn0seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiRGVsYXkiLCJtb2RfdHlwZSI6IkNlbnRlciIsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6MCwiZGVmZW5zaXZlX3lhd19kZWxheSI6NCwiZGVmZW5zaXZlIjp0cnVlLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJPZmYiLCJ5YXdfZGVsYXlfcmFuZG9tIjpmYWxzZSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6MCwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjoxLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOi0xOCwieWF3X3JpZ2h0IjozMCwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2giOiJLYXpha2giLCJ5YXdfcmFuZG9tIjoxMCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwibW9kX2RtX3JpZ2h0IjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3lhdyI6IlNwaW4iLCJkZWZlc2l2ZV9hYV9tb2RlIjoiQnVpbGRlciIsImRlZmVuc2l2ZV9waXRjaF9kZWxheSI6NCwieWF3X2xlZnQiOi0yNSwiZGVmZXNpdmVfYWFfdHlwZSI6IkZvcmNlIiwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJ5YXdfZGVsYXkiOjIsIm1vZF9kbSI6OSwiZ3NfYm9keV9zbGlkZXIiOjEsInBpdGNoX3ZhbHVlIjowLCJnc19ib2R5X3lhd190eXBlIjoiSml0dGVyIn0seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiRGVsYXkiLCJtb2RfdHlwZSI6IjMtV2F5IiwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjotMTgsImRlZmVuc2l2ZV95YXdfZGVsYXkiOjQsImRlZmVuc2l2ZSI6dHJ1ZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiU2ludXMiLCJ5YXdfZGVsYXlfcmFuZG9tIjp0cnVlLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3Ijo4MSwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjo2LCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOjAsInlhd19yaWdodCI6MzIsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoIjoiT2ZmIiwieWF3X3JhbmRvbSI6MTAsInlhd19zdGF0aWMiOjAsImRlZmVuc2l2ZV95YXdfc3BlZWQiOjEsIm1vZF9kbV9yaWdodCI6MTQsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJkZWZlbnNpdmVfeWF3IjoiT2ZmIiwiZGVmZXNpdmVfYWFfbW9kZSI6Ik1vZGUiLCJkZWZlbnNpdmVfcGl0Y2hfZGVsYXkiOjQsInlhd19sZWZ0IjotMjgsImRlZmVzaXZlX2FhX3R5cGUiOiJGb3JjZSIsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6dHJ1ZSwiaml0dGVyX2RlbGF5Ijo2LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjoxMTksInlhd19kZWxheSI6NiwibW9kX2RtIjotMTQsImdzX2JvZHlfc2xpZGVyIjoxLCJwaXRjaF92YWx1ZSI6MCwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciJ9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkwgJiBSIiwibW9kX3R5cGUiOiJDZW50ZXIiLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZSI6MCwibW9kX2RtX2xlZnQiOjAsImRlZmVuc2l2ZV95YXdfZGVsYXkiOjQsImRlZmVuc2l2ZSI6dHJ1ZSwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9hYV9zaW51c195YXciOjAsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjowLCJ5YXdfcmlnaHQiOjI1LCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaCI6IlVwIiwieWF3X3JhbmRvbSI6MTAsInlhd19zdGF0aWMiOjAsImRlZmVuc2l2ZV95YXdfc3BlZWQiOjEsIm1vZF9kbV9yaWdodCI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjAsImRlZmVuc2l2ZV95YXciOiIxODAiLCJkZWZlc2l2ZV9hYV9tb2RlIjoiQnVpbGRlciIsImRlZmVuc2l2ZV9waXRjaF9kZWxheSI6NCwieWF3X2xlZnQiOi0yMywiZGVmZXNpdmVfYWFfdHlwZSI6IkZvcmNlIiwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJ5YXdfZGVsYXkiOjQsIm1vZF9kbSI6NywiZ3NfYm9keV9zbGlkZXIiOi0xLCJwaXRjaF92YWx1ZSI6MCwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciJ9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkwgJiBSIiwibW9kX3R5cGUiOiJTa2l0dGVyIiwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjowLCJkZWZlbnNpdmVfeWF3X2RlbGF5Ijo0LCJkZWZlbnNpdmUiOnRydWUsImRlZmVzaXZlX2FhX21vZGVfdHlwZSI6Ik9mZiIsInlhd19kZWxheV9yYW5kb20iOmZhbHNlLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3IjowLCJkZWZlbnNpdmVfYWFfc2ludXNfc3BlZWQiOjEsImRlZmVuc2l2ZV95YXdfdmFsdWVfMSI6MCwieWF3X3JpZ2h0IjoyMSwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2giOiJPZmYiLCJ5YXdfcmFuZG9tIjoyMCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwibW9kX2RtX3JpZ2h0IjowLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3lhdyI6Ik9mZiIsImRlZmVzaXZlX2FhX21vZGUiOiJCdWlsZGVyIiwiZGVmZW5zaXZlX3BpdGNoX2RlbGF5Ijo0LCJ5YXdfbGVmdCI6LTE2LCJkZWZlc2l2ZV9hYV90eXBlIjoiT2ZmIiwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJ5YXdfZGVsYXkiOjQsIm1vZF9kbSI6NSwiZ3NfYm9keV9zbGlkZXIiOi0xLCJwaXRjaF92YWx1ZSI6MCwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciJ9XV0=')
end):depend(enabled)
--[[
buttom_secretus = groups.group_fl:button('Secret Preset', function() 
    config.import('W3sicHJlZGljdF9iaW5kIjpbMSwwLCJ+Il0sImFpcnN0b3AiOlsxLDAsIn4iXSwicHJlZGljdF93ZWFwb25zIjpbIn4iXSwicHJlZGljdF9jb25kaXRpb25zIjpbIn4iXSwiZGVmZW5zaXZlX2ZpeCI6dHJ1ZSwicmVzb2x2ZXJfdHlwZSI6Ij8/PyIsInJlc29sdmVyIjp0cnVlLCJwcmVkaWN0X3R5cGUiOiJEZWZhdWx0IiwicHJlZGljdGlvbl9zeXN0ZW0iOmZhbHNlfSx7ImZha2VfbGFnc19hbW91bnQiOiJNYXhpbXVtIiwiYWRkb25zIjpbIldhcm11cCBBbnRpLUFpbSIsIkFudGkgQmFja3N0YWIiLCJTYWZlIEhlYWQiLCJ+Il0sIm1hbnVhbHNfbWFuaXB1bGF0aW9ucyI6dHJ1ZSwia2V5X2xlZnQiOlsxLDkwLCJ+Il0sImRlZmVuc2l2ZV9mbGlja190eXBlIjoiTGVmdCIsImZha2VfbGFncyI6dHJ1ZSwia2V5X2ZyZWVzdGFuZCI6WzIsMCwifiJdLCJ5YXdfYmFzZSI6IkF0IFRhcmdldHMiLCJkZWZlbnNpdmVfZmxpY2tfdmFsdWUiOjAsImtleV9mb3J3YXJkIjpbMSwwLCJ+Il0sImRlZmVuc2l2ZV9mbGljayI6ZmFsc2UsImtleV9yaWdodCI6WzEsODgsIn4iXSwic2FmZV9oZWFkIjpbIkFpcitDIEtuaWZlIiwifiJdLCJhYV9zZWxlY3QiOiJNYWluIiwiZGVmZW5zaXZlX2ZsaWNrX3RpY2tzIjoxLCJmYWtlX2xhZ3NfdmFyaWFuY2UiOjEwLCJkZWZlbnNpdmVfZmxpY2tfa2V5IjpbMSwwLCJ+Il0sImZha2VfbGFnc19saW1pdCI6MTV9LHsiemV1c193YXJuaW5nIjp0cnVlLCJicmFuZGVkX3dhdGVybWFya19wb3MiOiJCb3R0b20iLCJ2ZWxvY2l0eV93YXJuaW5nIjp0cnVlLCJsb2dfdHlwZSI6WyJIaXQiLCJNaXNzIiwifiJdLCJtYW51YWxfaW5kaWNhdG9yc19jIjoiIzlCOUJGRkZGIiwiY3Jvc3NfaW5kIjp0cnVlLCJhbmltYXRpb24iOnRydWUsIm1hbnVhbF9pbmRpY2F0b3JzX3R5cGUiOiJNb2Rlcm4iLCJ0aGlyZF9wZXJzb25fdmFsdWUiOjc1LCJidXlfYm90X3NlY29uZGFyeSI6IlJldm9sdmVyXC9EZWFnbGUiLCJidXlfYm90X3ByaW1hcnkiOiJTY291dCIsImNyb3NzX2luZF9jIjoiI0RFOEFBOEZGIiwiYnJhbmRlZF93YXRlcm1hcmtfcG9zX2MiOiIjOUI5QkZGRkYiLCJidXlfYm90X290aGVyIjpbIktldmxhciIsIkhlbG1ldCIsIkRlZnVzZSBLaXQiLCJHcmVuYWRlIiwiTW9sb3RvdiIsIlNtb2tlIiwiVGFzZXIiLCJ+Il0sImJ1eV9ib3QiOnRydWUsImtpbGxzYXkiOnRydWUsImhpdG1hcmtlciI6dHJ1ZSwiYW5pbWF0aW9uX2FpciI6IlN0YXRpYyIsIm1hbnVhbF9pbmRpY2F0b3JzX3ZlbG9jaXR5Ijp0cnVlLCJmYXN0X2xhZGRlciI6dHJ1ZSwiZGVmZW5zaXZlX2luZGljYXRvciI6dHJ1ZSwiYXNwZWN0cmF0aW8iOnRydWUsInRoaXJkX3BlcnNvbiI6dHJ1ZSwiY3Jvc3NfaW5kX2dyYWRpZW50Ijp0cnVlLCJhc3BlY3RyYXRpb192YWx1ZSI6MTI1LCJmcHNfYm9vc3QiOnRydWUsImhpdG1hcmtlcl9jIjoiIzlCOUJGRkZGIiwibWFudWFsX2luZGljYXRvcnMiOnRydWUsImNsYW5fdGFnIjp0cnVlLCJhbmltYXRpb25fZ3JvdW5kIjoiU3RhdGljIn0sW3siZW5hYmxlIjpmYWxzZSwieWF3X3R5cGUiOiJTdGF0aWMiLCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaCI6Ik9mZiIsInBpdGNoX3ZhbHVlIjowLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjAsImRlZmVuc2l2ZV9waXRjaF92YWx1ZSI6MCwibW9kX2RtX2xlZnQiOjAsImdzX2JvZHlfc2xpZGVyIjowLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOjAsImRlZmVzaXZlX2FhX3R5cGUiOiJPZmYiLCJnc19ib2R5X3lhd190eXBlIjoiT2ZmIiwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6MCwieWF3X2RlbGF5Ijo0LCJtb2RfZG1fcmlnaHQiOjAsImRlZmVzaXZlX2FhX21vZGUiOiJCdWlsZGVyIiwiZGVmZW5zaXZlX3lhdyI6Ik9mZiIsImRlZmVzaXZlX2FhX21vZGVfdHlwZSI6Ik9mZiIsImRlZmVuc2l2ZSI6ZmFsc2UsInlhd19kZWxheV9yYW5kb20iOmZhbHNlLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWVfMiI6MCwieWF3X21vZGlmZXJfZGVsYXlfcmFuZG9tIjpmYWxzZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfc3BlZWQiOjEsIm1vZF90eXBlIjoiT2ZmIiwibW9kX2RtIjowLCJ5YXdfbGVmdCI6MCwieWF3X3JpZ2h0IjowLCJ5YXdfcmFuZG9tIjowfSx7ImVuYWJsZSI6dHJ1ZSwieWF3X3R5cGUiOiJEZWxheSIsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoIjoiT2ZmIiwicGl0Y2hfdmFsdWUiOjAsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6LTE0LCJnc19ib2R5X3NsaWRlciI6LTEsImRlZmVuc2l2ZV95YXdfdmFsdWVfMSI6MCwiZGVmZXNpdmVfYWFfdHlwZSI6IkZvcmNlIiwiZ3NfYm9keV95YXdfdHlwZSI6IkppdHRlciIsImRlZmVuc2l2ZV9hYV9zaW51c19hbXBsaXR1ZGUiOjEwOCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6LTE0LCJ5YXdfZGVsYXkiOjIsIm1vZF9kbV9yaWdodCI6LTIxLCJkZWZlc2l2ZV9hYV9tb2RlIjoiTW9kZSIsImRlZmVuc2l2ZV95YXciOiJPZmYiLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJTaW51cyIsImRlZmVuc2l2ZSI6dHJ1ZSwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJ5YXdfbW9kaWZlcl9kZWxheV9yYW5kb20iOnRydWUsImppdHRlcl9kZWxheSI6MywiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjo5LCJtb2RfdHlwZSI6IkRlbGF5IENlbnRlciIsIm1vZF9kbSI6MCwieWF3X2xlZnQiOi0yOCwieWF3X3JpZ2h0IjozNCwieWF3X3JhbmRvbSI6Mjh9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkRlbGF5IiwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2giOiJEb3duIiwicGl0Y2hfdmFsdWUiOjAsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MTMsImRlZmVuc2l2ZV9waXRjaF92YWx1ZSI6MCwibW9kX2RtX2xlZnQiOi0zMiwiZ3NfYm9keV9zbGlkZXIiOjEsImRlZmVuc2l2ZV95YXdfdmFsdWVfMSI6LTEwLCJkZWZlc2l2ZV9hYV90eXBlIjoiRm9yY2UiLCJnc19ib2R5X3lhd190eXBlIjoiSml0dGVyIiwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MTIwLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3Ijo3MCwieWF3X2RlbGF5IjoyLCJtb2RfZG1fcmlnaHQiOjIzLCJkZWZlc2l2ZV9hYV9tb2RlIjoiTW9kZSIsImRlZmVuc2l2ZV95YXciOiJKaXR0ZXIiLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJTaW51cyIsImRlZmVuc2l2ZSI6dHJ1ZSwieWF3X2RlbGF5X3JhbmRvbSI6dHJ1ZSwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjAsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6dHJ1ZSwiaml0dGVyX2RlbGF5Ijo0LCJkZWZlbnNpdmVfYWFfc2ludXNfc3BlZWQiOjEwLCJtb2RfdHlwZSI6IkRlbGF5IENlbnRlciIsIm1vZF9kbSI6NDgsInlhd19sZWZ0IjotMTIsInlhd19yaWdodCI6MTYsInlhd19yYW5kb20iOjE2fSx7ImVuYWJsZSI6dHJ1ZSwieWF3X3R5cGUiOiJMICYgUiIsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoIjoiQ3VzdG9tIiwicGl0Y2hfdmFsdWUiOjAsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MTU4LCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOi02MCwibW9kX2RtX2xlZnQiOjAsImdzX2JvZHlfc2xpZGVyIjowLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOi0xODAsImRlZmVzaXZlX2FhX3R5cGUiOiJGb3JjZSIsImdzX2JvZHlfeWF3X3R5cGUiOiJPZmYiLCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjowLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3IjowLCJ5YXdfZGVsYXkiOjQsIm1vZF9kbV9yaWdodCI6MCwiZGVmZXNpdmVfYWFfbW9kZSI6IkJ1aWxkZXIiLCJkZWZlbnNpdmVfeWF3IjoiU2VjcmV0IiwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwiZGVmZW5zaXZlIjp0cnVlLCJ5YXdfZGVsYXlfcmFuZG9tIjpmYWxzZSwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjAsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6ZmFsc2UsImppdHRlcl9kZWxheSI6NCwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjoxLCJtb2RfdHlwZSI6IkNlbnRlciIsIm1vZF9kbSI6MCwieWF3X2xlZnQiOi05LCJ5YXdfcmlnaHQiOjEyLCJ5YXdfcmFuZG9tIjoxN30seyJlbmFibGUiOnRydWUsInlhd190eXBlIjoiTCAmIFIiLCJwaXRjaF90eXBlIjoiRG93biIsImRlZmVuc2l2ZV9waXRjaCI6IkthemFraCIsInBpdGNoX3ZhbHVlIjowLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzIiOjkwLCJkZWZlbnNpdmVfcGl0Y2hfdmFsdWUiOjAsIm1vZF9kbV9sZWZ0IjowLCJnc19ib2R5X3NsaWRlciI6MCwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjotMTA5LCJkZWZlc2l2ZV9hYV90eXBlIjoiRm9yY2UiLCJnc19ib2R5X3lhd190eXBlIjoiT2ZmIiwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6MCwieWF3X2RlbGF5Ijo0LCJtb2RfZG1fcmlnaHQiOjAsImRlZmVzaXZlX2FhX21vZGUiOiJCdWlsZGVyIiwiZGVmZW5zaXZlX3lhdyI6IlNlY3JldCIsImRlZmVzaXZlX2FhX21vZGVfdHlwZSI6Ik9mZiIsImRlZmVuc2l2ZSI6dHJ1ZSwieWF3X2RlbGF5X3JhbmRvbSI6ZmFsc2UsImRlZmVuc2l2ZV9waXRjaF92YWx1ZV8yIjowLCJ5YXdfbW9kaWZlcl9kZWxheV9yYW5kb20iOmZhbHNlLCJqaXR0ZXJfZGVsYXkiOjQsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6MSwibW9kX3R5cGUiOiJDZW50ZXIiLCJtb2RfZG0iOi0yMSwieWF3X2xlZnQiOi03LCJ5YXdfcmlnaHQiOjcsInlhd19yYW5kb20iOjV9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkRlbGF5IiwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2giOiJKaXR0ZXIiLCJwaXRjaF92YWx1ZSI6MCwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjo4NywiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjotNzYsIm1vZF9kbV9sZWZ0IjotMzQsImdzX2JvZHlfc2xpZGVyIjowLCJkZWZlbnNpdmVfeWF3X3ZhbHVlXzEiOi0xMjksImRlZmVzaXZlX2FhX3R5cGUiOiJGb3JjZSIsImdzX2JvZHlfeWF3X3R5cGUiOiJPZmYiLCJkZWZlbnNpdmVfYWFfc2ludXNfYW1wbGl0dWRlIjo0NywieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6LTQzLCJ5YXdfZGVsYXkiOjMsIm1vZF9kbV9yaWdodCI6MjgsImRlZmVzaXZlX2FhX21vZGUiOiJCdWlsZGVyIiwiZGVmZW5zaXZlX3lhdyI6IlNwaW4iLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJTaW51cyIsImRlZmVuc2l2ZSI6dHJ1ZSwieWF3X2RlbGF5X3JhbmRvbSI6dHJ1ZSwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjY4LCJ5YXdfbW9kaWZlcl9kZWxheV9yYW5kb20iOnRydWUsImppdHRlcl9kZWxheSI6NCwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjo5LCJtb2RfdHlwZSI6IkRlbGF5IENlbnRlciIsIm1vZF9kbSI6MzcsInlhd19sZWZ0IjotMTgsInlhd19yaWdodCI6MTgsInlhd19yYW5kb20iOjEyfSx7ImVuYWJsZSI6dHJ1ZSwieWF3X3R5cGUiOiJMICYgUiIsInBpdGNoX3R5cGUiOiJEb3duIiwiZGVmZW5zaXZlX3BpdGNoIjoiS2F6YWtoIiwicGl0Y2hfdmFsdWUiOjAsImRlZmVuc2l2ZV95YXdfdmFsdWVfMiI6MCwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjowLCJtb2RfZG1fbGVmdCI6LTksImdzX2JvZHlfc2xpZGVyIjotMSwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjotMTIwLCJkZWZlc2l2ZV9hYV90eXBlIjoiRm9yY2UiLCJnc19ib2R5X3lhd190eXBlIjoiSml0dGVyIiwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MCwieWF3X3N0YXRpYyI6MCwiZGVmZW5zaXZlX3lhd19zcGVlZCI6MSwiZGVmZW5zaXZlX2FhX3NpbnVzX3lhdyI6MCwieWF3X2RlbGF5Ijo0LCJtb2RfZG1fcmlnaHQiOjE2LCJkZWZlc2l2ZV9hYV9tb2RlIjoiQnVpbGRlciIsImRlZmVuc2l2ZV95YXciOiJTcGluIiwiZGVmZXNpdmVfYWFfbW9kZV90eXBlIjoiT2ZmIiwiZGVmZW5zaXZlIjp0cnVlLCJ5YXdfZGVsYXlfcmFuZG9tIjpmYWxzZSwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjAsInlhd19tb2RpZmVyX2RlbGF5X3JhbmRvbSI6ZmFsc2UsImppdHRlcl9kZWxheSI6MiwiZGVmZW5zaXZlX2FhX3NpbnVzX3NwZWVkIjoxLCJtb2RfdHlwZSI6IkRlbGF5IENlbnRlciIsIm1vZF9kbSI6MCwieWF3X2xlZnQiOi01LCJ5YXdfcmlnaHQiOjUsInlhd19yYW5kb20iOjd9LHsiZW5hYmxlIjp0cnVlLCJ5YXdfdHlwZSI6IkRlbGF5IiwicGl0Y2hfdHlwZSI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2giOiJKaXR0ZXIiLCJwaXRjaF92YWx1ZSI6MCwiZGVmZW5zaXZlX3lhd192YWx1ZV8yIjoxMiwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlIjotNzYsIm1vZF9kbV9sZWZ0IjowLCJnc19ib2R5X3NsaWRlciI6MCwiZGVmZW5zaXZlX3lhd192YWx1ZV8xIjotMTM4LCJkZWZlc2l2ZV9hYV90eXBlIjoiRm9yY2UiLCJnc19ib2R5X3lhd190eXBlIjoiT2ZmIiwiZGVmZW5zaXZlX2FhX3NpbnVzX2FtcGxpdHVkZSI6MTIwLCJ5YXdfc3RhdGljIjowLCJkZWZlbnNpdmVfeWF3X3NwZWVkIjoxLCJkZWZlbnNpdmVfYWFfc2ludXNfeWF3IjoyOCwieWF3X2RlbGF5IjozLCJtb2RfZG1fcmlnaHQiOjAsImRlZmVzaXZlX2FhX21vZGUiOiJNb2RlIiwiZGVmZW5zaXZlX3lhdyI6IlNwaW4iLCJkZWZlc2l2ZV9hYV9tb2RlX3R5cGUiOiJTaW51cyIsImRlZmVuc2l2ZSI6dHJ1ZSwieWF3X2RlbGF5X3JhbmRvbSI6dHJ1ZSwiZGVmZW5zaXZlX3BpdGNoX3ZhbHVlXzIiOjY2LCJ5YXdfbW9kaWZlcl9kZWxheV9yYW5kb20iOmZhbHNlLCJqaXR0ZXJfZGVsYXkiOjQsImRlZmVuc2l2ZV9hYV9zaW51c19zcGVlZCI6OSwibW9kX3R5cGUiOiJTa2l0dGVyIiwibW9kX2RtIjotNywieWF3X2xlZnQiOjcsInlhd19yaWdodCI6LTUsInlhd19yYW5kb20iOjEwfV1d')
end):depend(enabled)]]

function menu_logic()
    ui.set_visible(ref.flEnabled[1], false)
    ui.set_visible(ref.flEnabled[2], false)
    ui.set_visible(ref.flLimit, false)
    ui.set_visible(ref.flVariance, false)
    ui.set_visible(ref.flAmount, false)

    if lua_ui.main.main_checkbox:get() then
        ui.set_visible(ref.enabled, false)
        ui.set_visible(ref.pitch[1], false)
        ui.set_visible(ref.roll[1], false)
        ui.set_visible(ref.yawbase, false)
        ui.set_visible(ref.yaw[1], false)
        ui.set_visible(ref.fsbodyyaw, false)
        ui.set_visible(ref.yawjitter[1], false)
        ui.set_visible(ref.bodyyaw[1], false)
        ui.set_visible(ref.freestand[1], false)
        ui.set_visible(ref.edgeyaw, false)
        ui.set_visible(ref.pitch[2], false)
        ui.set_visible(ref.yaw[2], false)
        ui.set_visible(ref.yawjitter[2], false)
        ui.set_visible(ref.bodyyaw[2], false)
        ui.set_visible(ref.freestand[2], false)
    else
        ui.set_visible(ref.enabled, true)
        ui.set_visible(ref.pitch[1], true)
        ui.set_visible(ref.roll[1], true)
        ui.set_visible(ref.yawbase, true)
        ui.set_visible(ref.yaw[1], true)
        ui.set_visible(ref.fsbodyyaw, true)
        ui.set_visible(ref.yawjitter[1], true)
        ui.set_visible(ref.bodyyaw[1], true)
        ui.set_visible(ref.freestand[1], true)
        ui.set_visible(ref.edgeyaw, true)
        ui.set_visible(ref.pitch[2], true)
        ui.set_visible(ref.yaw[2], true)
        ui.set_visible(ref.yawjitter[2], true)
        ui.set_visible(ref.bodyyaw[2], true)
        ui.set_visible(ref.freestand[2], true)
    end
end

--region resolver

local native_GetClientEntity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*, int)')

math.clamp = function (x, a, b)
    if a > x then return a
    elseif b < x then return b
    else return x end
end

local expres = {}

expres.get_prev_simtime = function(ent)
    local ent_ptr = native_GetClientEntity(ent)    
    if ent_ptr ~= nil then 
        return libs.ffi_lib.cast('float*', libs.ffi_lib.cast('uintptr_t', ent_ptr) + 0x26C)[0] 
    end
end

expres.restore = function()
    for i = 1, 64 do
        plist.set(i, "Force body yaw", false)
    end
end

expres.body_yaw, expres.eye_angles = {}, {}

expres.get_max_desync = function (animstate)
    local speedfactor = math.clamp(animstate.feet_speed_forwards_or_sideways, 0, 1)
    local avg_speedfactor = (animstate.stop_to_full_running_fraction * -0.3 - 0.2) * speedfactor + 1

    local duck_amount = animstate.duck_amount
    if duck_amount > 0 then
        avg_speedfactor = avg_speedfactor + (duck_amount * speedfactor * (0.5 - avg_speedfactor))
    end

    return math.clamp(avg_speedfactor, .5, 1)
end

local gReason = 'none'
local resolving_value = 58
local already_toggled = false

client.set_event_callback("aim_miss", function(e)
    gReason = e.reason
    already_toggled = false
end)

expres.handle = function(current_threat)
    if current_threat == nil or not entity.is_alive(current_threat) or entity.is_dormant(current_threat) or not lua_ui.ragebot.resolver:get() then 
        expres.restore()
        return 
    end

    if expres.body_yaw[current_threat] == nil then 
        expres.body_yaw[current_threat], expres.eye_angles[current_threat] = {}, {}
    end

    local simtime = toticks(entity.get_prop(current_threat, 'm_flSimulationTime'))
    local prev_simtime = toticks(expres.get_prev_simtime(current_threat))
    
    expres.body_yaw[current_threat][simtime] = entity.get_prop(current_threat, 'm_flPoseParameter', 11) * 120 - 60
    expres.eye_angles[current_threat][simtime] = select(2, entity.get_prop(current_threat, "m_angEyeAngles"))

    if expres.body_yaw[current_threat][prev_simtime] ~= nil then
        local ent = libs.c_entity.new(current_threat)
        local animstate = ent:get_anim_state()
        local max_desync = expres.get_max_desync(animstate)
        local Pitch = entity.get_prop(current_threat, "m_angEyeAngles[0]")
        local pitch_e = Pitch > -30 and Pitch < 49
        local curr_side = globals.tickcount() % 4 > 1 and 1 or -1

        if lua_ui.ragebot.resolver:get() then
            if lua_ui.ragebot.resolver_type:get() == "???" then
                if gReason == '?' and not already_toggled then
                    resolving_value = -resolving_value
                    already_toggled = true
                end
                local value_body = resolving_value
                plist.set(current_threat, 'Force body yaw', true)
                if pitch_e then
                    plist.set(current_threat, 'Force body yaw value', 0)
                else
                    plist.set(current_threat, 'Force body yaw value', value_body) 
                end
            elseif lua_ui.ragebot.resolver_type:get() == "Default" then
                local value_body = 0
                if pitch_e then
                    value_body = 0
                else
                    value_body = curr_side * (max_desync * math.random(0, 58))
                end
                plist.set(current_threat, 'Force body yaw', true)
                plist.set(current_threat, 'Force body yaw value', value_body)
                plist.set(current_threat, 'Correction active', true)
            end
        else
            plist.set(current_threat, 'Force body yaw', false)
        end
        plist.set(current_threat, 'Correction active', true)
    end
end

local function resolver_update()
    local lp = entity.get_local_player()
    if not lp then return end
    local entities = entity.get_players(true)
    if not entities then return end

    for i = 1, #entities do
        local target = entities[i]
        if not target then return end
        if not entity.is_alive(target) then return end
        expres.handle(target)
    end
end

--region misc

local function check_charge()
    local lp = entity.get_local_player()
    local m_nTickBase = entity.get_prop(lp, 'm_nTickBase')
    local client_latency = client.latency()
    local shift = math.floor(m_nTickBase - globals.tickcount() - 3 - toticks(client_latency) * .5 + .5 * (client_latency * 10))
    local wanted = -14 + (ui.get(ref.fakelag_limit) - 1) + 3
    return shift <= wanted
end

local is_hittable = false
local charge_state = false

local function unsafe_charge(cmd)
    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then return end

    local threat = client.current_threat()
    local in_air = bit.band(entity.get_prop(lp, 'm_fFlags'), 1) == 0
    
    if threat then
        is_hittable = bit.band(entity.get_esp_data(threat).flags, bit.lshift(1, 11)) == 2048
    else
        is_hittable = false
    end

    if is_hittable and not check_charge() and ui.get(ref.dt[1]) and ui.get(ref.dt[2]) and in_air then
        ui.set(ref.aimbot, false)
        charge_state = true
    else
        ui.set(ref.aimbot, true)
        charge_state = false
    end
end

function auto_tp(cmd)
    local lp = entity.get_local_player()
    if lp == nil then return end
    local flags = entity.get_prop(lp, 'm_fFlags')
    local jumpcheck = bit.band(flags, 1) == 0
    if is_vulnerable() and jumpcheck then
        cmd.force_defensive = true
        cmd.discharge_pending = true
    end
end

--region visuals

function lerp(a, b, t)
    return a + (b - a) * t
end

function clamp(x, minval, maxval)
    if x < minval then
        return minval
    elseif x > maxval then
        return maxval
    else
        return x
    end
end

local rec = function(x, y, w, h, radius, color)
    radius = math.min(x / 2, y / 2, radius)
    local r, g, b, a = unpack(color)
    
    renderer.rectangle(x, y + radius, w, h - radius * 2, r, g, b, a)
    renderer.rectangle(x + radius, y, w - radius * 2, radius, r, g, b, a)
    renderer.rectangle(x + radius, y + h - radius, w - radius * 2, radius, r, g, b, a)

    renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
    renderer.circle(x + w - radius, y + radius, r, g, b, a, radius, 90, 0.25)
    renderer.circle(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25)
    renderer.circle(x + radius, y + h - radius, r, g, b, a, radius, -90, 0.25)
end

local rec_outline = function(x, y, w, h, radius, thickness, color)
    radius = math.min(w / 2, h / 2, radius)
    local r, g, b, a = unpack(color)
    
    if radius == 1 then
        renderer.rectangle(x, y, w, thickness, r, g, b, a)
        renderer.rectangle(x, y + h - thickness, w, thickness, r, g, b, a)
    else
        renderer.rectangle(x + radius, y, w - radius * 2, thickness, r, g, b, a)
        renderer.rectangle(x + radius, y + h - thickness, w - radius * 2, thickness, r, g, b, a)
        renderer.rectangle(x, y + radius, thickness, h - radius * 2, r, g, b, a)
        renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius * 2, r, g, b, a)

        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
    end
end

local glow_module = function(x, y, w, h, width, rounding, accent, accent_inner)
    local r, g, b, a = unpack(accent)
    local thickness = 1
    local offset = 1
    
    if accent_inner then
        rec(x, y, w, h + 1, rounding, accent_inner)
    end
    
    local max_alpha = a
    local width_offset = width - 1
    
    for k = 0, width do
        local alpha = max_alpha * (k / width) ^ 2
        if alpha > 5 then
            local accent_color = {r, g, b, alpha}
            rec_outline(x + (k - width_offset - offset) * thickness, 
                        y + (k - width_offset - offset) * thickness, 
                        w - (k - width_offset - offset) * thickness * 2, 
                        h + 1 - (k - width_offset - offset) * thickness * 2, 
                        rounding + thickness * (width - k + offset), 
                        thickness, accent_color)
        end
    end
end

local function text_fade_animation(x, y, speed, color1, color2, text, flag)
    local final_text = ''
    local curtime = globals.curtime()
    for i = 0, #text do
        local x = i * 10  
        local wave = math.cos(8 * speed * curtime + x / 30)
        local color = rgba_to_hex(
            lerp(color1.r, color2.r, clamp(wave, 0, 1)),
            lerp(color1.g, color2.g, clamp(wave, 0, 1)),
            lerp(color1.b, color2.b, clamp(wave, 0, 1)),
            color1.a
        ) 
        final_text = final_text .. '\a' .. color .. text:sub(i, i) 
    end
    
    renderer.text(x, y, color1.r, color1.g, color1.b, color1.a, flag, nil, final_text)
end

math.lerp = function(name, value, speed)
    return name + (value - name) * globals.absoluteframetime() * speed
end

local scoped_space = 0
local screen = {client.screen_size()}
local center = {screen[1]/2, screen[2]/2} 

local function crosshair_indicators()
    local lp = entity.get_local_player()
    if lp == nil then return end
    if not entity.is_alive(lp) then return end
    local ind_size = renderer.measure_text('cb', 'Nyctophobia')
    local scpd = entity.get_prop(lp, 'm_bIsScoped') == 1
    scoped_space = math.lerp(scoped_space, scpd and 20 or 0, 20)
    local condition = 'SHARED'
    if id == 1 then condition = 'SHARED'
    elseif id == 2 then condition = 'STANDING'
    elseif id == 3 then condition = 'RUNNING'
    elseif id == 4 then condition = 'WALKING'
    elseif id == 5 then condition = 'AEROBIC'
    elseif id == 6 then condition = 'AEROBIC+'
    elseif id == 7 then condition = 'DUCKING'
    elseif id == 8 then condition = 'SNEAKING' end
    local spaceind = 8

    main_font = 'c-'
    key_font = 'c-'
    
    local new_check = false
    local r1, g1, b1, a1 = 200, 200, 200, 255
    local r2, g2, b2, a2 = lua_ui.other.cross_ind:get_color()
    local r3, g3, b3, a3 = 255, 255, 255, 255
    local r, g, b, a = 255, 255, 255, 255

    if lua_ui.other.cross_ind_gradient:get() then
        text_fade_animation(center[1] + scoped_space, center[2] + 25, -1, {r=r1, g=g1, b=b1, a=255}, {r=r2, g=g2, b=b2, a=255}, new_check and string.upper('Nyctophobia') or 'Nyctophobia', main_font)
    else
        renderer.text(center[1] + scoped_space, center[2] + 25, r2, g2, b2, 255, main_font, 0, 'Nyctophobia')
    end

    renderer.text(center[1] + scoped_space, center[2] + 25 + (spaceind), 255, 255, 255, 255, main_font, 0, condition)
    spaceind = spaceind - 2

    if ui.get(ref.forcebaim)then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), 255, 100, 100, 255, key_font, 0, new_check and 'BAIM' or 'BAIM')
        spaceind = spaceind + 8
    end

    if ui.get(ref.safepoint)then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), 255, 100, 100, 255, key_font, 0, new_check and 'SAFE' or 'SAFE')
        spaceind = spaceind + 8
    end

    if ui.get(ref.ping_spike[1]) and ui.get(ref.ping_spike[2]) then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), 100, 170, 100, 255, key_font, 0, new_check and 'PING' or 'PING')
        spaceind = spaceind + 8
    end

    if ui.get(ref.dt[1]) and ui.get(ref.dt[2]) then
        if exploit_charged() then
            renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), r3, g3, b3, a, key_font, 0, new_check and 'DT' or 'DT')
        else
            renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), 255, 0, 0, 255, key_font, 0, new_check and 'DT' or 'DT')
        end
        spaceind = spaceind + 8
    elseif ui.get(ref.os[2]) then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), r3, g3, b3, a, key_font, 0, new_check and 'OSAA' or 'OSAA')
        spaceind = spaceind + 8
    end

    if ui.get(ref.autopeek[1]) and ui.get(ref.autopeek[2]) then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), r3, g3, b3, 255, key_font, 0, new_check and 'PEEK' or 'PEEK')
        spaceind = spaceind + 8
    end

    if ui.get(ref.minimum_damage_override[2]) then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), r3, g3, b3, 255, key_font, 0, new_check and 'DMG' or'DMG')
        spaceind = spaceind + 8
    end

    if ui.get(ref.freestand[1]) and ui.get(ref.freestand[2]) then
        renderer.text(center[1] + scoped_space, center[2] + 35 + (spaceind), r3, g3, b3, a, key_font, 0, new_check and 'FS' or 'FS')
        spaceind = spaceind + 8
    end
end

local scoped_space_manual = 0

local function manual_indicator()
    local r2, g2, b2, a2 = lua_ui.other.manual_indicators:get_color()
    local lp = entity.get_local_player()
    if not lp then return end
    if not entity.is_alive(lp) then return end    local vecvelocity = { entity.get_prop(lp, 'm_vecVelocity') }
    local man_velocity = string.format('%d', math.sqrt(vecvelocity[1]^2+vecvelocity[2]^2))
    local scpd = entity.get_prop(lp, 'm_bIsScoped') == 1
    scoped_space_manual = math.lerp(scoped_space_manual, scpd and 15 or 0, 10)

    if lua_ui.other.manual_indicators:get() then
        if lua_ui.other.manual_indicators_type:get() == 'Modern' then
            if yaw_direction == 90 then
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] + 60, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '❱')
                else
                    renderer.text(center[1] + 60 + man_velocity/7, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '❱')
                end
            else
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] + 60, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '❱')
                else
                    renderer.text(center[1] + 60 + man_velocity/7, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '❱')
                end
            end
            if yaw_direction == -90 then
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] - 60, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '❰')
                else
                    renderer.text(center[1] - 60 - man_velocity/7, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '❰')
                end
            else
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] - 60, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '❰')
                else
                    renderer.text(center[1] - 60 - man_velocity/7, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '❰')
                end
            end
        elseif lua_ui.other.manual_indicators_type:get() == 'Classic' then
            if yaw_direction == 90 then
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] + 60, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '>')
                else
                    renderer.text(center[1] + 60 + man_velocity/7, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '>')
                end
            else
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] + 60, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '>')
                else
                    renderer.text(center[1] + 60 + man_velocity/7, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '>')
                end
            end
            if yaw_direction == -90 then
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] - 60, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '<')
                else
                    renderer.text(center[1] - 60 - man_velocity/7, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '<')
                end
            else
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] - 60, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '<')
                else
                    renderer.text(center[1] - 60 - man_velocity/7, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '<')
                end
            end
        elseif lua_ui.other.manual_indicators_type:get() == 'Meme' then
            if yaw_direction == 90 then
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] + 60, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '☛')
                else
                    renderer.text(center[1] + 60 + man_velocity/7, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '☛')
                end
            else
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] + 60, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '☛')
                else
                    renderer.text(center[1] + 60 + man_velocity/7, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '☛')
                end
            end
            if yaw_direction == -90 then
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] - 60, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '☚')
                else
                    renderer.text(center[1] - 60 - man_velocity/7, center[2] - scoped_space_manual, r2, g2, b2, 255, 'c+', 0, '☚')
                end
            else
                if not lua_ui.other.manual_indicators_velocity:get() then
                    renderer.text(center[1] - 60, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '☚')
                else
                    renderer.text(center[1] - 60 - man_velocity/7, center[2] - scoped_space_manual, 100, 100, 100, 100, 'c+', 0, '☚')
                end
            end
        end
    end
end

local function watermark()
    local me = entity.get_local_player()
    if me == nil then return end
    if not lua_ui.main.main_checkbox:get() then return end
    local r, g, b = lua_ui.other.branded_watermark_pos:get_color()
    local width, height = client.screen_size()
    local r2, g2, b2, a2 = 55, 55, 55,255
    local highlight_fraction =  (globals.realtime() / 2 % 1.2 * 2) - 1.2
    local output = ''
    local text_to_draw = 'N Y C T O P H O B I A'
    if not entity.is_alive(me) then return end
    for idx = 1, #text_to_draw do
        local character = text_to_draw:sub(idx, idx)
        local character_fraction = idx / #text_to_draw
        local r1, g1, b1, a1 = lua_ui.other.branded_watermark_pos:get_color()
        local highlight_delta = (character_fraction - highlight_fraction)
        if highlight_delta >= 0 and highlight_delta <= 1.4 then
            if highlight_delta > 0.7 then
            highlight_delta = 1.4 - highlight_delta
            end
            local r_fraction, g_fraction, b_fraction, a_fraction = r2 - r1, g2 - g1, b2 - b1
            r1 = r1 + r_fraction * highlight_delta / 0.8
            g1 = g1 + g_fraction * highlight_delta / 0.8
            b1 = b1 + b_fraction * highlight_delta / 0.8
        end
        output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, 255, text_to_draw:sub(idx, idx))
    end
    output = output
    
    local r,g,b,a = 87, 235, 61
    if lua_ui.other.branded_watermark_pos:get() == 'Left' then
        renderer.text(width - (width-90), height - 660, r, g, b, 255, 'c', 0, output .. ' \aFFA0A0FF['..string.upper(build)..']')
    elseif lua_ui.other.branded_watermark_pos:get() == 'Bottom' then
        renderer.text(width/2, height - 30, r, g, b, 255, 'c', 0, output .. ' \aFFA0A0FF['..string.upper(build)..']')
    elseif lua_ui.other.branded_watermark_pos:get() == 'Right' then
        renderer.text(width - width/30, height - 660, r, g, b, 255, 'c', 0, output .. ' \aFFA0A0FF['..string.upper(build)..']')
    end
end

local defensive_alpha = 0
local defensive_amount = 0
local velocity_alpha = 0
local velocity_amount = 0

renderer.rounded_rectangle = function(x, y, w, h, r, g, b, a, radius)
    y = y + radius
    local data_circle = {
        {x + radius, y, 180},
        {x + w - radius, y, 90},
        {x + radius, y + h - radius * 2, 270},
        {x + w - radius, y + h - radius * 2, 0},
    }

    local data = {
        {x + radius, y, w - radius * 2, h - radius * 2},
        {x + radius, y - radius, w - radius * 2, radius},
        {x + radius, y + h - radius * 2, w - radius * 2, radius},
        {x, y, radius, h - radius * 2},
        {x + w - radius, y, radius, h - radius * 2},
    }

    for _, data in next, data_circle do
        renderer.circle(data[1], data[2], r, g, b, a, radius, data[3], 0.25)
    end

    for _, data in next, data do
        renderer.rectangle(data[1], data[2], data[3], data[4], r, g, b, a)
    end
end

local function velocity_ind()
    if not lua_ui.other.velocity_warning:get() then return end
    local lp = entity.get_local_player()
    if lp == nil then return end
    if not entity.is_alive(lp) then return end
    local r, g, b, a = lua_ui.other.velocity_warning:get_color()
    local vel_mod = entity.get_prop(lp, 'm_flVelocityModifier')
    local velocity = vel_mod * 100
    local alpha = math.min(math.floor(math.sin((globals.curtime()%3) * 10) * 175 + 50), 255)
    if velocity < 100 then
        renderer.text(center[1], screen[2] / 3 - 10, 255, 2.55*velocity, 2.55*velocity, alpha, 'c', 0, ' * velocity * ')
        renderer.rounded_rectangle(center[1]-100, screen[2] / 3, 200, 5, 0,0,0, 255, 3)
        renderer.rounded_rectangle(center[1]-98, screen[2] / 3 + 2, (velocity*2)-1, 2, r, g, b, 255, 2)
    elseif ui.is_menu_open() then
        renderer.text(center[1], screen[2] / 3 - 10, 255, 255, 255, alpha, 'c', 0, ' * velocity * ')
        renderer.rounded_rectangle(center[1]-100, screen[2] / 3, 200, 5, 0,0,0, 255, 3)
        renderer.rounded_rectangle(center[1]-98, screen[2] / 3 + 2, (100)-1, 2, r, g, b, 255, 2)
    end
end

local tickbase_maximum = 0

local function defensive_ind()
    if not lua_ui.other.defensive_indicator:get() then return end
    local lp = entity.get_local_player()
    if lp == nil then return end
    if not entity.is_alive(lp) then return end

    local tickbase_inds = entity.get_prop(entity.get_local_player(), 'm_nTickBase')

    if math.abs(tickbase_inds - tickbase_maximum) > 64 then
        tickbase_maximum = 0
    end

    local defensive_ticks_left_inds = 0;

    if tickbase_inds > tickbase_maximum then
        tickbase_maximum = tickbase_inds
    elseif tickbase_maximum > tickbase_inds then
        defensive_ticks_left_inds = math.min(14, math.max(0, tickbase_maximum-tickbase_inds-1))
    end

    local active = defensive_ticks_left_inds > 2

    local r, g, b, a = lua_ui.other.defensive_indicator:get_color()
    if not ui.is_menu_open() then
        if ui.get(ref.dt[1]) and ui.get(ref.dt[2]) or ui.get(ref.os[1]) and ui.get(ref.os[2]) or not ui.get(ref.fakeduck) then
            if exploit_charged() and active then
                defensive_alpha = math.lerp(255, 255, 30)
            elseif exploit_charged() and not active then
                defensive_alpha = math.lerp(150, 255, 30)
            else
                defensive_alpha = 0
            end
        else
            defensive_alpha = 0
        end
    else
        defensive_alpha = 255
    end
    if defensive_alpha == 255 then
        renderer.text(center[1], screen[2] / 3.5 - 10, 255, 255, 255, defensive_alpha, 'c', 0, '* defensive is safe *')
    end
    if defensive_alpha > 50 then
        renderer.rounded_rectangle(center[1]-100, screen[2] / 3.5, 200, 5, 0,0,0, 255, 3)
    end
    if defensive_alpha > 50 then
        if not ui.is_menu_open() then
            renderer.rounded_rectangle(center[1]-98, screen[2] / 3.5 + 2, 15*defensive_ticks_left_inds + 2, 2, r, g, b, 255, 2)
        else
            renderer.rounded_rectangle(center[1]-98, screen[2] / 3.5 + 2, 100, 2, r, g, b, 255, 2)
        end
    end
end

local function get_player_weapons(idx)
    local list = {}

    for i = 0, 64 do
        local cwpn = entity.get_prop(idx, 'm_hMyWeapons', i)

        if cwpn ~= nil then
            table.insert(list, cwpn)
        end
    end

    return list
end

client.set_event_callback('paint', function()
    local me = entity.get_local_player()

    if not lua_ui.other.zeus_warning:get() or me == nil or not entity.is_alive(me) then
        return
    end
    
    for _, i in pairs(entity.get_players(true)) do
        local esp_data = entity.get_esp_data(i)

        if esp_data ~= nil then
            local has_taser = 0
        
            local x1, y1, x2, y2, a = entity.get_bounding_box(i)

            if esp_data.weapon_id == 31 then
                has_taser = 2
            end

            local box_top_x, box_top_y, box_bottom_x, _, box_alpha = entity.get_bounding_box(i)

            if (box_top_x == nil or box_top_y == nil or box_alpha == 0) then
                return
            end
            local y_offset = -25
        
            local center_x = box_top_x / 2 + box_bottom_x / 2

            for _, v in pairs(get_player_weapons(i)) do
                if v ~= nil and has_taser == 0 and entity.get_prop(v, 'm_iItemDefinitionIndex') == 31 then
                    has_taser = 1
                end
            end

            if x1 ~= 0 and a > 0.000 and has_taser > 1 then
                if has_taser == 2 then
                    glow_module(center_x, box_top_y + y_offset,0.1,1, 35,12,{255,50,50,255}, {0,0,0,2})
                    renderer.text(center_x, box_top_y + y_offset, 0, 0, 0, 255, 'c+', 0, '!')
                end
            end
        end
    end
end)         

local queue = {}

local function aim_fire(c)
    queue[globals.tickcount()] = {c.x, c.y, c.z, globals.curtime() + 2}
end

local function paint(c)
    if not lua_ui.other.hitmarker:get() then return end
    local r1, g1, b1, a1 = lua_ui.other.hitmarker:get_color()

    for tick, data in pairs(queue) do
        if globals.curtime() <= data[4] then
            local x1_hit, y_hit = renderer.world_to_screen(data[1], data[2], data[3])
            if x1_hit ~= nil and y_hit ~= nil then
                if lua_ui.other.hitmarker_type:get() == 'Circle' then
                    local time_alive = globals.curtime() - (data[4] - 2)
                    local radius = math.max(4 - time_alive * 2, 1)
                    renderer.circle(x1_hit, y_hit, r1, g1, b1, 255, radius, 3, 3)
                elseif lua_ui.other.hitmarker_type:get() == 'Plus' then
			        renderer.line(x1_hit - 6,y_hit,x1_hit + 6,y_hit,r1,g1,b1,255)
			        renderer.line(x1_hit,y_hit - 6,x1_hit,y_hit + 6 ,r1,g1,b1,255)
                end
            end
        else
            queue[tick] = nil
        end
    end
end

client.set_event_callback("player_spawn", function()
    queue = {}
end)

--misc

local ct_anim = {
    '                  ',
    '                 N',
    '                Ny',
    '               Nyc',
    '              Nyct',
    '             Nycto',
    '            Nyctop',
    '           Nyctoph',
    '          Nyctopho ',
    '         Nyctophob  ',
    '        Nyctophobi   ',
    '       Nyctophobia    ',
    '      Nyctophobia     ',
    '     Nyctophobia      ',
    '    Nyctophobia       ',
    '   Nyctophobia        ',
    '  Nyctophobia         ',
    ' Nyctophobia          ',
    'Nyctophobia           ',
    'yctophobia            ',
    'ctophobia             ',
    'tophobia              ',
    'ophobia               ',
    'phobia            ',
    'hobia                 ',
}

ct_animation = function()
if client.latency() == nil then return end
    local set_clan_tag = math.floor(math.fmod((globals.tickcount() + (client.latency(0) / globals.tickinterval())) / 22, #ct_anim + 1) + 1)
    if entity.get_prop(entity.get_game_rules(),'m_gamePhase') == 5 or entity.get_prop(entity.get_game_rules(),'m_gamePhase') == 4 then
        return ct_anim['Nyctophobia']
    else
        return ct_anim[set_clan_tag]
    end 
end

ct_check = nil

clan_tag = function(ct_anim)
    if ct_anim == ct_check then return end
    if ct_anim == nil then return end

    client.set_clan_tag(ct_anim)

    ct_check = ct_anim
    ui.set(ref.clantag, false)
end

local function aspect_ratio()
    if lua_ui.other.aspectratio:get() then
        cvar.r_aspectratio:set_float(lua_ui.other.aspectratio_value:get()/100)
    else
        cvar.r_aspectratio:set_float(0)
    end
end

local function thirdperson()
    if lua_ui.other.third_person:get() then
        cvar.cam_idealdist:set_int(lua_ui.other.third_person_value:get())
    else
        cvar.cam_idealdist:set_int(150)
    end
end

function disableshadows()
    if lua_ui.other.fps_boost:get() then
        cvar.cl_csm_shadows:set_int(0)
    else
        cvar.cl_csm_shadows:set_int(1)
    end
end

client.set_event_callback('player_death', function(e)
    delayed_msg = function(delay, msg)
        return client.delay_call(delay, function() client.exec('say ' .. msg) end)
    end

    local delay = 1.7
    local me = entity.get_local_player()
    local victim = client.userid_to_entindex(e.userid)
    local attacker = client.userid_to_entindex(e.attacker)

    local killsay_delay = 0
    local deathsay_delay = 0

    if not me then return end

    gamerulesproxy = entity.get_all('CCSGameRulesProxy')[1]
    warmup = entity.get_prop(gamerulesproxy,'m_bWarmupPeriod')
    if warmup == 1 then return end

    if lua_ui.other.killsay:get() then
        if (victim ~= attacker and attacker == me) then
            local phase_block = ru_trashtalk[math.random(1, #ru_trashtalk)]
    
                for i=1, #phase_block do
                    local phase = phase_block[i]
                    local interphrase_delay = #phase_block[i]/24*delay
                    killsay_delay = killsay_delay + interphrase_delay
    
                    delayed_msg(killsay_delay, phase)
                end
            end
                
        if (victim == me and attacker ~= me) then
            local phase_block = ru_deathtalk[math.random(1, #ru_deathtalk)]
    
            for i=1, #phase_block do
                local phase = phase_block[i]
                local interphrase_delay = #phase_block[i]/20*delay
                deathsay_delay = deathsay_delay + interphrase_delay
    
                delayed_msg(deathsay_delay, phase)
            end
        end
    end
end)

do
    client.set_event_callback('setup_command', function (cmd)

        if lua_ui.other.fast_ladder:get() then
            local lp = entity.get_local_player()
            if lp == nil then
                return
            end

            if entity.get_prop(lp, 'm_MoveType') ~= 9 then
                return
            end

            local weapon = entity.get_player_weapon(lp)
            if weapon == nil then
                return
            end

            local throw_time = entity.get_prop(weapon, 'm_fThrowTime')

            if throw_time ~= nil and throw_time ~= 0 then
                return
            end

            if cmd.forwardmove > 0 then
                if cmd.pitch < 45 then
                    cmd.pitch = 89
                    cmd.in_moveright = 1
                    cmd.in_moveleft = 0
                    cmd.in_forward = 0
                    cmd.in_back = 1

                    if cmd.sidemove == 0 then
                        cmd.yaw = cmd.yaw + 90
                    end

                    if cmd.sidemove < 0 then
                        cmd.yaw = cmd.yaw + 150
                    end

                    if cmd.sidemove > 0 then
                        cmd.yaw = cmd.yaw + 30
                    end
                end
            elseif cmd.forwardmove < 0 then
                cmd.pitch = 89
                cmd.in_moveleft = 1
                cmd.in_moveright = 0
                cmd.in_forward = 1
                cmd.in_back = 0

                if cmd.sidemove == 0 then
                    cmd.yaw = cmd.yaw + 90
                end

                if cmd.sidemove > 0 then
                    cmd.yaw = cmd.yaw + 150
                end

                if cmd.sidemove < 0 then
                    cmd.yaw = cmd.yaw + 30
                end
            end  
        else
            return
        end 
    end)
end

local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
local weapon_to_verb = { knife = 'Knifed', hegrenade = 'Naded', inferno = 'Burned' }

local function aimbot_logs_fix()
    if lua_ui.main.main_checkbox:get() and lua_ui.other.aimbot_logs:get() then
        ui.set(ref.console_out, true)
    end
end

client.set_event_callback('aim_hit', function(e)
    if lua_ui.main.main_checkbox:get() and lua_ui.other.aimbot_logs:get() and lua_ui.other.log_type:get('Hit') then
	    local group = hitgroup_names[e.hitgroup + 1] or "?"
	    client.color_log(124, 252, 100, "Nyctophobia ~ \0")
	    client.color_log(200, 200, 200, "Hit\0")
	    client.color_log(124, 252, 100, string.format(" %s\0", entity.get_player_name(e.target)))
	    client.color_log(200, 200, 200, " in the\0")
	    client.color_log(124, 252, 100, string.format(" %s\0", group))
	    client.color_log(200, 200, 200, " for\0")
	    client.color_log(124, 252, 100, string.format(" %s\0", e.damage))
	    client.color_log(200, 200, 200, " damage\0")
	    client.color_log(200, 200, 200, " (\0")
	    client.color_log(124, 252, 100, string.format("%s\0", entity.get_prop(e.target, "m_iHealth")))
	    client.color_log(200, 200, 200, " hp remaining)")
    end
end)

client.set_event_callback("aim_miss", function(e)
    if lua_ui.main.main_checkbox:get() and lua_ui.other.aimbot_logs:get() and lua_ui.other.log_type:get('Miss') then
	    local group = hitgroup_names[e.hitgroup + 1] or "?"
	    client.color_log(255, 100, 100, "Nyctophobia ~ \0")
	    client.color_log(200, 200, 200, "Missed shot in\0")
	    client.color_log(255, 100, 100, string.format(" %s\'s\0", entity.get_player_name(e.target)))
	    client.color_log(255, 100, 100, string.format(" %s\0", group))
	    client.color_log(200, 200, 200, " due to\0")
	    client.color_log(255, 100, 100, string.format(" %s", e.reason))
    end
end)

client.set_event_callback('player_hurt', function(e)
    if lua_ui.main.main_checkbox:get() and lua_ui.other.aimbot_logs:get() and lua_ui.other.log_type:get('Hit') then
	
	    local attacker_id = client.userid_to_entindex(e.attacker)

	    if attacker_id == nil or attacker_id ~= entity.get_local_player() then
            return
        end

	    if weapon_to_verb[e.weapon] ~= nil then
            local target_id = client.userid_to_entindex(e.userid)
		    local target_name = entity.get_player_name(target_id)

		    client.color_log(124, 252, 100, "Nyctophobia ~ \0")
		    client.color_log(200, 200, 200, string.format("%s\0", weapon_to_verb[e.weapon]))
		    client.color_log(124, 252, 100, string.format(" %s\0", target_name))
		    client.color_log(200, 200, 200, " for\0")
		    client.color_log(124, 252, 100, string.format(" %s\0", e.dmg_health))
		    client.color_log(200, 200, 200, " damage\0")
		    client.color_log(200, 200, 200, " (\0")
		    client.color_log(124, 252, 100, string.format("%s\0", e.health))
		    client.color_log(200, 200, 200, " hp remaining)")
        end
	end
end)

local function anim_breaker()
    local lp = entity.get_local_player()
    if not lp then return end
    if not entity.is_alive(lp) then return end  
    local ent = libs.c_entity(lp)

    local self_index = libs.c_entity.new(lp)
    local self_anim_state = self_index:get_anim_state()
    if not self_anim_state then
        return
    end

    local self_anim_overlay = self_index:get_anim_overlay(12)
    if not self_anim_overlay then
        return
    end
    local x_velocity = entity.get_prop(lp, "m_vecVelocity[0]")
    if math.abs(x_velocity) >= 3 then
        self_anim_overlay.weight = 1
    end

    if lua_ui.other.animation_ground:get() == "Static" then
        entity.set_prop(lp, "m_flPoseParameter", 1, 0)
        ui.set(ref.leg_movement, 'Always slide')
    elseif lua_ui.other.animation_ground:get() == "Walking" then
        entity.set_prop(lp, "m_flPoseParameter", globals.tickcount() %4 > 1 and 1/10 or 0, 0)
        ui.set(ref.leg_movement, 'Never slide')
    elseif lua_ui.other.animation_ground:get() == "Fipp" then
        entity.set_prop(lp, "m_flPoseParameter", 0.5, 7)
        ui.set(ref.leg_movement, 'Never slide')
    elseif lua_ui.other.animation_ground:get() == "Droch" then
        entity.set_prop(lp, "m_flPoseParameter", math.random(0, 10)/10, 0)
    else
        ui.set(ref.leg_movement, 'Off')
    end
    
    if lua_ui.other.animation_air:get() == "Static" then
        entity.set_prop(lp, "m_flPoseParameter", 1, 6)
    elseif lua_ui.other.animation_air:get() == "Droch" then
        entity.set_prop(lp, "m_flPoseParameter", math.random(0, 10)/10, 6)
    elseif lua_ui.other.animation_air:get() == "Fipp" then
        --entity.set_prop(lp, "m_flPoseParameter", 0.5, 7)
        local animlayer = ent:get_anim_overlay(6)
        animlayer.weight = 1
    end
end

local ticks = 0

local function airstop(cmd)
    local lp = entity.get_local_player()
    if not lp then return end
    
    if lua_ui.ragebot.airstop:get() then
        if cmd.quick_stop then
            if (globals.tickcount() - ticks) > 3 then
                cmd.in_speed = 1
            end
        else
            ticks = globals.tickcount()
        end
    end

end

local function run_buybot(e)
	local userid = e.userid
	if userid ~= nil then
		if client.userid_to_entindex(userid) ~= entity.get_local_player() then
			return
		end
	end

	if not lua_ui.other.buy_bot:get() then
		return
	end

	local primary = lua_ui.other.buy_bot_primary:get()
	local pistol = lua_ui.other.buy_bot_secondary:get()
	local gear = lua_ui.other.buy_bot_other:get()

	local commands = {}

	table.insert(commands, get_command(primary_weapons, primary))
	table.insert(commands, get_command(secondary_weapons, pistol))
	
	for i=1, #gear do
		table.insert(commands, get_command(gear_weapons, gear[i]))
	end

	table.insert(commands, "use weapon_knife;")

	local command = table.concat(commands, "")
	client.exec(command)
end

function filter(bool)
    cvar.developer:set_int(0)
    cvar.con_filter_enable:set_int(bool and 1 or 0)
    cvar.con_filter_text:set_string(bool and "IrWL5106TZZKNFPz4P4Gl3pSN?J370f5hi373ZjPg%VOVh6lN" or "")
    client.exec(bool and "con_filter_enable 1" or "con_filter_enable 0")
end

lua_ui.other.filter_console:set_callback(function(self)
    client.exec(self:get() and 'clear')
    filter(self:get())
end)

client.set_event_callback("level_init", function()
    filter(lua_ui.other.filter_console:get())
end)

client.set_event_callback("round_start", function()
    filter(lua_ui.other.filter_console:get())
end)

--region callbacks

client.set_event_callback('aim_fire',aim_fire)

client.set_event_callback("player_spawn", run_buybot)

client.set_event_callback('paint', function()
    local lp = entity.get_local_player()
    if lp == nil then return end
    if not lua_ui.main.main_checkbox:get() then return end

    if lua_ui.other.clan_tag:get() then
        clan_tag(ct_animation())
    else
        clan_tag(' ')
    end
    aspect_ratio()
    disableshadows()
    watermark()
    thirdperson()
    if lua_ui.other.cross_ind:get() then
        crosshair_indicators()
    end
    paint(c)
    if lua_ui.other.velocity_warning:get() then
        velocity_ind()
    end
    if lua_ui.other.defensive_indicator:get() then
        defensive_ind()
    end
    if lua_ui.other.manual_indicators:get() then
        manual_indicator()
    end
end)

client.set_event_callback('paint_ui', function()
    if ui.is_menu_open() then
        get_skeet_color()
        menu_logic()
    end
end)

client.set_event_callback('setup_command', function(cmd)
    if not lua_ui.main.main_checkbox:get() then return end
    aa_setup(cmd)
    run_direction()
    aimbot_logs_fix()
    if lua_ui.ragebot.prediction_system:get() then
        prediction_system(cmd)
    end
    if lua_ui.ragebot.airstop:get() then
        airstop(cmd)
    end
    if lua_ui.ragebot.resolver:get() then
        resolver_update()
    end

    if lua_ui.ragebot.unsafe_charge:get() then
        unsafe_charge(cmd)
    elseif charge_state then
        ui.set(ref.aimbot, true)
    end

    if lua_ui.ragebot.auto_tp:get() and lua_ui.ragebot.auto_tp_key:get() then
        auto_tp(cmd)
    end

    if lua_ui.ragebot.airlag:get() then
        airlag(cmd)
    end
end)


client.set_event_callback('pre_render', function()
    if not lua_ui.main.main_checkbox:get() then return end
    if lua_ui.other.animation:get() then
        anim_breaker()
    end
end)

client.set_event_callback('shutdown', function()
    expres.restore()
    ui.set_visible(ref.enabled, true)
    ui.set_visible(ref.pitch[1], true)
    ui.set_visible(ref.roll[1], true)
    ui.set_visible(ref.yawbase, true)
    ui.set_visible(ref.yaw[1], true)
    ui.set_visible(ref.fsbodyyaw, true)
    ui.set_visible(ref.yawjitter[1], true)
    ui.set_visible(ref.bodyyaw[1], true)
    ui.set_visible(ref.freestand[1], true)
    ui.set_visible(ref.edgeyaw, true)
    ui.set_visible(ref.pitch[2], true)
    ui.set_visible(ref.yaw[2], true)
    ui.set_visible(ref.yawjitter[2], true)
    ui.set_visible(ref.bodyyaw[2], true)
    ui.set_visible(ref.freestand[2], true)
    ui.set_visible(ref.flEnabled[1], true)
    ui.set_visible(ref.flEnabled[2], true)
    ui.set_visible(ref.flLimit, true)
    ui.set_visible(ref.flVariance, true)
    ui.set_visible(ref.flAmount, true)
    cvar.r_aspectratio:set_float(0)
    cvar.cam_idealdist:set_int(150)
    cvar.cl_csm_shadows:set_int(1)
end)



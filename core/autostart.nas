print("*** LOADING core - autostart.nas ... ***");

# namespace : core

#
#   IN THIS FILE : SPECIFIC FUNCTIONS FOR STARTING/STOPPING AIRCRAFT
#


#===============================================================================
#                                               INSTRUMENTS START/STOP FUNCTIONS

var do_electrical_master_switch = func(value) {
    printf('  set master switch');
    setprop("/instrumentation/my_aircraft/electricals/controls/master-switch", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_electrical_bus_avionics = func(value) {
    printf('  set bus avionics');
    setprop("/instrumentation/my_aircraft/electricals/controls/bus-avionics", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_electrical_bus_engines = func(value) {
    printf('  set bus engines');
    setprop("/instrumentation/my_aircraft/electricals/controls/bus-engines", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_electrical_bus_commands = func(value) {
    printf('  set bus commands');
    setprop("/instrumentation/my_aircraft/electricals/controls/bus-commands", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engine0_fuel_on = func(value) {
    printf('  set engine 0 fuel');
    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/fuel-on", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engine1_fuel_on = func(value) {
    printf('  set engine 1 fuel');
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/fuel-on", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engine0_pump = func(value) {
    printf('  set engine 0 pump');
    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/pump", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engine1_pump = func(value) {
    printf('  set engine 1 pump');
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/pump", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engine0_start = func(value) {
    printf('  set engine 0 start -- wait 20 seconds');
    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/is_starting", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engine1_start = func(value) {
    printf('  set engine 1 start -- wait 20 seconds');
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/is_starting", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_engines_started = func() {
    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/is_starting", 0);
    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/is_stopping", 0);
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/is_starting", 0);
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/is_stopping", 0);
    setprop("/engines/engine[0]/stopped", 0);
    setprop("/engines/engine[1]/stopped", 0);
}
var do_lighting_nav = func(value) {
    printf('  set nav light');
    setprop("/controls/lighting/nav-lights", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_lighting_pos = func(value) {
    printf('  set position light');
    setprop("/controls/lighting/pos-lights", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_lighting_anticoll = func(value) {
    printf('  set anticollision light');
    setprop("/controls/lighting/beacon", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_lighting_strobe = func(value) {
    printf('  set strobe light');
    setprop("/controls/lighting/strobe", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_lighting_landing = func(value) {
    printf('  set landing and taxi light');
    setprop("/controls/lighting/landing-lights", value);
    setprop("/controls/lighting/taxi-light", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_lighting_form = func(value) {
    printf('  set formation light');
    setprop("/controls/lighting/formation-lights", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_lighting_instr = func(value) {
    printf('  set instruments light');
    setprop("/controls/lighting/instruments-norm", value);
}
var do_lighting_panel = func(value) {
    printf('  set interior light');
    setprop("/controls/lighting/panel-norm", value);
}
var do_command_canopy = func(value) {
    printf('  set canopy position');
    setprop("/controls/doors/canopy", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_command_brake_parking = func(value) {
    printf('  set parking brake');
    setprop("/controls/gear/brake-parking", value);
    setprop("/sim/model/lever_parkbrake", .5);
    setprop("/sim/model/lever_parkbrake", value);
}
var do_ground_equipment = func(value) {
    printf('  ground equipment');
    setprop("/sim/model/ground-equipment-e", value);
    setprop("/sim/model/ground-equipment-g", value);
    setprop("/sim/model/ground-equipment-s", value);
    setprop("/sim/model/ground-equipment-p", value);
    setprop("/sim/model/ground-equipment-f", value);
}
var do_comm0 = func(value) { # 0/1
    printf('  comm0');
    setprop("/instrumentation/comm[0]/serviceable", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_comm1 = func(value) { # 0/1
    printf('  comm1');
    setprop("/instrumentation/comm[1]/serviceable", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_nav0 = func(value) { # 0/1
    printf('  nav0');
    setprop("/instrumentation/nav[0]/serviceable", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_nav1 = func(value) { # 0/1
    printf('  nav1');
    setprop("/instrumentation/nav[1]/serviceable", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}
var do_adf0 = func(value) { # 0/2
    printf('  adf0');
    setprop("/instrumentation/adf[0]/func-knob", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 2));
}
var do_transponder = func(value) { # 0/5
    printf('  transponder');
    setprop("/instrumentation/transponder/inputs/knob-mode", value);
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 5));
}
var do_hud_brightness = func(value) {
    printf('  hud brightness');
    setprop("/sim/hud/color/brightness", value);
}
var do_hud_color = func(value) { # 0=green/1=red
    printf('  hud color');
    setprop("/sim/hud/current-color", value);
}

var flashlight = func(n) {
    var view_number = getprop('/sim/current-view/view-number-raw') or 0;
    if(view_number == 0)
    {
        setprop("/sim/rendering/als-secondary-lights/use-flashlight", n);
    }
}

var settings_depending_luminosity = {
    'day':{
        'hud_color':        0,
        'hud_brightness':   .9,
        'panel_light':      0,
        'instrument_light': 1,
        'nav_light':        1,
        'pos_light':        1,
        'form_light':       1,
        'flashlight':       0,
    },
    'dawn':{
        'hud_color':        0,
        'hud_brightness':   .7,
        'panel_light':      0,
        'instrument_light': .6,
        'nav_light':        1,
        'pos_light':        1,
        'form_light':       1,
        'flashlight':       0,
    },
    'night':{
        'hud_color':        1,
        'hud_brightness':   .5,
        'panel_light':      .8,
        'instrument_light': .4,
        'nav_light':        1,
        'pos_light':        1,
        'form_light':       .66,
        'flashlight':       2,
    },
};


#===============================================================================
#                                                           START/STOP FUNCTIONS

# avoid concurrent starting and stopping process
var process_status = 'READY';

var init = func() {
    #printf('init ...');
    do_lighting_landing(0);
    do_lighting_form(0);
    do_lighting_pos(0);
    do_lighting_nav(0);
    do_lighting_strobe(0);
    do_lighting_anticoll(0);
    do_lighting_instr(0);
    do_lighting_panel(0);
    do_comm0(0);
    do_comm1(0);
    do_nav0(0);
    do_nav1(0);
    do_adf0(0);
    do_transponder(0);
    do_engine0_pump(0);
    do_engine0_fuel_on(0);
    do_engine1_pump(0);
    do_engine1_fuel_on(0);
    do_electrical_bus_commands(0);
    do_electrical_bus_engines(0);
    do_electrical_bus_avionics(0);
    do_electrical_master_switch(0);

    setprop("/controls/engines/engine[0]/throttle", 0);
    setprop("/controls/engines/engine[1]/throttle", 0);

    setprop("/controls/flight/elevator", 0);
    setprop("/controls/flight/aileron", 0);
    setprop("/controls/flight/rudder", 0);
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/aileron-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);

    setprop("/controls/flight/speedbrake", 0);

    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/is_starting", 0);
    setprop("/instrumentation/my_aircraft/engines/controls/engine[0]/is_stopping", 0);
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/is_starting", 0);
    setprop("/instrumentation/my_aircraft/engines/controls/engine[1]/is_stopping", 0);
}

var fast_start = func() {
    printf('fast_start ...');

    if(process_status == 'READY')
    {
        process_status = 'FASTAUTOSTARTING';

        do_ground_equipment(0);
        do_electrical_master_switch(1);
        do_electrical_bus_avionics(1);
        do_electrical_bus_engines(1);
        do_electrical_bus_commands(1);
        do_engine0_pump(1);
        do_engine0_fuel_on(1);
        do_engine1_pump(1);
        do_engine1_fuel_on(1);
        do_comm0(1);
        do_comm1(1);
        do_nav0(1);
        do_nav1(1);
        do_adf0(2);
        do_transponder(4);
        do_lighting_strobe(1);
        do_lighting_anticoll(1);
        do_lighting_landing(1);
        do_command_canopy(0);
        settimer(func() {
            do_engines_started();
            do_electrical_master_switch(1);
            process_status = 'READY';
        }, 1);

        settimer(func() {

        var scene_diffuse = getprop("/rendering/scene/diffuse/green");
            var luminosity = 'dawn';
            luminosity = (scene_diffuse > .5) ? 'day' : luminosity;
            luminosity = (scene_diffuse <= .12) ? 'night' : luminosity;

            do_lighting_instr(settings_depending_luminosity[luminosity]['instrument_light']);
            do_lighting_panel(settings_depending_luminosity[luminosity]['panel_light']);
            do_lighting_form(settings_depending_luminosity[luminosity]['form_light']);
            do_lighting_pos(settings_depending_luminosity[luminosity]['pos_light']);
            do_lighting_nav(settings_depending_luminosity[luminosity]['nav_light']);
            do_hud_color(settings_depending_luminosity[luminosity]['hud_color']);
            do_hud_brightness(settings_depending_luminosity[luminosity]['hud_brightness']);
        }, 5);
        printf('started. Ready to fly !');
        settimer(func() { setprop("/sim/messages/pilot", 'started. Ready to fly !'); }, 1);
    }
}


#===============================================================================
#                                                             AUTOMATIC STARTING

var check_start = func() {

    printf('starting airborn ...');

    # starting
    fast_start();
    setprop("/controls/gear/brake-parking", 0);

    settimer(func() {
        setprop("/instrumentation/my_aircraft/command_h/ack_alert", 1);
        instrument_pfd.event_click_hold_autopilot();
        var preset_alt = getprop("/sim/presets/altitude-ft") or 20000;
        var preset_speed = getprop("/sim/presets/airspeed-kt") or 400;
        var preset_hdg = getprop("/sim/presets/heading-deg") or 360;
        var offset_deg = getprop("/instrumentation/heading-indicator/offset-deg") or 0;
        setprop("/autopilot/settings/target-altitude-ft", preset_alt);
        setprop("/autopilot/settings/target-speed-kt", preset_speed);
        setprop("/autopilot/settings/heading-bug-deg", (preset_hdg + offset_deg));
    }, 2);

    # enable autopilot :
    settimer(func() {
        setprop("/instrumentation/my_aircraft/command_h/ack_alert", 1);
        setprop("/sim/messages/pilot", 'autopilot activated, aircraft ready');
    }, 3);

}


check_start();



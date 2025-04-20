print("*** LOADING my_aircraft_functions - functions.nas ... ***");

# namespace : my_aircraft_functions

#
#   IN THIS FILE : COMMON/SHARED FUNCTIONS (NO LOOP HERE)
#


#===============================================================================
#                                                                    CONVERSIONS

# inHg to hPa
var INHG2HPA = 33.86389;

# farenheit to celsius
var DF2DC = func(DF)
{
    if(! DF) DF = 0;
    var out = ((DF - 32) / 1.8);
    return out;
}

# celsius to farenheit
var DC2DF = func(DC)
{
    if(! DC) DC = 0;
    return (DC * 1.8) + 32;
}

var LBS2KG = 0.45359237;


#===============================================================================
#                                                                         INPUTS
# used in include/input-properties.xml

var throttle_mouse = func()
{
    # throttle only if center mouse button pressed
    if(! getprop("/devices/status/mice/mouse[0]/button[1]"))
    {
        return;
    }

    var delta = cmdarg().getNode("offset").getValue() * -4;
    var thr0_value = getprop("/controls/engines/engine[0]/throttle") or 0;
    var thr1_value = getprop("/controls/engines/engine[1]/throttle") or 0;

    var new_thr0_value = thr0_value + delta;
    var new_thr1_value = thr1_value + delta;
    if(size(arg) > 0)
    {
        new_thr0_value = -new_thr0_value;
        new_thr1_value = -new_thr1_value;
    }
    setprop("/controls/engines/engine[0]/throttle", new_thr0_value);
    setprop("/controls/engines/engine[1]/throttle", new_thr1_value);
}

var inc_throttle = func()
{
    var lock_speed = getprop("/autopilot/locks/speed") or '';
    if(lock_speed)
    {
        var node = props.globals.getNode("/autopilot/settings/target-speed-kt", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0.0)
        {
            node.setValue(0.0);
        }
    }
    else
    {
        var thr0_value = getprop("/controls/engines/engine[0]/throttle") or 0;
        var thr1_value = getprop("/controls/engines/engine[1]/throttle") or 0;

        var new_thr0_value = thr0_value + arg[0];
        var new_thr1_value = thr1_value + arg[0];

        new_thr0_value = (new_thr0_value < -1.0) ? -1.0 : (new_thr0_value > 1.0) ? 1.0 : new_thr0_value;
        new_thr1_value = (new_thr1_value < -1.0) ? -1.0 : (new_thr1_value > 1.0) ? 1.0 : new_thr1_value;
        setprop("/controls/engines/engine[0]/throttle", new_thr0_value);
        setprop("/controls/engines/engine[1]/throttle", new_thr1_value);
    }
}

var inc_elevator = func()
{

    var lock_alt = getprop("/autopilot/locks/altitude") or '';
    if(lock_alt == 'altitude-hold')
    {
        var node = props.globals.getNode("/autopilot/settings/target-altitude-ft", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(0);
        }
        else if(node.getValue() > 40000)
        {
            node.setValue(40000);
        }
    }
    else
    {
        var elevator_value = getprop("/controls/flight/elevator") or 0;
        var new_elevator_value = elevator_value + arg[0];

        new_elevator_value = (new_elevator_value < -1.0) ? -1.0 : (new_elevator_value > 1.0) ? 1.0 : new_elevator_value;
        setprop("/controls/flight/elevator", new_elevator_value);
    }
}

var inc_aileron = func()
{
    var lock_hdg = getprop("/autopilot/locks/heading") or '';
    if(lock_hdg == 'dg-heading-hold')
    {
        var node = props.globals.getNode("/autopilot/settings/heading-bug-deg", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(node.getValue() + 360.0);
        }
        elsif(node.getValue() > 360.0)
        {
            node.setValue(node.getValue() - 360.0);
        }
    }
    else
    {
        var aileron_value = getprop("/controls/flight/aileron") or 0;
        var new_aileron_value = aileron_value + arg[0];

        new_aileron_value = (new_aileron_value < -1.0) ? -1.0 : (new_aileron_value > 1.0) ? 1.0 : new_aileron_value;
        setprop("/controls/flight/aileron", new_aileron_value);
    }
}

var center_flight_controls = func()
{
    setprop("/controls/flight/elevator", 0);
    setprop("/controls/flight/aileron", 0);
    setprop("/controls/flight/rudder", 0);
}

var center_flight_controls_trim = func()
{
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/aileron-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
}


var inc_bingo = func(inc)
{
    var bingo_choose          = getprop("/instrumentation/my_aircraft/fuel/bingo/choose") or 0;
    var bingo_distance_minute = getprop("/instrumentation/my_aircraft/fuel/bingo/distance_minute") or 0;
    var bingo_distance_nm     = getprop("/instrumentation/my_aircraft/fuel/bingo/distance_nm") or 0;

    if(bingo_choose == 0)
    {
        var new_bingo_distance_minute = bingo_distance_minute + inc;
        new_bingo_distance_minute = (new_bingo_distance_minute < 0) ? 0 : (new_bingo_distance_minute > 300) ? 300 : new_bingo_distance_minute;
        setprop("/instrumentation/my_aircraft/fuel/bingo/distance_minute", new_bingo_distance_minute);
    }
    else
    {
        var new_bingo_distance_nm = bingo_distance_nm + inc;
        new_bingo_distance_nm = (new_bingo_distance_nm < 0) ? 0 : (new_bingo_distance_nm > 500) ? 500 : new_bingo_distance_nm;
        setprop("/instrumentation/my_aircraft/fuel/bingo/distance_nm", new_bingo_distance_nm);
    }
}

var disable_hippodrome_if_ap_not_ok = func()
{
    var is_hippodrome_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    var ap_heading_mode = getprop("/autopilot/locks/heading")  or '';
    var ap_alt_mode     = getprop("/autopilot/locks/altitude") or '';
    var ap_speed_mode   = getprop("/autopilot/locks/speed")    or '';
    var is_ap_ok = ((ap_heading_mode == 'dg-heading-hold')
        and (ap_alt_mode == 'altitude-hold')
        and (ap_speed_mode == 'speed-with-throttle')
    );

    # disabling hippodrome if ap settings are not valid
    if(! is_ap_ok)
    {
        setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", 0);
    }
}

var event_toggle_hippodrome = func(do_enable)
{
    var is_hippodrome_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    var heading_bug_error_deg = math.abs(sprintf('%d', getprop("/autopilot/internal/heading-bug-error-deg") or 0));
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle hippodrome :
        do_enable = (is_hippodrome_enabled == 0) ? 1 : 0;
    }

    # don't enable if turning
    if(heading_bug_error_deg > 4)
    {
        do_enable = 0;
    }

    setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", do_enable);
    disable_hippodrome_if_ap_not_ok();
}

var event_toggle_lights = func()
{
    var beacon = getprop("/controls/lighting/beacon") or 0;
    var nav    = getprop("/controls/lighting/nav-lights") or 0;
    var pos    = getprop("/controls/lighting/pos-lights") or 0;
    var strobe = getprop("/controls/lighting/strobe") or 0;

    var toggle_lights = ((beacon * nav * pos * strobe) == 0) ? 1 : 0;

    setprop("/controls/lighting/beacon",     toggle_lights);
    setprop("/controls/lighting/nav-lights", toggle_lights);
    setprop("/controls/lighting/pos-lights", toggle_lights);
    setprop("/controls/lighting/strobe",     toggle_lights);
}

var event_toggle_landing_lights = func()
{
    var taxi = getprop("/controls/lighting/taxi-light") or 0;

    var toggle_lights = (taxi == 0) ? 1 : 0;

    setprop("/controls/lighting/taxi-light", toggle_lights);
}

var event_smoke = func(do_enable)
{
    var is_smoking = getprop("/sim/model/smoking") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_smoking == 0) ? 1 : 0;
    }
    setprop("/sim/model/smoking", do_enable);
}

var event_acknowledge_master_caution = func()
{
    # first click : alert remain (master caution no blinking and alert-sound disabled) :
    # second click : reinit
    setprop("/instrumentation/my_aircraft/command_h/ack_alert", 1);
}

var event_swap_sfd_screen = func()
{
    var current_screen = getprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen") or '';

    if(current_screen == 'EICAS')
    {
        setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", 'RADAR');
    }
    elsif(current_screen == 'RADAR')
    {
        setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", 'EICAS');
    }
}

var event_toggle_launchbar = func(do_enable)
{
    var is_carrier_equiped = getprop("/sim/model/carrier-equipment") or 0;
    if(is_carrier_equiped != 1) { return; }

    var is_launchbar_enabled = getprop("/controls/gear/launchbar") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_launchbar_enabled == 0) ? 1 : 0;
    }

    if(do_enable == 1)
    {
        # lower launchbar
        setprop("/controls/gear/launchbar", 1);

        # raise launchbar if could not have engaged
        settimer(func() {
            var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
            if(state_launchbar != 'Engaged')
            {
                setprop("/controls/gear/catapult-launch-cmd", 0);
                setprop("/controls/gear/launchbar", 0);
            }
        }, 1);
    }
    else
    {
        # raise launchbar unless engaged
        var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
        if(state_launchbar != 'Engaged')
        {
            setprop("/controls/gear/catapult-launch-cmd", 0);
            setprop("/controls/gear/launchbar", 0);
        }
    }
}

var event_control_gear = func(down, animate_view)
{
    var is_on_ground = getprop("/gear/gear[1]/wow") or 0;
    var is_serviceable = getprop("/sim/failure-manager/controls/gear/serviceable") or 0;
    if(down == -1)
    {
        # down == -1 : toggle gears :
        var is_down = getprop("/controls/gear/gear-down") or 0;
        down = (is_down == 0) ? 1 : 0;
    }
    if(is_serviceable == 0)
    {
        #setprop("sim/model/lever_gear", (getprop("sim/model/lever_gear") == 0) ? 1 : 0);
        return;
    }

    if((down == 1) and (is_on_ground == 0))
    {
        # down == 1 : extend gears :
        setprop("/controls/gear/gear-down", 1);
    }
    elsif((down == 0) and (is_on_ground == 0))
    {
        setprop("/controls/gear/launchbar", 0);
        setprop("/controls/gear/catapult-launch-cmd", 0);
        setprop("/controls/gear/gear-down", 0);
        settimer(func() { setprop("/controls/flight/elevator-trim", 0); }, 8); # see yasim extend gear : 8seconds
    }
}


var event_brake = func(do_enable)
{
    setprop("/controls/gear/brake-left", do_enable);
    setprop("/controls/gear/brake-right", do_enable);
}

var event_airbrake = func(do_enable)
{
    var speedbrake = getprop("/controls/flight/speedbrake") or 0;
    if(do_enable == 1)
    {
        speedbrake = (speedbrake > .9) ? 1.0 : speedbrake + .1;
        setprop("/controls/flight/speedbrake", speedbrake);
    }
    else
    {
        speedbrake = (speedbrake < .11) ? 0.0 : speedbrake - .1;
        setprop("/controls/flight/speedbrake", speedbrake);
    }
    event_status_ap_speed();
}

var event_status_ap_speed = func()
{
    var speedbrake     = getprop("/controls/flight/speedbrake") or 0;
    var ap_speed       = getprop("/autopilot/locks/speed") or ''; # speed-with-throttle
    var stdby_ap_speed = getprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby") or 0;

    if((speedbrake > .1) and (ap_speed == 'speed-with-throttle'))
    {
        setprop("/autopilot/locks/speed", '');
    }
    elsif((speedbrake <= .09) and (stdby_ap_speed == 1))
    {
        setprop("/autopilot/locks/speed", 'speed-with-throttle');
    }
}

var event_toggle_std_atm = func(do_enable)
{
    var is_std_atm = getprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_std_atm == 0) ? 1 : 0;
    }
    if(do_enable == 1)
    {
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt", 1);
        var setting_inhg_previous = getprop("/instrumentation/altimeter/setting-inhg");
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/setting-inhg-previous", setting_inhg_previous);
        setprop("/instrumentation/altimeter/setting-inhg", 29.92);
    }
    else
    {
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt", 0);
        var setting_inhg_previous = getprop("/instrumentation/my_aircraft/stdby-alt/controls/setting-inhg-previous");
        setprop("/instrumentation/altimeter/setting-inhg", setting_inhg_previous);
    }
}


#===============================================================================
#                                                                          TOOLS

var reload_fx = func()
{
    fgcommand("reinit", props.Node.new({ subsystem: "sound" }));
}

var check_source_aliases = func()
{
    var list_of_properties = [
        "/orientation/pitch-deg",
        "/orientation/roll-deg",
        "/orientation/heading-magnetic-deg",
    ];

    for(var i = 0 ; i < size(list_of_properties) ; i += 1)
    {
        var property = list_of_properties[i];
        var value = getprop(property);
        if(! value) value = 'NULL !';
        printf ('la propriete %s vaut %s', property, value);
    }
}

var dump_properties = func()
{
    io.write_properties('/home/nico/.fgfs/Export/foo.xml', '/');
}






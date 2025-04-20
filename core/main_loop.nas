print("*** LOADING core - main_loop.nas ... ***");

# namespace : core

#
#   IN THIS FILE : LOOPS
#

#===============================================================================
#                                                                          LOOPS


var loop_2000ms = func() {
    #my_aircraft_functions.disable_hippodrome_if_ap_not_ok();
    core.vor_true_to_mag();
}

var loop_1000ms = func() {
    core.hippo_loop();
    core.listen_master_ap_loop();

    instrument_pfd.pfd();
    instrument_fuel.fuel();

    instrument_command_h.checking_aircraft_status();
}

var loop_500ms = func() {
    instrument_nd.nd();
    instrument_command_h.blink();
}

var loop_200ms = func() {
    instrument_hud.minihud_loop();

    # alarms update
    core.update_alarms();
}

var loop_100ms = func() {

    #instrument_light.light();

    # systems
    core.systems_loop();

    # setting engine egt celsius from egt farenheit
    core.egtf2egtc();

    # setting altimeter kilopascal from inch hg
    setprop("/instrumentation/altimeter/setting-kpa", (getprop("/instrumentation/altimeter/setting-inhg") * my_aircraft_functions.INHG2HPA));

    # setting true-heading-bug from mag-heading-bug
    setprop("/instrumentation/my_aircraft/nd/outputs/true-heading-bug-deg", math.mod(getprop("/autopilot/settings/heading-bug-deg") + getprop("/environment/magnetic-variation-deg"), 360));

    # touchdown smoke
    core.touchdown_smoke();

}

var ms = 0;
var ratio_speed = 1;
var main_loop = func() {

    if(math.mod(ms, 100 * ratio_speed) == 0)
    {
        loop_100ms();
    }
    if(math.mod(ms, 200 * ratio_speed) == 0)
    {
        loop_200ms();
    }
    if(math.mod(ms, 500 * ratio_speed) == 0)
    {
        loop_500ms();
    }
    if(math.mod(ms, 1000 * ratio_speed) == 0)
    {
        loop_1000ms();
    }
    if(math.mod(ms, 2000 * ratio_speed) == 0)
    {
        loop_2000ms();
    }

    ms = (ms > (2000 * ratio_speed)) ? 0 : ms + 100;

    var time_speed = getprop("/sim/speed-up") or 1;
    #ratio_speed = (time_speed > 1) ? 2 * time_speed : 1;
    ratio_speed = (time_speed > 4) ? 4 : 1;

    settimer(main_loop, .1);

}

var run_once = func() {
    instrument_nd.set_north();
    settimer(instrument_command_h.reset, 3);
}

setlistener("/sim/signals/fdm-initialized", main_loop);
setlistener("/sim/signals/fdm-initialized", run_once);






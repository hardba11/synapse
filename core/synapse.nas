print("*** LOADING core - synapse.nas ... ***");

# namespace : core

#
#   IN THIS FILE : AIRCRAFT PROPERTIES UPDATE
#
var ap_random = rand();
var egtf2egtc = func()
{
    setprop("/engines/engine[0]/egt", 0);
    var m0egt_degf = getprop("/engines/engine[0]/egt-degf");
    if(m0egt_degf)
    {
        var m0egt = my_aircraft_functions.DF2DC(m0egt_degf);
        setprop("/engines/engine[0]/egt", m0egt);
    }
    setprop("/engines/engine[1]/egt", 0);
    var m1egt_degf = getprop("/engines/engine[1]/egt-degf");
    if(m1egt_degf)
    {
        var m1egt = my_aircraft_functions.DF2DC(m1egt_degf);
        setprop("/engines/engine[1]/egt", m1egt);
    }
}

var vor_true_to_mag = func()
{
    var tru_orientation = getprop("/orientation/heading-deg") or 0;
    var mag_orientation = getprop("/orientation/heading-magnetic-deg") or 0;

    var nav1_tru = getprop("/instrumentation/nav[0]/heading-deg") or 0;
    setprop("/instrumentation/nav[0]/heading-magnetic-deg", nav1_tru + (mag_orientation - tru_orientation));

    var nav2_tru = getprop("/instrumentation/nav[1]/heading-deg") or 0;
    setprop("/instrumentation/nav[1]/heading-magnetic-deg", nav2_tru + (mag_orientation - tru_orientation));
}

var update_alarms = func()
{
    var stall_warning = 0;
    var speed = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 0;
    var aoa = getprop("/orientation/alpha-deg") or 0;
    var wow = getprop("/gear/gear[1]/wow") or 0;
    if((speed < 110) and (wow == 0))
    {
        if(aoa >= 12)  { stall_warning = 1; }
        if(aoa >= 15) { stall_warning = 2; }
    }
    setprop("/sim/alarms/stall-warning", stall_warning);
}


var touchdown_is_smoke         = [0, 0, 0];
var touchdown_rollspeed        = [0, 0, 0];
var touchdown_buffer_rollspeed = [0, 0, 0];
var touchdown_smoke = func()
{
    for(var i = 1; i <= 2; i += 1)
    {
        touchdown_rollspeed[i] = getprop("/gear/gear["~i~"]/rollspeed-ms") or 0;
        touchdown_is_smoke[i] = 0;

        # if last rollspeed value was 0 and current value > last value
        # begin smoke and squeal
        if((touchdown_buffer_rollspeed[i] == 0)
            and ((touchdown_rollspeed[i] - 1) > touchdown_buffer_rollspeed[i]))
        {
            touchdown_is_smoke[i] = 1;
        }
        touchdown_buffer_rollspeed[i] = touchdown_rollspeed[i];
        setprop("/gear/gear["~i~"]/tyre-touchdown", touchdown_is_smoke[i]);
    }
}

# /instrumentation/my_aircraft/pfd/controls/hippodrome
# - 0: desactive
# - 1: actif
# top
# - 0: ne rien faire (ligne droite)
# - 1: debut ligne droite : lancer virage dans 300s
# - 2: virage en cours : detecter la fin
# - 3: attendre
var top_hippo = 0;
var hippo_turn = func()
{
    #print("+++ call hippo_turn");

    var hippo_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    if((hippo_enabled == 1) and (top_hippo == 3))
    {
        setprop("/sim/messages/pilot", 'starting turn.');
        var ap_heading = sprintf("%d", getprop("/autopilot/settings/heading-bug-deg") or 0);

        var new_heading = (ap_heading > 180) ? ap_heading - 180 : ap_heading + 180;
        var tmp_heading = (ap_heading > 270) ? ap_heading - 90 : ap_heading + 270;

        settimer(func() {
            setprop("/autopilot/settings/heading-bug-deg", tmp_heading);
        }, 0);
        settimer(func() {
            setprop("/autopilot/settings/heading-bug-deg", new_heading);
            top_hippo = 2;
        }, 5);
    }
}

var hippo_loop = func()
{
    print("+++ hippo_loop");
    var hippo_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    if(hippo_enabled == 1)
    {
        var leg_duration = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome-leg-duration") or 30;
        if(top_hippo == 0)
        {
            #print("+++ activation");
            top_hippo = 1;
        }
        elsif(top_hippo == 1)
        {
            #print("+++ top droite");
            #setprop("/sim/messages/pilot", 'starting hippodrom leg, turn in '~ leg_duration ~' seconds.');
            #settimer(func() { if(getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome")){ setprop("/sim/messages/pilot", 'turn in 10 seconds.'); } }, (leg_duration - 10));
            settimer(func() { hippo_turn(); }, leg_duration);
            top_hippo = 3;
        }
        elsif(top_hippo == 2)
        {
            var heading_bug_error_deg = math.abs(sprintf('%d', getprop("/autopilot/internal/heading-bug-error-deg") or 0));
            #print("+++ virage ... "~ heading_bug_error_deg);
            if(heading_bug_error_deg < 2)
            {
                #print("+++ fin virage");
                top_hippo = 1;
            }
        }
    }
    else
    {
        top_hippo = 0;
    }
}

#===============================================================================
#

var get_infos_from_master = func(my_master_callsign)
{
    if(my_master_callsign == '')
    {
        return [];
    }

    var list_mp_obj = props.globals.getNode("/ai/models").getChildren("multiplayer");
    for(var i = 0; i < size(list_mp_obj); i += 1)
    {
        var mp_callsign = list_mp_obj[i].getNode("callsign").getValue() or '';
        var is_valid = list_mp_obj[i].getNode("valid").getValue() or false;
        if((mp_callsign == my_master_callsign) and is_valid)
        {
            # master found, get ap settings
            var alt             = list_mp_obj[i].getNode("sim/multiplay/generic/int[14]").getValue() or 0;
            var speed           = list_mp_obj[i].getNode("sim/multiplay/generic/int[15]").getValue() or 0;
            var callsign_target = list_mp_obj[i].getNode("sim/multiplay/generic/string[1]").getValue() or '';
            var fix_target      = list_mp_obj[i].getNode("sim/multiplay/generic/string[2]").getValue() or '';
            return [alt, speed, callsign_target, fix_target, 0];
        }
    }
    return [];
}

var get_infos_from_ap = func()
{
    # get ap settings

    var alt =             getprop("/sim/presets/altitude-ft") or 20000;
    var speed =           getprop("/sim/presets/airspeed-kt") or 300;
    var callsign_target = getprop("/sim/presets/target") or '';
    var fix_target =      getprop("/sim/presets/fix") or '';
    var hdg =             getprop("/sim/presets/heading-deg") or 0;
    return [alt, speed, callsign_target, fix_target, hdg];
}

var get_infos_to_callsign = func(callsign_target)
{
    if(callsign_target == '')
    {
        return [];
    }

    var list_mp_obj = props.globals.getNode("/ai/models").getChildren("multiplayer");
    for(var i = 0; i < size(list_mp_obj); i += 1)
    {
        var callsign = list_mp_obj[i].getNode("callsign").getValue() or '';
        var is_valid = list_mp_obj[i].getNode("valid").getValue() or false;
        if((callsign_target == callsign) and is_valid)
        {
            var target_true_hdg = list_mp_obj[i].getNode("orientation/true-heading-deg").getValue() or 0;
            var target_lat = list_mp_obj[i].getNode("position/latitude-deg").getValue() or 0;
            var target_lng = list_mp_obj[i].getNode("position/longitude-deg").getValue() or 0;
            var target_speed = list_mp_obj[i].getNode("velocities/true-airspeed-kt").getValue() or 0;
            var target_altitude = list_mp_obj[i].getNode("position/altitude-ft").getValue() or 0;
            var target_range = list_mp_obj[i].getNode("radar/range-nm").getValue() or 0;
            var target_bearing = list_mp_obj[i].getNode("radar/bearing-deg").getValue() or 0;
            var heading_from_target = geo.normdeg(target_bearing + 180 - target_true_hdg);

            var speed_factor = (target_range < 3) ? target_range : 4;
            speed_factor = speed_factor * math.cos((heading_from_target + 20 + (ap_random * 10)) * D2R) * -0.6;

            coords_to_follow = geo.Coord.new();
            coords_to_follow.set_latlon(target_lat, target_lng);
            coords_to_follow.apply_course_distance(target_true_hdg + 1 + ap_random, (7 * target_speed));
            lat = coords_to_follow.lat();
            lng = coords_to_follow.lon();
            speed = (target_range > 6) ? (target_speed + 400) : (target_speed + (target_speed * speed_factor));
            speed = (speed > 650) ? 650 : speed;
            alt = target_altitude + 12 + (ap_random * 5);

            var my_position = geo.aircraft_position();
            var wp = geo.Coord.new();
            wp.set_latlon(lat, lng);
            var magnetic_variation_deg = getprop("/environment/magnetic-variation-deg") or 0;
            hdg = geo.normdeg(my_position.course_to(wp) - magnetic_variation_deg);

            return [alt, speed, hdg, target_range];
        }
    }
    return [];
}

var get_infos_to_fix = func(fix_target)
{
    if(fix_target == '')
    {
        return [];
    }

    var fixes = [];
    var type = '';
    if(size(fix_target) == 5)
    {
        fixes = findFixesByID(fix_target);
        type = 'FIX';
    }
    elsif(size(fix_target) == 4)
    {
        fixes = findAirportsByICAO(fix_target);
        type = 'AIRPRT';
    }
    elsif(size(fix_target) == 3)
    {
        fixes = findNavaidsByID(fix_target, 'ndb');
        type = 'NDB';
    }

    if(size(fixes) > 0)
    {
        var magnetic_variation_deg = getprop("/environment/magnetic-variation-deg") or 0;
        var fix = courseAndDistance(fixes[0]);
        var hdg = geo.normdeg(fix[0] - magnetic_variation_deg);
        var target_range = fix[1];

        return [hdg, type, target_range];

    }
    return [];
}

var set_speed = func(speed)
{
    var speedbrake = 0;
    speed = (speed < 150) ? 150 : speed;
    var current_speed = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 0;
    if((current_speed - speed) > 30)
    {
        speedbrake = .6;
    }
    elsif((current_speed - speed) > 20)
    {
        speedbrake = .4;
    }
    elsif((current_speed - speed) > 10)
    {
        speedbrake = .2;
    }
    return [speed, speedbrake];
}

var set_alt = func(alt)
{
    var alt_agl_ft = getprop("/position/altitude-agl-ft") or 0;
    var alt_ft = getprop("/position/altitude-ft") or 0;
    var old_alt = alt;
    var vspeed = 12000;

    alt = (alt_agl_ft < 1200) ? alt - alt_agl_ft + 1300 : alt;

    if(alt_ft > 40000)
    {
        vspeed = 2000;
    }
    if(alt_ft > 25000)
    {
        vspeed = 3000;
    }
    elsif(alt_ft > 15000)
    {
        vspeed = 4000;
    }
    elsif(alt_ft > 8000)
    {
        vspeed = 8000;
    }
    return [alt, vspeed];
}

var listen_master_ap_loop = func()
{
    var alt =             20000;
    var speed =           250;
    var callsign_target = '';
    var fix_target =      '';
    var hdg =             0;
    var target_range =    0;
    var following_type =  'HDG';
    var speedbrake =      0;
    var vspeed =          2000;

    #--------------------------------------------------- RECUPERATION DES ORDRES

    # rqp des infos ap
    var infos_from_ap = get_infos_from_ap(get_infos_from_ap);
    if(size(infos_from_ap) == 5)
    {
        alt = infos_from_ap[0];
        speed = infos_from_ap[1];
        callsign_target = infos_from_ap[2];
        fix_target = infos_from_ap[3];
        hdg = infos_from_ap[4];
    }

    # si master, rqp des infos mp du master
    var my_master_callsign = props.globals.getNode("/sim/presets/my-master-callsign").getValue() or '';
    var infos_from_master = get_infos_from_master(my_master_callsign);
    if(size(infos_from_master) == 5)
    {
        alt = infos_from_master[0];
        speed = infos_from_master[1];
        callsign_target = infos_from_master[2];
        fix_target = infos_from_master[3];
    }
    else
    {
        my_master_callsign = '';
    }

    #---------------------------------------------------- RECUPERATION DES INFOS

    var infos_to_fix = get_infos_to_fix(fix_target);
    if(size(infos_to_fix) == 3)
    {
        hdg = infos_to_fix[0];
        following_type = infos_to_fix[1];
        target_range = infos_to_fix[2];
    }
    else
    {
        fix_target = '';
    }

    var infos_to_callsign = get_infos_to_callsign(callsign_target);
    if(size(callsign_target) == 4)
    {
        alt = infos_to_callsign[0];
        speed = infos_to_callsign[1];
        hdg = infos_to_callsign[2];
        target_range = infos_to_callsign[3];
        following_type = 'TARGET';
    }
    else
    {
        callsign_target = '';
    }

    #------------------------------------------------------------------- CALCULS
    
    var speed_set = set_speed(speed);
    speed = speed_set[0];
    speedbrake = speed_set[1];

    var alt_set = set_alt(alt);
    alt = alt_set[0];
    vspeed = alt_set[1];


    #------------------------------------------------------------------- CONTROL

    var do_hippo = getprop("/sim/presets/do-hippo") or 0;
    if((my_master_callsign == '') and (callsign_target == '') and (fix_target == '') and (do_hippo == 1))
    {
        setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", 1);
    }
    else
    {
        setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", 0);
        setprop("/autopilot/settings/heading-bug-deg", hdg);
    }

    setprop("/autopilot/settings/vertical-speed-fpm", vspeed);
    setprop("/autopilot/settings/target-speed-kt", speed);
    setprop("/autopilot/settings/target-altitude-ft", alt);

    #setprop("/sim/presets/altitude-ft", alt);
    #setprop("/sim/presets/airspeed-kt", speed);
    #setprop("/sim/presets/heading-deg", hdg);

    setprop("/sim/presets/my-master-callsign", my_master_callsign);
    setprop("/sim/presets/target", callsign_target);
    setprop("/sim/presets/fix", fix_target);
    setprop("/sim/presets/following-type", following_type);
    setprop("/sim/presets/following-range", target_range);

}




























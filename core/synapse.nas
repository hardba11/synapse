print("*** LOADING core - synapse.nas ... ***");

# namespace : core

#
#   IN THIS FILE : AIRCRAFT PROPERTIES UPDATE
#

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


var listen_master_ap_loop = func()
{
    var master_is_found = 0;

    var alt = getprop("/sim/presets/altitude-ft") or 20000;
    var speed = getprop("/sim/presets/airspeed-kt") or 250;
    var hdg = getprop("/sim/presets/heading-deg") or 0;
    var callsign_target = 'callsign_target';
    var fix_target = 'fix_target';

    # on recherche le master parmi les multiplayers et on recupere ses ordres
    var my_master_callsign = props.globals.getNode("/sim/presets/my-master-callsign").getValue() or 'my_master_callsign';
    if(my_master_callsign != 'my_master_callsign')
    {
        var list_mp_obj = props.globals.getNode("/ai/models").getChildren("multiplayer");
        for(var i = 0; i < size(list_mp_obj); i += 1)
        {
            var mp_callsign = list_mp_obj[i].getNode("callsign").getValue() or '';
            var is_valid = list_mp_obj[i].getNode("valid").getValue() or false;
            if((mp_callsign == my_master_callsign) and is_valid)
            {
                master_is_found = 1;

                # master found, get ap settings
                alt = list_mp_obj[i].getNode("sim/multiplay/generic/int[14]").getValue() or '';
                speed = list_mp_obj[i].getNode("sim/multiplay/generic/int[15]").getValue() or '';
                lat = list_mp_obj[i].getNode("sim/multiplay/generic/float[14]").getValue() or 0;
                lng = list_mp_obj[i].getNode("sim/multiplay/generic/float[15]").getValue() or 0;
                callsign_target = list_mp_obj[i].getNode("sim/multiplay/generic/string[1]").getValue() or 'callsign_target';
                fix_target = list_mp_obj[i].getNode("sim/multiplay/generic/string[2]").getValue() or 'fix_target';
                break;
            }
        }
    }

    var magnetic_variation_deg = getprop("/environment/magnetic-variation-deg") or 0;
    if(master_is_found == 1)
    {
        # on a un master, on suit ses ordres

        setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", 0);

        # le drone doit suivre un callsign, on le recherche :
        var callsign_target_found = 0;
        if(callsign_target != 'callsign_target')
        {
            for(var i = 0; i < size(list_mp_obj); i += 1)
            {
                var callsign = list_mp_obj[i].getNode("callsign").getValue() or '';
                var is_valid = list_mp_obj[i].getNode("valid").getValue() or false;
                if((callsign_target == callsign) and is_valid)
                {
                    callsign_target_found = 1;
                    setprop("/sim/presets/following-type", 'TARGET');
                    setprop("/sim/presets/following", callsign_target);


                    var target_true_hdg = list_mp_obj[i].getNode("orientation/true-heading-deg").getValue() or 0;
                    var target_lat = list_mp_obj[i].getNode("position/latitude-deg").getValue() or '0';
                    var target_lng = list_mp_obj[i].getNode("position/longitude-deg").getValue() or '0';
                    var target_speed = list_mp_obj[i].getNode("velocities/true-airspeed-kt").getValue() or 0;
                    var target_altitude = list_mp_obj[i].getNode("position/altitude-ft").getValue() or 0;
                    var target_range = list_mp_obj[i].getNode("radar/range-nm").getValue() or 0;
                    var target_bearing = list_mp_obj[i].getNode("radar/bearing-deg").getValue() or 0;
                    var target_rotation = list_mp_obj[i].getNode("radar/rotation").getValue() or 0;

                    setprop("/sim/presets/following-range", target_range);

                    var heading_from_target = geo.normdeg(target_bearing + 180 - target_true_hdg);
                    var speed_factor = (target_range < 3) ? target_range : 4;
                    speed_factor = speed_factor * math.cos((heading_from_target) * D2R) * -0.45;

                    coords_to_follow = geo.Coord.new();
                    coords_to_follow.set_latlon(target_lat, target_lng);
                    coords_to_follow.apply_course_distance(target_true_hdg + 1, (5 * target_speed));
                    lat = coords_to_follow.lat();
                    lng = coords_to_follow.lon();
                    if(target_range > 6)
                    {
                        speed = (target_speed + 400);
                    }
                    else
                    {
                        speed = (target_speed + (target_speed * speed_factor));
                    }
                    speed = (speed > 650) ? 650 : speed;
                    speed = (speed < 150) ? 150 : speed;
                    alt = target_altitude + 15;

                    var my_position = geo.aircraft_position();
                    var wp = geo.Coord.new();
                    wp.set_latlon(lat, lng);
                    hdg = geo.normdeg(my_position.course_to(wp) - magnetic_variation_deg);

                    break;
                }
            }
        }

        # le drone doit atteindre un fix :
        var fix_target_found = 0;
        if((callsign_target_found == 0) and (fix_target != ''))
        {
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
                fix_target_found = 1;
                setprop("/sim/presets/following-type", type);
                setprop("/sim/presets/following", fix_target);

                var fix = courseAndDistance(fixes[0]);
                hdg = geo.normdeg(fix[0] - magnetic_variation_deg);
                setprop("/sim/presets/following-range", fix[1]);
            }

        }

        if((callsign_target_found == 0) and (fix_target_found == 0))
        {
            setprop("/sim/presets/following-type", '---');
            setprop("/sim/presets/following", 'hippodrome');
            setprop("/sim/presets/following-range", '');
        }

        setprop("/autopilot/settings/target-speed-kt", speed);
        setprop("/autopilot/settings/target-altitude-ft", alt);
        setprop("/autopilot/settings/heading-bug-deg", hdg);
        #print('MASTER FOUND : setting from master : alt='~ alt ~' - speed='~ speed ~' - hdg='~ hdg);
    }
    else
    {
        # on n'a pas de master, on passe en hippodrome

        setprop("/sim/presets/following-type", '---');
        setprop("/sim/presets/following", 'hippodrome');
        setprop("/sim/presets/following-range", '');

        setprop("/autopilot/settings/target-speed-kt", speed);
        setprop("/autopilot/settings/target-altitude-ft", alt);
        var hippo_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
        if(hippo_enabled == 0)
        {
            setprop("/autopilot/settings/heading-bug-deg", hdg);
            settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", 1); }, 2);
            #print('NO MASTER FOUND : setting from presets : alt='~ alt ~' - speed='~ speed ~' - hdg='~ hdg);
        }
    }
}










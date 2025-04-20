print("*** LOADING core - systems.nas ... ***");

# namespace : core

#
#   IN THIS FILE : AIRCRAFT ELECTRICAL AND ENGINES SYSTEMS
#

#     evenement push btn "start" et tt est ok
#               |
#               V
#     +----is_starting----+
#     |      (loop)       |
#     |         ^         |
#     |         |         V
# is_stopped    |     ! is_stopped  (<=> /engines/engine[x]/stopped)
#     ^         |         |
#     |         |         |
#     +----is_stopping----+
#            (loop)
#               ^
#               |
#     evenement interruption inputs (fuel, pump, etc)



#===============================================================================
#                                                                      CONSTANTS


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                                   systems_loop
# this function check engines stats and manage engines
var systems_loop = func()
{
    foreach(var engine_id ; ['0', '1'])
    {
        var n1 = getprop("/engines/engine["~ engine_id ~"]/n1") or 0;
        setprop("/engines/engine["~ engine_id ~"]/n1-true", n1);
        setprop("/engines/engine["~ engine_id ~"]/out-of-fuel", 0);
        setprop("/engines/engine["~ engine_id ~"]/stopped", 0);
        setprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/is_starting", 0);
        setprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/is_stopping", 0);

    }

    setprop("/systems/electrical/bus/avionics", 1);
    setprop("/systems/electrical/bus/engines",  1);
    setprop("/systems/electrical/bus/commands", 1);
    setprop("/controls/hydraulic/system/engine-pump", 1);
}


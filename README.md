<!--
markdown README.md > md.html ; cat {hd.inc,md,ft.inc}.html > github.html
-->
# Synapse

**Synapse is a fictional drone**

It is usable in [FlightGear open source flight simulator](http://www.flightgear.org).



# Installation

Install the aircraft as you would any other FlightGear aircraft from GitHub.

# Usage

Synapse is a drone and is only used via autopilot settings.

It is controlled either by its own autopilot or by its master aircraft.


## Launching Synapse

Synapse will already be in-flight when FlightGear starts, so you need to launch FlightGear with additional parameters

You can choose your desired altitude, speed, and heading.

Replace `MY_CALLSIGN` with the callsign of your master aircraft.

```
--in-air
--offset-distance=0
--vc=250
--altitude=10000
--prop:/sim/presets/my-master-callsign=MY_CALLSIGN
--prop:/sim/presets/airspeed-kt=250
--prop:/sim/presets/altitude-ft=10000
--prop:/sim/presets/heading-deg=270
--multiplay=in,10,,5005
--multiplay=out,10,mpserver01.flightgear.org,5000
```

You can then use the Synapse - Auto Pilot... menu to set heading, speed, and altitude.

## Launching brsq

Start a second instance of FlightGear with brsq, which will act as the master aircraft.
Since Synapse will receive commands from brsq, both instances must be able to communicate via multiplayer mode.

Replace `MY_CALLSIGN` with the callsign of your master aircraft.

```
--callsign=MY_CALLSIGN
--multiplay=in,10,,5006
--multiplay=out,10,mpserver01.flightgear.org,5000
```

You can use the brsq - Loyal Wingman... menu to control your drone.

- If you enter a callsign, the drone will intercept that aircraft. You can, for example, enter your own MY_CALLSIGN.
- If you enter a fix (VOR, airport, etc.), the drone will fly toward that fix at the specified speed and altitude.
- If neither is specified, the drone will orbit in a racetrack pattern at the desired speed and altitude.

On the drone’s HUD, the master’s callsign is displayed in the top-left corner, along with any defined FIX or TARGET.


# How to Use Synapse with an Aircraft Other Than BRSQ

This section is intended for developers.

**1- Add 4 MP properties**

These must be located in `/sim/multiplay/generic/`
Make sure these properties are available and unused :

```
    <int                  n="14" type="int">12500</int>  <!-- loyal wingman: alt -->
    <int                  n="15" type="int">220</int>    <!-- loyal wingman: speed -->
    <string               n="1"  type="string"></string> <!-- loyal wingman: callsign to follow -->
    <string               n="2"  type="string"></string> <!-- loyal wingman: fix -->
```

See the file: `bourrasque/include/sim-multiplay-properties.xml`

**2- Add a Loyal Wingman menu**

For examples, see the following files:
- bourrasque/gui/dialogs/synapse-autopilot.xml
- bourrasque/gui/specific-menu.xml









vous pouvez utiliser le menu `brsq - Loyal Wingman...` afin de diriger votre drone.
- si vous saisissez un callsign, le drone ira l'intercepter. vous pouvez mettre votre `MY_CALLSIGN` par exemple
- si vous saisissez un fix (VOR, airport, etc), le drone ira sur ce fix à la vitesse et l'altitude souhaitée
- sinon le drone se mettra en hippodome à la vitesse et l'altitude souhaitée

sur le hud du drone apparaissent en haut à gauche le callsign du master et si un FIX ou une TARGET sont definis





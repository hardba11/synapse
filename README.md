<!--
markdown README.md > md.html ; cat {hd.inc,md,ft.inc}.html > github.html
-->
# Synapse

**Synapse is a fictional drone**

It is usable in [FlightGear open source flight simulator](http://www.flightgear.org).


# Installation

Install synapse : `unzip` or `git clone`.


# Usage

Synapse is a drone and is only used via autopilot settings.

It is controlled either by its own autopilot **OR BY ITS MASTER AIRCRAFT**.

## 1/ controlled by its own autopilot

### Launching Synapse

Synapse will already be in-flight when FlightGear starts, so you need to launch FlightGear with additional parameters

additionnal parameters :

```
--airport=FMEE
--callsign=MY_UAV
--in-air
--offset-distance=0
--vc=250
--altitude=10000
--prop:/sim/presets/airspeed-kt=250
--prop:/sim/presets/altitude-ft=10000
--prop:/sim/presets/heading-deg=270
```

### Control drone with autopilot

You can then use the `Synapse | Auto Pilot...` menu :

- set heading, speed, and altitude 
- set a callsign to follow (another multiplayer aircraft)
- set an airport to reach (TNCM)

On synapse's hud, you can see target informations.

## 2/ controlled by a master aircraft

### hrdbControlSynapse add-on is required !

Install [hrdb-addons](https://github.com/hardba11/hrdb-addons) in a directory (`/path/of/addon/` for example).

### Launching Master Aircraft

You need to set additionnal parameters :

- Replace `MY_CALLSIGN` with the callsign of your master aircraft.
- Replace `/path/of/addon/` with the directory where you put your addons.

```
--airport=FMEE
--callsign=MY_CALLSIGN
--multiplay=in,10,,5001
--multiplay=out,10,mpserver01.flightgear.org,5000
--addon=/path/of/addon/hrdb-addons/hrdbControlSynapse-1.0.0
```


### Launching Synapse

Synapse will already be in-flight when FlightGear starts, so you need to launch FlightGear with additional parameters :

- replace `MY_CALLSIGN` with the callsign of your master aircraft.

```
--airport=FMEE
--callsign=MY_UAV
--in-air
--offset-distance=0
--vc=250
--altitude=10000
--prop:/sim/presets/my-master-callsign=MY_CALLSIGN
--prop:/sim/presets/airspeed-kt=250
--prop:/sim/presets/altitude-ft=10000
--prop:/sim/presets/heading-deg=270
--multiplay=in,10,,5002
--multiplay=out,10,mpserver01.flightgear.org,5000
```
### controlling synapse from your Master Aircraft

You can then use the `HrdbAddOns | Loyal wingman...` menu :

- set speed, and altitude 
- set a callsign to follow (your callsign or another)
- set an airport to reach (KSFO)

On synapse's hud, you can see if master found and target informations (given by master aircraft).

<!--
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
- `bourrasque/gui/dialogs/synapse-autopilot.xml`
- `bourrasque/gui/specific-menu.xml`

-->





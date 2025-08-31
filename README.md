<!--
markdown README.md > md.html ; cat {hd.inc,md,ft.inc}.html > github.html
-->
# Synapse

**Synapse is a fictional drone**

It is usable in [FlightGear open source flight simulator](http://www.flightgear.org).

![Image](https://github.com/hardba11/synapse/blob/main/contrib/preview.png)

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
- Replace `A.B.C` with the version of the addon.

```
--airport=FMEE
--callsign=MY_CALLSIGN
--multiplay=in,10,,5001
--multiplay=out,10,mpserver01.flightgear.org,5000
--addon=/path/of/addon/hrdb-addons/hrdbControlSynapse-A.B.C
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





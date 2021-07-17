# Termux Alarm Clock 

A simple alarm clock script which requires the user to sort a list of numbers in order to stop the alarm.

## Requirements

* Bash
* Figlet
* BC
* Lolcat
* Termux-API (for vibration, flashlight and sound)

## Configuration

To configure the alarm clock, create a configuration file called `alarm.conf` in the same directory as `alarm.sh`. ([Example configuration](https://github.com/sync1211/Termux-Alarm-Clock/wiki/Example-configuration))

If you want to play a sound when the alarm triggers, place a file called `Alarm.mp3` in the root directory of this project or specify a file in `alarm.conf`.

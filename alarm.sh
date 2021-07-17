#!/data/data/com.termux/files/usr/bin/bash

#alarm script V1.5

#variables
alarm_vibration_enabled=true
alarm_flashlight_enabled=true
alarm_vibration_custom_args=""
alarm_music_enabled=false
alarm_music_vol=15
alarm_music="Alarm.mp3"
alarm_wakeup_greeting_enabled=true
alarm_wakeup_greeting="Have a nice day! "
alarm_wakeup_custom_cmd="fortune | lolcat"
alarm_wakelock=true
alarm_custom_cmd=""
alarm_loop_custom_cmd=""
alarm_loop_delay=0

#read cfg
curpath=$(dirname $(realpath "$0"))
source $curpath/alarm.conf &> /dev/null


#functions

alarm_loop(){
    eval $alarm_custom_cmd

    if $alarm_music_enabled; then
        termux-volume music $alarm_music_vol
        termux-media-player play "$alarm_music" &> /dev/null
    fi

    while true; do
        eval $alarm_loop_custom_cmd
        
        if $alarm_flashlight_enabled; then
	        termux-torch on
        fi
        if $alarm_vibration_enabled; then
        	eval "termux-vibrate $alarm_vibration_custom_args"
        fi
        if $alarm_flashlight_enabled; then
	        termux-torch off
        fi
        sleep $alarm_loop_delay
    done
}

alarm_wakeup(){
    if $alarm_flashlight_enabled; then
        termux-torch off &
    fi
    if $alarm_music_enabled; then
        termux-volume music 0 &
        termux-media-player stop &> /dev/null
    fi
    if $alarm_wakeup_greeting_enabled; then
        figlet "$alarm_wakeup_greeting"
    fi
    
    eval $alarm_wakeup_custom_cmd

    if $alarm_wakelock; then
        termux-wake-unlock 
    fi
}


#set alarm

echo "What time should the alarm go off? [HH:MM]"
read target

# sleep interval is 15 minutes
snooze=`dc -e "15 60 *p"`

# convert wakeup time to seconds
target_h=`echo $target | awk -F: '{print $1}'`
target_m=`echo $target | awk -F: '{print $2}'`
target_s_t=`dc -e "$target_h 60 60 ** $target_m 60 *+p"`

# get current time and convert to seconds
clock=`date | awk '{print $4}'`
clock_h=`echo $clock | awk -F: '{print $1}'`
clock_m=`echo $clock | awk -F: '{print $2}'`
clock_s=`echo $clock | awk -F: '{print $3}'`
clock_s_t=`dc -e "$clock_h 60 60 ** $clock_m 60 * $clock_s ++p"`

# calculate difference in times, add number of sec. in day and mod by same
sec_until=`dc -e "24 60 60 **d $target_s_t $clock_s_t -+r%p"`

echo "The alarm will go off at $target. ($sec_until seconds)"

if $alarm_wakelock; then
    termux-wake-lock &
fi

sleep $sec_until

alarm_loop &

E0=$(( $RANDOM % 10 ))
E1=$(( $RANDOM % 10 ))
E2=$(( $RANDOM % 10 ))
E3=$(( $RANDOM % 10 ))

E=($E0 $E1 $E2 $E3)

if $alarm_puzzle_invert; then
    IFS=$'\n' sorted=($(sort -r <<<"${E[*]}"))
    puzzle_target="lowest"
    puzzle_order="descending"
else
    IFS=$'\n' sorted=($(sort <<<"${E[*]}"))
    puzzle_target="highest"
    puzzle_order="ascending"
fi

if $alarm_puzzle_complex; then

    sorted=$(echo ${sorted[@]} | tr -d ' ') 
    instruction_str="\e[1mplease sort the numbers in $puzzle_order order! " 
else
    sorted=$(echo ${sorted[3]} | tr -d ' ')
    instruction_str="\e[1mplease enter the $puzzle_target number! "
fi


while true; do
    clear
    figlet "$E0 $E1 $E2 $E3" | lolcat
    
    echo -e "$instruction_str"
    read z
    z=$(echo "$z" |tr -d ' ')

    if [ "$z" = "$sorted" ]; then
        kill $!
        alarm_wakeup
        exit 0
    fi
done

#!/bin/bash

### AUTHOR:         Johann Birnick (github: jbirnick)
### PROJECT REPO:   https://github.com/jbirnick/polybar-timer

## FUNCTIONS

now () { date --utc +%s; }

killTimer () { rm -rf /tmp/polybar-timer ; }
timerSet () { [ -e /tmp/polybar-timer/ ] ; }
timerPaused () { [ -f /tmp/polybar-timer/paused ] ; }

timerExpiry () { cat /tmp/polybar-timer/expiry ; }
timerLabelRunning () { cat /tmp/polybar-timer/label_running ; }
timerLabelPaused () { cat /tmp/polybar-timer/label_paused ; }
timerAction () { cat /tmp/polybar-timer/action ; }

secondsLeftWhenPaused () { cat /tmp/polybar-timer/paused ; }
minutesLeftWhenPaused () { echo $(( ( $(secondsLeftWhenPaused)  + 59 ) / 60 )) ; }
secondsLeft () { echo $(( $(timerExpiry) - $(now) )) ; }
minutesLeft () { echo $(( ( $(secondsLeft)  + 59 ) / 60 )) ; }

printExpiryTime () { dunstify -u low -r -12345 "Timer expires at $( date -d "$(secondsLeft) sec" +%H:%M)" ;}
printPaused () { dunstify -u low -r -12345 "Timer paused" ; }
removePrinting () { dunstify -C -12345 ; }

updateTail () {
  # check whether timer is expired
  if timerSet
  then
    if { timerPaused && [ $(minutesLeftWhenPaused) -le 0 ] ; } || { ! timerPaused && [ $(minutesLeft) -le 0 ] ; }
    then
      eval $(timerAction)
      dunstify -u timer -r 12345 "Timer expired!"
      killTimer
      removePrinting
    fi
  fi

  # update output
  if timerSet
  then
    if timerPaused
    then
      echo "$(timerLabelPaused) $(minutesLeftWhenPaused)"
    else
      echo "$(timerLabelRunning) $(minutesLeft)"
    fi
  else
    echo "${STANDBY_LABEL}"
  fi
}

usage() {
    cat <<EOF
A script to create, start, and control a timer.
Designed for use within polybar. Check out https://github.com/jbirnick/polybar-timer#example-configuration for an example.

Script usage: $0 [COMMAND] args ...

COMMAND:
  new [m] [rLabel] [pLabel] [action]    - Create a new timer with [m] minutes. Printed as "[rLabel|pLabel] [m]".
                                          [rLabel] is shown while the timer is running, and [pLabel] is shown while the timer is paused.
                                          The action will be executed when the timer expires.
  tail [label] [s]                      - Print the [label], followed by the time left on the timer, every [s] seconds.
                                          This may be used for the exec field in polybar.
  update [pid]                          - Update a running [tail] command identified by its PID [pid].
                                          The PID is provided by polybar with %pid%.
  increase [s]                          - Increase the timer by [s] seconds if it exists.
  togglepause                           - Pause a running timer; Start a paused timer.
  cancel                                - Cancel a timer if it exists.
  help                                  - Print this help.

EOF
}

## MAIN CODE

case $1 in
  tail)
    STANDBY_LABEL=$2

    trap updateTail USR1

    while true
     do
     updateTail
     sleep ${3} &
     wait
    done
    ;;
  update)
    kill -USR1 $(pgrep --oldest --parent ${2})
    ;;
  new)
    killTimer
    mkdir /tmp/polybar-timer
    echo "$(( $(now) + 60*${2} ))" > /tmp/polybar-timer/expiry
    echo "${3}" > /tmp/polybar-timer/label_running
    echo "${4}" > /tmp/polybar-timer/label_paused
    echo "${5}" > /tmp/polybar-timer/action
    printExpiryTime
    ;;
  increase)
    if timerSet
    then
      if timerPaused
      then
        echo "$(( $(secondsLeftWhenPaused) + ${2} ))" > /tmp/polybar-timer/paused
      else
        echo "$(( $(timerExpiry) + ${2} ))" > /tmp/polybar-timer/expiry
        printExpiryTime
      fi
    else
      exit 1
    fi
    ;;
  cancel)
    killTimer
    removePrinting
    ;;
  togglepause)
    if timerSet
    then
      if timerPaused
      then
        echo "$(( $(now) + $(secondsLeftWhenPaused) ))" > /tmp/polybar-timer/expiry
        rm -f /tmp/polybar-timer/paused
        printExpiryTime
      else
        secondsLeft > /tmp/polybar-timer/paused
        rm -f /tmp/polybar-timer/expiry
        printPaused
      fi
    else
      exit 1
    fi
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo -e "For usage type: $0 help\n"
    echo "Please read the manual at https://github.com/jbirnick/polybar-timer ."
    ;;
esac
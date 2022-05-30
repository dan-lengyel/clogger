#!/bin/bash
set -e
############################################################
# Help                                                     #
############################################################
Help()
{
    # Display Help
    echo " _______________________________________________________________________ "
    echo "/ This is a script for setting the log level of the application logger. \\"
    echo "|_______________________________________________________________________|"
    echo "|Syntax: setlevel [-h|l] \$LEVEL [-m] ON/OFF/\$TIME                       |"
    echo "|options:                                                               |"
    echo "|h     Print this Help.                                                 |"
    echo "|l     Sets the log level to \$LEVEL.                                    |"
    echo "|m     Gives further arguments for the METRICS level                    |"
    echo "|The following log levels can be set:                                   |"
    echo "| - OFF: turns all off all logs (not metrics)                           |"
    echo "| - ERROR: only display error logs                                      |"
    echo "| - INFO: only display error and info logs                              |"
    echo "| - DEBUG: display all logs                                             |"
    echo "| - METRICS: turn metrics off/on (for \$TIME amount of minutes)          |"
    echo "|_______________________________________________________________________|"
    echo "|When using the METRICS option, you must also specify the -m option.    |"
    echo "|This takes the following arguments:                                    |"
    echo "| - ON: Turns metrics on.                                               |"
    echo "| - OFF: Turns metrics off.                                             |"
    echo "| - \$TIME: must be a valid number. Will turn on metrics for the         |"
    echo "|          number of minutes specified.                                 |"
    echo "\\_______________________________________________________________________/"
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################
############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":hl:" option; do
    case $option in
        h) # Display help
            Help
            exit;;
        l) # Enter a log level
            level=$OPTARG
            case $level in
                OFF) # All logs off
                    echo "Turning off logs"
                    sed -i -e '/logs.=ERROR/s/^#*/#/g' \
                           -e '/logs.=INFO/s/^#*/#/g' \
                           -e '/logs.=DEBUG/s/^#*/#/g' ./conf/zlog.conf
                    exit;;
                ERROR) # Only show ERROR logs
                    echo "Setting log level to ERROR"
                    sed -i -e '/logs.=ERROR/s/^#*//g' \
                           -e '/logs.=INFO/s/^#*/#/g' \
                           -e '/logs.=DEBUG/s/^#*/#/g' ./conf/zlog.conf
                    exit;;
                INFO) # Only show ERROR and INFO logs
                    echo "Setting log level to INFO"
                    sed -i -e '/logs.=ERROR/s/^#*//g' \
                           -e '/logs.=INFO/s/^#*//g' \
                           -e '/logs.=DEBUG/s/^#*/#/g' ./conf/zlog.conf
                    exit;;
                DEBUG) # Show all logs
                    echo "Setting log level to DEBUG"
                    sed -i -e '/logs.=ERROR/s/^#*//g' \
                           -e '/logs.=INFO/s/^#*//g' \
                           -e '/logs.=DEBUG/s/^#*//g' ./conf/zlog.conf
                    exit;;
                METRICS)
                    while getopts ":m:" suboptions; do
                        case $suboptions in
                            m)
                                timer=$OPTARG
                                case $timer in
                                    ON) # Turn on metrics, uncomment metrics.INFO
                                        echo "Turning metrics ON"
                                        sed -i -e '/metrics.=INFO/s/^#*//g' ./conf/zlog.conf
                                        exit;;
                                    OFF) # Turn off metrics, comment metrics.INFO
                                        echo "Turning metrics OFF"
                                        sed -i -e'/metrics.=INFO/s/^#*/#/g' ./conf/zlog.conf
                                        exit;;
                                    ''|*[!0-9]*) # If not ON, OFF, or a number: exit
                                        echo "Error: invalid argument. Please use OFF, ON, or a valid number."
                                        exit;;
                                    *) # If arg is a valid number, handle it.
                                        if [ $timer -lt 1 ] || [ $timer -gt 180 ] 
                                        then
                                            echo "Error: invalid number. Enter a number between 1 and 180."
                                            exit
                                        fi
                                        if [ $timer -eq 1 ]
                                        then
                                            echo "Turning metrics ON for $((10#$timer)) minute"
                                        else
                                            echo "Turning metrics ON for $((10#$timer)) minutes"
                                        fi
                                        sed -i -e '/metrics.=INFO/s/^#*//g' ./conf/zlog.conf
                                        sleep $timer\m
                                        sed -i -e'/metrics.=INFO/s/^#*/#/g' ./conf/zlog.conf
                                        echo "Turning metrics OFF"
                                        exit;;
                                esac;;                                
                            \?) # Invalid suboption
                                echo "Error: invalid suboption"
                                exit;;
                        esac
                    done
                    ;;
                *)
                    echo "Invalid log level."
                    ;;
            esac
            ;;
        \?) # Invalid option
            echo "Error: invalid option"
            exit;;
    esac
done

Help
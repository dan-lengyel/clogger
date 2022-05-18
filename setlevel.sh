#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
    # Display Help
    echo "This is a script for setting the log level of the application logger."
    echo
    echo "Syntax: setlevel [-h|l] \$LEVEL"
    echo "options:"
    echo "h     Print this Help."
    echo "l     Sets the log level to \$LEVEL."
    echo "The following log levels can be set:"
    echo " - ERROR"
    echo " - INFO"
    echo " - DEBUG"
    echo
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
                ERROR)
                    echo "Setting log level to ERROR"
                    # Comment INFO and DEBUG
                    sed -i -e'/logs.=INFO/s/^#*/#/g' \
                           -e'/logs.=DEBUG/s/^#*/#/g' ./conf/zlog.conf
                    ;;
                INFO)
                    echo "Setting log level to INFO"
                    # Uncomment INFO, comment DEBUG
                    sed -i -e '/logs.=INFO/s/^#*//g' \
                           -e '/logs.=DEBUG/s/^#*/#/g' ./conf/zlog.conf
                    ;;
                DEBUG)
                    echo "Setting log level to DEBUG"
                    # Uncomment INFO and DEBUG
                    sed -i -e '/logs.=INFO/s/^#*//g' \
                           -e '/logs.=DEBUG/s/^#*//g' ./conf/zlog.conf
                    ;;
                *)
                    echo "Invalid log level."
                    ;;
            esac
            exit;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

echo "Use with -h option for help!"
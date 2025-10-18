#!/bin/bash

# Very simple test script to debug Rofi integration

# Log all input for debugging
echo "Script called with: $*" >> /tmp/rofi-debug.log
echo "ROFI_RETV: $ROFI_RETV" >> /tmp/rofi-debug.log
echo "ROFI_INFO: $ROFI_INFO" >> /tmp/rofi-debug.log

# Always return a few simple results for any input
echo -en "Test Result 1\0info\x1ftest1\0icon\x1ftext-x-generic\n"
echo -en "Python Test\0info\x1ftest2\0icon\x1ftext-x-python\n"
echo -en "PDF Document\0info\x1ftest3\0icon\x1fapplication-pdf\n"

# If selection is made
if [ "$ROFI_RETV" = "1" ]; then
    echo "Selection made: $1" >> /tmp/rofi-debug.log
    exit 0
fi

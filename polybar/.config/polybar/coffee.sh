#!/bin/bash

if xset q | grep -q "DPMS is Disabled"; then
    echo "Coffee: on"
else
    echo "Coffee: off"
fi

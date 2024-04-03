#!/bin/bash

pass -c $(pass ls | dmenu -i -l 10 -fn 'Source Code Pro-14' -nb '#282828' -nf '#C5C8C6' -sb '#F074C6' -sf '#282828' | awk '{print $1}')


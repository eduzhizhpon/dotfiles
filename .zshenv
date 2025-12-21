#!/bin/bash

[[ -f $HOME/.core_env ]] && source $HOME/.core_env

# Fix the Java Problem
export _JAVA_AWT_WM_NONREPARENTING=1

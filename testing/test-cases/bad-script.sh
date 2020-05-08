#!/bin/bash

echo $0 # Unquoted variable
var = 42 # Spaces around = in assignments
$foo=42 # $ in assignments

n=0 # Unused variable
if [[ n != 0 ]] # Constant test expressions, should be "$n"
then
echo this is incorrect
fi

PATH="$PATH:~/bin" # Includes tilde in path



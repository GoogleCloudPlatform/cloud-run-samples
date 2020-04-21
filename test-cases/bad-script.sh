#!/bin/bash

echo "Hello World"

if [ $1 -gt 100 ]
then
echo Hey that\'s a large number.
pwd
fi

files=(foo bar); echo "$files"

PATH="$PATH:~/bin" 
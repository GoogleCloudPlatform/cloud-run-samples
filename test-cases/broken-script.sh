#!/bin/bash

n=0
while [ "$n" != 10  ]
do
    count_lines $1 # Not a defined function
    n=$[ $n + 1 ]
done

cd not-a-directory/

while [ "$i" != 10  ] # Not a defined variable
do
    echo $i
done
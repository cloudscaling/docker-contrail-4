#!/bin/bash

scripts=''
for line in $(cat $2); do
  scripts+=$(echo $line | awk -F'=' '{print " -e s/{{"$1"}}/"$2"/g"}')
done

sed $scripts $1

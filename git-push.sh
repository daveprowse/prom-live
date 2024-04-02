#!/bin/bash

## Pushes all content automatically and gives timestamp for date

echo 'Running Script!'
x=`date -I`
echo -n -e "`git add .`"
echo -n -e "`git commit -m $(x)`"
echo "`git push -u origin main`"


testedte


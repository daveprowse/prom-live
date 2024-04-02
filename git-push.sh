#!/bin/bash

## Pushes all content automatically and gives timestamp for date

echo 'Running Script!'
#x=$(date -I)

git add 
git commit -m "$(date -I)"
git push -u origin main

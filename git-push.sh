#!/bin/bash

## Pushes all content automatically and gives timestamp for date

echo 'Running Script!'
x=$(date -I)

echo "$(git add .)"
echo "$(git commit -m '`(date -I)`')"
echo "$(git push -u origin main)"


testedte

test2
test3
test4

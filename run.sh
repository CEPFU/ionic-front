#!/bin/bash
# Add locally installed node modules to path but prefer global ones
PATH=$PATH:$(pwd)/node_modules/.bin
npm install
bower install
killall gulp
mkdir -p ../log
gulp sass coffee yaml watch > ../log/gulp.log &
killall ionic
ionic serve

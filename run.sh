#!/bin/bash
npm install
bower install
killall gulp
mkdir -p ../log
gulp sass coffee yaml watch > ../log/gulp.log &
killall ionic
ionic serve

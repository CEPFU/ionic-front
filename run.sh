#!/bin/bash
npm install
bower install
killall gulp
gulp sass coffee watch > gulp.log &
killall ionic
ionic serve

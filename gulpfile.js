var gulp = require('gulp');
var gutil = require('gulp-util');
var bower = require('bower');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var rename = require('gulp-rename');
var sh = require('shelljs');
var coffee = require('gulp-coffee');
var yaml = require('gulp-yaml');

var paths = {
  sass: ['./www/**/*.scss'],
  coffee: ['./www/**/*.coffee'],
  yaml: ['./www/**/*.yml']
};

gulp.task('default', ['sass']);

gulp.task('yaml', function(done) {
  gulp.src('./www/yaml/**.yml')
    .pipe(yaml())
    .pipe(rename({ extname: '.json' }))
    .pipe(gulp.dest('./www/json'))
    .on('end', done);
});

gulp.task('sass', function(done) {
  gulp.src('./www/sass/**.scss')
    .pipe(sass({ errLogToConsole: true}))
    .pipe(rename({ extname: '.css' }))
    .pipe(concat('style.css'))
    .pipe(gulp.dest('./www/css'))
    .on('end', done);
});

gulp.task('coffee', function(done) {
  gulp.src(paths.coffee)
  .pipe(coffee({bare: false})
  .on('error', gutil.log.bind(gutil, 'Coffee Error')))
  .pipe(concat('application.js'))
  .pipe(gulp.dest('./www/js'))
  .on('end', done)
})

gulp.task('watch', function() {
  gulp.watch(paths.sass, ['sass']);
  gulp.watch(paths.coffee, ['coffee']);
  gulp.watch(paths.yaml, ['yaml']);
});

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
var sourcemaps = require('gulp-sourcemaps');

var paths = {
  sass: ['./scss/*.scss'],
  coffee: ['./www/**/*.coffee'],
  yaml: ['./www/**/*.yml']
};

gulp.task('default', ['yaml', 'sass', 'coffee']);

gulp.task('yaml', function(done) {
  gulp.src('./www/yaml/**.yml')
    .pipe(yaml())
    .pipe(rename({ extname: '.json' }))
    .pipe(gulp.dest('./www/json'))
    .on('end', done);
});

gulp.task('sass', function(done) {
  gulp.src('./scss/*.scss')
    .pipe(sass())
    .on('error', sass.logError)
    .pipe(minifyCss({
      keepSpecialComments: 0
    }))
    .pipe(concat('style.min.css'))
    .pipe(gulp.dest('./www/css/'))
    .on('end', done);
});

gulp.task('coffee', function(done) {
  gulp.src(paths.coffee)
  .pipe(sourcemaps.init())
  .pipe(coffee({bare: false, map: true})
  .on('error', gutil.log.bind(gutil, 'Coffee Error')))
  .pipe(concat('application.js'))
  .pipe(sourcemaps.write('./maps'))
  .pipe(gulp.dest('./www/js'))
  .on('end', done)
})

gulp.task('watch', function() {
  gulp.watch(paths.sass, ['sass']);
  gulp.watch(paths.coffee, ['coffee']);
  gulp.watch(paths.yaml, ['yaml']);
});

gulp.task('install', ['git-check'], function() {
  return bower.commands.install()
    .on('log', function(data) {
      gutil.log('bower', gutil.colors.cyan(data.id), data.message);
    });
});

gulp.task('git-check', function(done) {
  if (!sh.which('git')) {
    console.log(
      '  ' + gutil.colors.red('Git is not installed.'),
      '\n  Git, the version control system, is required to download Ionic.',
      '\n  Download git here:', gutil.colors.cyan('http://git-scm.com/downloads') + '.',
      '\n  Once git is installed, run \'' + gutil.colors.cyan('gulp install') + '\' again.'
    );
    process.exit(1);
  }
  done();
});

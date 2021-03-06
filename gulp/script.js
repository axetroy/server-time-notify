let path = require('path');

let gulp = require('gulp');
let clean = require('gulp-clean');
let dart = require("gulp-dart");
let uglify = require('gulp-uglify');
let header = require('gulp-header');

let {paths} = require('./config');

function headerStream() {
  return header(
    `// ==UserScript==
// @name          server-time-notify (dart)
// @description   当本地时间，于服务器时间，小差较大时，会有提醒
// @version       ${require('../package.json').version}
// @author        Axetroy
// @include       *
// @grant         none
// @run-at        document-start
// @namespace         https://greasyfork.org/zh-CN/users/3400-axetroy
// @license           The MIT License (MIT); http://opensource.org/licenses/MIT
// ==/UserScript==

// Github源码: https://github.com/axetroy/server-time-notify

`);
}

gulp.task('clean', function () {
  return gulp.src(path.join(paths.dist, '*.*'), {read: false})
    .pipe(clean());
});

gulp.task('script', function () {
  return gulp.src(path.join(paths.src, 'index.dart'))
    .pipe(dart({
      "dest": paths.dist,
      // "checked": true
    }))
    .pipe(headerStream())
    .pipe(gulp.dest(''));
});

gulp.task('build', function () {
  return gulp.src(path.join(paths.src, 'index.dart'))
    .pipe(dart({
      "dest": paths.dist,
      "minify": "true",
      // "checked": true
    }))
    .pipe(uglify())
    .pipe(headerStream())
    .pipe(gulp.dest(''));
});

gulp.task('watch', ['clean', 'build'], function () {
  gulp.watch(path.join(paths.src, '*.dart'), ['build']);
});

gulp.task('default', ['clean'], function () {
  // gulp.start('build');
});
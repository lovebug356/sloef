var gulp = require('gulp');
var plugins = require("gulp-load-plugins")({lazy:false});
var coffee = require("coffee-script/register");
var spawn = require('child_process').spawn;

gulp.task('npm', function (done) {
    spawn('npm', ['publish'], { stdio: 'inherit' }).on('close', done);
});

pkg = require('./package.json');

globs = {
}

gulp.task('clean', function(){
  return gulp.src('build', {read:false})
      .pipe(plugins.rimraf());
});

gulp.task('bump', function() {
  gulp.src(['package.json'])
      .pipe(plugins.bump())
      .pipe(gulp.dest('.'))
      .pipe(plugins.git.commit('build: bump version'))
      .pipe(plugins.git.push('origin', 'master'));
});

gulp.task('coffee', function() {
  gulp.src(['src/**/*.js', 'src/**/*.coffee'])
      .pipe(plugins.if (/[.]coffee$/, plugins.coffee()))
      .pipe(gulp.dest('./build'))
});

gulp.task('test', function() {
  gulp.src(['tests/**/*.coffee'], {read: false})
      .pipe(plugins.mocha({
          reporter: 'nyan'
      }))
});

gulp.task('watch',function(){
    gulp.watch(['src/**/*.coffee', 'src/**/*.js'], ['coffee']);
});

gulp.task('build', ['coffee']);
gulp.task('default', ['clean', 'test', 'build']);
gulp.task('publish', ['default', 'bump', 'npm']);

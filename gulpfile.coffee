gulp   = require 'gulp'
coffee = require 'gulp-coffee'
plantuml   = require './coffee/'

gulp.task 'coffee', ->
  gulp.src './coffee/index.coffee'
  .pipe coffee()
  .pipe gulp.dest './'

gulp.task 'sample', ->
  gulp.src './sample/sample.txt'
    .pipe plantuml(
      jarPath: "plantuml.jar"
    )
    .pipe gulp.dest './sample/'

gulp.task 'watch', ->
  gulp.watch './sample/*.txt', ['sample']

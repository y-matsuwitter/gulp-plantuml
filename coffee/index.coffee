spawn       = require('spawn-cmd').spawn
through     = require 'through2'
gutil       = require 'gulp-util'
PluginError = gutil.PluginError

PLUGIN_NAME = 'gulp-plantuml'

module.exports = (options = {}) ->

  # build a command with arguments
  cmnd = 'java'
  args = ['-jar']
  args.push options.jarPath ? "plantuml.jar"
  args.push '-p'

  through.obj (file, encoding, callback) ->
    if file.isNull()
      return callback null, file

    if file.isStream()
      return callback new PluginError PLUGIN_NAME, 'Streaming not supported'

    # relace the extension
    original_file_path = file.path
    ext = if options.erb then '.erb' else '.html'
    file.path = gutil.replaceExtension file.path, '.png'

    program = spawn cmnd, args

    # create buffer
    b = new Buffer 0
    eb = new Buffer 0

    # add data to buffer
    program.stdout.on 'readable', ->
      while chunk = program.stdout.read()
        b = Buffer.concat [b, chunk], b.length + chunk.length

    # return data
    program.stdout.on 'end', ->
      file.contents = b
      callback null, file

    # handle errors
    program.stderr.on 'readable', ->
      while chunk = program.stderr.read()
        eb = Buffer.concat [eb, chunk], eb.length + chunk.length

    program.stderr.on 'end', ->
      if eb.length > 0
        err = eb.toString()
        msg = "Plantuml error in file (#{original_file_path}):\n#{err}"
        return callback new PluginError PLUGIN_NAME, msg

    # pass data to standard input
    program.stdin.write file.contents, ->
      program.stdin.end()

{exec} = require 'child_process'
{dirname} = require 'path'

module.exports =
class RspecHandler

  run: (path, callback) ->
    projectPath = atom.project.getRootDirectory().getPath()
    exec "bash -l -c 'cd #{projectPath} && rspec #{path}'", callback

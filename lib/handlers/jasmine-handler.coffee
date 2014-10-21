{exec} = require 'child_process'
{dirname} = require 'path'

module.exports =
class JasmineHandler

  run: (path, successCallback, errorCallback) ->
    projectPath = atom.project.getRootDirectory().getPath()
    exec "bash -l -c 'cd #{projectPath} && node_modules/jasmine-node/bin/jasmine-node #{path}'", (error) ->
      if error
        errorCallback()
      else
        successCallback()

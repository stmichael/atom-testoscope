{exec} = require 'child_process'
{dirname} = require 'path'

module.exports =
class BaseHandler

  run: (testFilePath, successCallback, errorCallback) ->
    projectPath = atom.project.getRootDirectory().getPath()
    exec "bash -l -c 'cd #{projectPath} && #{@getCommand(testFilePath)}'", (error, stdout, stderr) ->
      if error
        errorCallback()
      else
        successCallback()

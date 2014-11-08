ChildProcess = require 'child_process'
path = require 'path'
os = require 'os'
fs = require 'fs.extra'
JunitReportParser = require '../report-parsers/junit-report-parser'

module.exports =
class BaseHandler

  getReportPath: ->
    path.join(os.tmpDir(), 'test_runner_reports')

  cleanReportPath: ->
    if fs.existsSync(@getReportPath())
      fs.rmrfSync(@getReportPath())
    fs.mkdirSync(@getReportPath())

  run: (testFilePath, successCallback, errorCallback) ->
    @cleanReportPath()
    @executeTestCommand(testFilePath, successCallback, errorCallback)

  executeTestCommand: (testFilePath, successCallback, errorCallback) ->
    ChildProcess.exec @_getBashCommand(testFilePath), (error, stdout, stderr) =>
      @parseErrors(successCallback, errorCallback, error, stdout, stderr)

  _getBashCommand: (testFilePath) ->
    projectPath = atom.project.getPaths()[0]
    "bash -l -c 'cd #{projectPath} && #{@_getCommand(testFilePath, @getReportPath())}'"

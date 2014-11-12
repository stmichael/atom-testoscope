ChildProcess = require 'child_process'
path = require 'path'
os = require 'os'
fs = require 'fs.extra'
Q = require 'q'
JunitReportParser = require '../report-parsers/junit-report-parser'

module.exports =
class BaseHandler

  getReportPath: ->
    path.join(os.tmpDir(), 'test_runner_reports')

  cleanReportPath: ->
    if fs.existsSync(@getReportPath())
      fs.rmrfSync(@getReportPath())
    fs.mkdirSync(@getReportPath())

  run: (testFilePath, successCallback, errorCallback, outputCallback) ->
    @cleanReportPath()
    @executeTestCommand(testFilePath, successCallback, errorCallback, outputCallback)

  executeTestCommand: (testFilePath, successCallback, errorCallback, outputCallback) ->
    defer = Q.defer()
    testCommand = @_spawnCommand(defer, testFilePath)
    testCommand.stdout.setEncoding('utf8');
    testCommand.stdout.on 'data', (data) ->
      defer.notify data
    testCommand.stderr.setEncoding('utf8');
    testCommand.stderr.on 'data', (data) ->
      defer.notify data
    testCommand.on 'exit', (status) =>
      @parseErrors(defer)
    defer.promise

  _spawnCommand: (defer, testFilePath) ->
    projectPath = atom.project.getPaths()[0]
    ChildProcess.spawn(@_getCommand(), @_getCommandArgs(testFilePath, @getReportPath()), {cwd: projectPath})

path = require 'path'
fs = require 'fs'
BaseHandler = require './base-handler'
JunitReportParser = require '../report-parsers/junit-report-parser'

module.exports =
class KarmaHandler extends BaseHandler

  constructor: (options) ->
    super
    options = options || {}
    @configFile = options.config

  _getCommand: ->
    "node_modules/karma/bin/karma"

  _getCommandArgs: (testFilePath) ->
    ['start', @configFile, '--single-run', '--reporters', 'junit,dots']

  _spawnCommand: (defer, testFilePath) ->
    command = super
    command.on 'exit', =>
      projectPath = atom.project.getPaths()[0]
      fs.renameSync(path.join(projectPath, 'test-results.xml'), path.join(@getReportPath(), 'test-results.xml'))
    command

  parseErrors: (defer) ->
    fs.readdir @getReportPath(), (err, files) =>
      if files.length > 0
        file = path.join(@getReportPath(), files[0])
        fs.readFile file, encoding: 'UTF-8', (err, data) =>
          result = new JunitReportParser().parse(data)
          if result.getNumberOfTestcases() > 0
            defer.resolve(result)
          else
            defer.reject()
      else
        defer.reject()

path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
JunitReportParser = require '../report-parsers/junit-report-parser'

module.exports =
class KarmaHandler extends BaseHandler

  constructor: (options) ->
    super
    options = options || {}
    @configFile = options.config

  _getCommand: (testFilePath) ->
    "node_modules/karma/bin/karma start #{@configFile} --single-run --reporters junit,dots; mv #{atom.project.getPaths()[0]}/test-results.xml #{@getReportPath()}"

  parseErrors: (successCallback, errorCallback, error, stdout, stderr) ->
    file = path.join(@getReportPath(), 'test-results.xml')
    if fs.existsSync(file)
      fs.readFile file, encoding: 'UTF-8', (err, data) =>
        result = new JunitReportParser().parse(data)
        if result.getNumberOfTestcases() > 0
          successCallback(result)
        else
          errorCallback(stdout)
    else
      errorCallback(stderr)

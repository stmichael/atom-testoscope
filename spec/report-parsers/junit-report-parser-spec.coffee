JunitReportParser = require '../../lib/report-parsers/junit-report-parser'

describe 'JunitReportParser', ->

  report = '''
<?xml version="1.0" encoding="UTF-8" ?>
<testsuites>
  <testsuite name="jasmine test suite" errors="0" tests="1" failures="1" time="0.007" timestamp="2014-10-22T15:13:53">
    <testcase classname="jasmine test suite" name="a failing test" time="0.003">
      <failure type="expect" message="Expected true to equal false.">
        Error: Expected true to equal false.
        at new jasmine.ExpectationResult (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:114:32)
        at null.&amp;lt;anonymous&amp;gt; (/Users/someuser/Projects/atom/test-runner/lib/file.js:83:18)
        at null.toEqual (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1316:29)
        at null.&amp;lt;anonymous&amp;gt; (/Users/someuser/Projects/atom/test-runner/spec/fixtures/node_modules/some_library.js:64:98)
        at null.&amp;lt;anonymous&amp;gt; (/Users/someuser/Projects/atom/test-runner/spec/fixtures/fail_spec.js:6:18)
        at jasmine.Block.execute (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1145:17)
        at jasmine.Queue.next_ (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)
        at jasmine.Queue.start (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)
        at jasmine.Spec.execute (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2458:14)
        at jasmine.Queue.next_ (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)
        at jasmine.Queue.start (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)
        at jasmine.Suite.execute (/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2604:14)
      </failure>
    </testcase>
  </testsuite>
</testsuites>
  '''

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner/dummy'])

  it 'converts an junit report into an object', ->
    parser = new JunitReportParser
    results = parser.parse(report)

    expect(results.length).toEqual 1
    result = results[0]
    expect(result.namespace).toEqual 'jasmine test suite'
    expect(result.name).toEqual 'a failing test',
    expect(result.message).toEqual 'Expected true to equal false.',
    expect(result.file).toEqual 'spec/fixtures/fail_spec.js',
    expect(result.line).toEqual '6'
    expect(result.stacktrace).toEqual [
      {file: '/Users/someuser/Projects/atom/test-runner/lib/file.js', line: '83', caller: 'null.<anonymous>'}
      {file: '/Users/someuser/Projects/atom/test-runner/spec/fixtures/fail_spec.js', line: '6', caller: 'null.<anonymous>'}
    ]
    expect(result.fullStacktrace).toEqual [
      {caller: 'new jasmine.ExpectationResult', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '114'}
      {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/test-runner/lib/file.js', line: '83'}
      {caller: 'null.toEqual', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '1316'}
      {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/test-runner/spec/fixtures/node_modules/some_library.js', line: '64'}
      {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/test-runner/spec/fixtures/fail_spec.js', line: '6'}
      {caller: 'jasmine.Block.execute', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '1145'}
      {caller: 'jasmine.Queue.next_', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '2177'}
      {caller: 'jasmine.Queue.start', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '2130'}
      {caller: 'jasmine.Spec.execute', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '2458'}
      {caller: 'jasmine.Queue.next_', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '2177'}
      {caller: 'jasmine.Queue.start', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '2130'}
      {caller: 'jasmine.Suite.execute', file: '/Users/someuser/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js', line: '2604'}
    ]

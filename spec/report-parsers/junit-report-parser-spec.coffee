JunitReportParser = require '../../lib/report-parsers/junit-report-parser'

describe 'JunitReportParser', ->

  report = '''
<?xml version="1.0" encoding="UTF-8" ?>
<testsuites>
  <testsuite name="jasmine test suite" errors="0" tests="1" failures="1" time="0.007" timestamp="2014-10-22T15:13:53">
    <testcase classname="jasmine test suite" name="a failing test" time="0.003">
      <failure type="expect" message="Expected true to equal false.">
        Error: Expected true to equal false.
        at new jasmine.ExpectationResult (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:114:32)
        at null.&amp;lt;anonymous&amp;gt; (/Users/stmichael/Projects/atom/test-runner/lib/file.js:83:18)
        at null.toEqual (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1316:29)
        at null.&amp;lt;anonymous&amp;gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/node_modules/some_library.js:64:98)
        at null.&amp;lt;anonymous&amp;gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/fail_spec.js:6:18)
        at jasmine.Block.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1145:17)
        at jasmine.Queue.next_ (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)
        at jasmine.Queue.start (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)
        at jasmine.Spec.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2458:14)
        at jasmine.Queue.next_ (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)
        at jasmine.Queue.start (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)
        at jasmine.Suite.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2604:14)
      </failure>
    </testcase>
  </testsuite>
</testsuites>
  '''

  it 'converts an junit report into an object', ->
    parser = new JunitReportParser
    results = parser.parse(report)

    expect(results.length).toEqual 1
    result = results[0]
    expect(result.namespace).toEqual 'jasmine test suite'
    expect(result.name).toEqual 'a failing test',
    expect(result.message).toEqual 'Expected true to equal false.',
    expect(result.file).toEqual 'fail_spec.js',
    expect(result.line).toEqual '6'
    expect(result.stacktrace).toEqual [
      'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/lib/file.js:83:18)',
      'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/fail_spec.js:6:18)'
    ]
    expect(result.fullStacktrace).toEqual [
      'Error: Expected true to equal false.',
      'at new jasmine.ExpectationResult (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:114:32)',
      'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/lib/file.js:83:18)',
      'at null.toEqual (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1316:29)',
      'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/node_modules/some_library.js:64:98)',
      'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/fail_spec.js:6:18)',
      'at jasmine.Block.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1145:17)',
      'at jasmine.Queue.next_ (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)',
      'at jasmine.Queue.start (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)',
      'at jasmine.Spec.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2458:14)',
      'at jasmine.Queue.next_ (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)',
      'at jasmine.Queue.start (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)',
      'at jasmine.Suite.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2604:14)'
    ]

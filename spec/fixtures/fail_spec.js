describe('jasmine test suite', function() {

  it('a failing test', function() {
    console.log('output from the test');
    expect(true).toEqual(false);
  });

});

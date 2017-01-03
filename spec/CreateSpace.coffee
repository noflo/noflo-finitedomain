noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-finitedomain'

describe 'CreateSpace component', ->
  c = null
  start = null
  space = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'finitedomain/CreateSpace', (err, instance) ->
      return done err if err
      c = instance
      start = noflo.internalSocket.createSocket()
      space = noflo.internalSocket.createSocket()
      c.inPorts.start.attach start
      c.outPorts.space.attach space
      done()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.start).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.space).to.be.an 'object'

  describe 'creating a computing space', ->
    it 'should be able to initialize one', (done) ->
      space.on 'data', (space) ->
        chai.expect(space).to.be.an 'object'
        chai.expect(space.propagate).to.be.a 'function'
        done()
      start.send null

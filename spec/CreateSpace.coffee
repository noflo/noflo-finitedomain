noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  CreateSpace = require '../components/CreateSpace.coffee'
else
  CreateSpace = require 'noflo-finitedomain/components/CreateSpace.js'

describe 'CreateSpace component', ->
  c = null
  start = null
  space = null
  beforeEach ->
    c = CreateSpace.getComponent()
    start = noflo.internalSocket.createSocket()
    space = noflo.internalSocket.createSocket()
    c.inPorts.start.attach start
    c.outPorts.space.attach space

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

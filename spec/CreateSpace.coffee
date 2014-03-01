noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  CreateSpace = require '../components/CreateSpace.coffee'
else
  CreateSpace = require 'noflo-finitedomain/components/CreateSpace.js'

describe 'CreateSpace component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = CreateSpace.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'creating a computing space', ->
    it 'should be able to initialize one', (done) ->
      out.on 'data', (space) ->
        chai.expect(space).to.be.an 'object'
        chai.expect(space.propagate).to.be.a 'function'
        done()
      ins.send null

noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai

describe 'Finite Domain Constrain Solver', ->
  class Callback extends noflo.Component
    constructor: ->
      @cb = null
      @end = null
      @inPorts =
        in: new noflo.Port
        callback: new noflo.Port
        end: new noflo.Port
      @inPorts.callback.on 'data', (@cb) =>
      @inPorts.end.on 'data', (@end) =>
      @inPorts.in.on 'data', (data) =>
        @cb data
      @inPorts.in.on 'disconnect', =>
        @end()
  Callback.getComponent = -> new Callback

  describe 'solving a simple inequality constraint', ->
    it 'should be able to solve', (done) ->
      fbp = """
      'X' -> VARIABLE DecX(finitedomain/DeclareVariable)
      '[[5, 10]]' -> DOMAIN DecX
      'Y' -> VARIABLE DecY(finitedomain/DeclareVariable)
      '[[8, 20]]' -> DOMAIN DecY
      'X' -> GREATER Gt(finitedomain/GreaterThan)
      'Y' -> THAN Gt
      'X,Y' -> VARIABLES Solve(finitedomain/Solve)
      Init(finitedomain/CreateSpace) SPACE -> SPACE DecX
      DecX SPACE -> SPACE DecY SPACE -> SPACE Gt
      Gt SPACE -> SPACE Solve
      Solve SOLUTION -> IN Callback(Callback)
      """
      noflo.graph.loadFBP fbp.trim(), (graph) ->
        graph.baseDir = 'noflo-finitedomain'
        noflo.createNetwork graph, (network) ->
          network.loader.components.Callback = Callback
          network.connect ->
            solutions = 0
            graph.addInitial (data) ->
              chai.expect(data).to.be.an 'object'
              chai.expect(data.X).to.be.a 'number'
              chai.expect(data.Y).to.be.a 'number'
              chai.expect(data.X).to.be.above data.Y
              solutions++
            , 'Callback', 'callback'
            graph.addInitial ->
              chai.expect(solutions).to.be.above 3
              done()
            , 'Callback', 'end'
            graph.addInitial null, 'Init', 'start'
            network.start()
        , true

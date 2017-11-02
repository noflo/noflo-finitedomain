noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  path = require 'path'

describe 'Finite Domain Constrain Solver', ->
  Callback = ->
    c = new noflo.Component
    c.inPorts.add 'in'
    c.inPorts.add 'callback'
    c.inPorts.add 'end'
    c.forwardBrackets = {}
    c.process (input, output) ->
      return unless input.hasData 'callback', 'end'
      return unless input.hasStream 'in'
      [end, callback] = input.getData 'end', 'callback'
      stream = input.getStream 'in'
      for packet in stream
        continue unless packet.type is 'data'
        callback packet.data
      do end
      do output.done

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
      noflo.graph.loadFBP fbp.trim(), (err, graph) ->
        return done err if err
        graph.baseDir = 'noflo-finitedomain' if noflo.isBrowser()
        graph.baseDir = path.resolve(__dirname, '../') unless noflo.isBrowser()
        noflo.createNetwork graph, (err, network) ->
          return done err if err
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
            network.start (err) ->
              return done err if err
        , true

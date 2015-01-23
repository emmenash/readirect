should = require 'should'
supertest = require 'supertest'
connect = require 'connect'

readirect = null
describe 'readirect', ->
  it 'exposes a module', ->
    readirect = require './readirect'
    readirect.should.be.an.object
  server = beforeEach -> server = connect()
  it 'works as connect middleware', ->
    server.use readirect()
    server.use (req, res)->res.end 200
    supertest(server).get('/').expect 200
should = require 'should'
supertest = require 'supertest'
connect = require 'connect'
rx = require 'regexify'


readirect = null
describe 'readirect', ->
  it 'exposes a module', ->
    readirect = require './readirect'
    readirect.should.be.an.object
  server = beforeEach -> server = connect()
  it 'works as connect middleware', (done)->
    server.use readirect()
    server.use (req, res)->res.end 'OK'
    supertest(server).get('/').expect 200
    .end done
  it 'lets you configure redirects based on regex capture groups', (done)->
    r = readirect()
    username = repo = /[^\/]+/
    r.from rx "github.com/#{rx username}/#{rx repo}"
    .redirect (username, repo)->"/repos/#{repo}/fork/#{username}"
    server.use r
    server.use (req, res)->res.end 'OK'
    supertest server
    .get '/'
    .set 'Referer', 'https://github.com/test-user/test-repo'
    .expect 'Location', '/repos/test-repo/fork/test-user'
    .end done
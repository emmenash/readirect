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

  it 'lets you configure redirects from referrers', (done)->
    r = readirect()
    username = repo = /[^\/]+/
    r.from.referrer rx "github.com/#{rx username}/#{rx repo}"
    .to (username, repo)->"/repos/#{repo}/fork/#{username}"
    server.use r
    server.use (req, res)->res.end 'OK'
    supertest server
    .get '/'
    .set 'Referer', 'https://github.com/test-user/test-repo'
    .expect 'Location', '/repos/test-repo/fork/test-user'
    .end done

  it 'lets you configure redirects from urls', (done)->
    r = readirect()
    r.from.url rx "/blog/#{rx /([\d]{4})-[\d\-]+/}/#{rx /[\w\-]+/}"
    .to (date, year, title)->"/legacy/#{title}-#{year}"
    server.use r
    server.use (req, res)->res.end 'OK'
    supertest server
    .get '/blog/2007-03-02/fun-times-to-happen'
    .expect 'Location', '/legacy/fun-times-to-happen-2007'
    .end done

  it 'lets you chain multiple redirects for ease of use', (done)->
    username = repo = ref = /[^\/]+/
    server.use do -> 
      readirect().from.referrer rx "github.com/#{rx username}/#{rx repo}#{rx /$/}"
      .to (username, repo)->"/repos/#{repo}/fork/#{username}"
      .from.url rx "/blog/#{rx /([\d]{4})-[\d\-]+/}/#{rx /[\w\-]+/}"
      .to (date, year, title)->"/legacy/#{title}-#{year}"

    server.use (req, res)->res.end 'OK'
    supertest server
    .get '/'
    .set 'Referer', 'https://github.com/test-user/test-repo'
    .expect 'Location', '/repos/test-repo/fork/test-user'
    .end ->
      supertest server
        .get '/blog/2007-03-02/fun-times-to-happen'
        .expect 'Location', '/legacy/fun-times-to-happen-2007'
        .end done

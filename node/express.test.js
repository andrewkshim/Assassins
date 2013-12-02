var superagent = require('superagent')
var expect = require('expect.js')

function userPath(path) {
  return 'http://localhost:8080/users/' + path
}

function gamePath(path) {
  return 'http://localhost:8080/games/' + path
}


describe('express rest api server', function(){
  var userId, 
    gameId,
    TEST_USERNAME, 
    TEST_PASSWORD;
  TEST_USERNAME = "HELLO"
  TEST_PASSWORD = "WORLD"
  NEW_TEST_PASSWORD = "NEW_WORLD"

  it('gets all users', function(done) {
    superagent.get(userPath(''))
      .end(function(err, response) {
        expect(err).to.eql(null)
        expect(response.status).to.eql(200)
        done()
      })
  })

  it('creates user', function(done) {
    superagent.post(userPath('new'))
      .send({ 
        name: TEST_USERNAME,
        password: TEST_PASSWORD    
      })
    .end(function(err, response) {
      expect(err).to.eql(null) 
      console.log(response.body)
      userId = response.body._id;
      console.log("UserID: " + userId);
      expect(response.body.name).to.eql(TEST_USERNAME)
      done()
    }) 
  })

  it('updates user', function(done) {
    superagent.put(userPath(userId)) 
      .send({
        password: NEW_TEST_PASSWORD
      })
      .end(function(err, response) {
        expect(err).to.eql(null) 
        expect(response.status).to.eql(200)
        done()
      })
  })

  it('creates game', function(done) {
    superagent.post(gamePath('new')) 
      .send({
        creatorId: userId 
      })
      .end(function(err, response) {
        expect(err).to.eql(null)
        console.log('creating game')
        console.log(response.body)
        gameId = response.body._id
        expect(gameId).not.to.be(undefined)
        done()
      })
  })

  it('adds user to game', function(done) {
    superagent.put(gamePath([gameId, 'addUser'].join('/'))) 
      .send({
        userID: userId,
        markerID: 1
      })
      .end(function(err, response) {
        expect(err).to.eql(null) 
        expect(response.status).to.eql(200)
        done()
      })
  })

  it('assigns targets in game', function(done) {
    superagent.put(gamePath([gameId, 'assignTargets'].join('/')))     
      .end(function(err, response) {
          expect(err).to.eql(null) 
          expect(response.status).to.eql(200)
          done()
      })
  })

  it('removes user from game', function(done) {
    superagent.put(gamePath([gameId, 'removeUser'].join('/'))) 
      .send({
        userId: userId 
      })
      .end(function(err, response) {
        expect(err).to.eql(null) 
        expect(response.status).to.eql(200)
        done()
      })
  })

  it('deletes user', function(done) {
    superagent.del(userPath(userId))
    .end(function(err, response) {
      expect(err).to.eql(null) 
      expect(response.status).to.eql(200)
      done()
    })
  })




})

express = require('express')
mongoskin = require('mongoskin')
http = require('http')
routes = require('./routes')

app = express()
app.set('port', process.env.PORT || 8080)
app.use(express.bodyParser())

httpserver = http.createServer(app).listen(app.get('port'), () ->
  console.log('Express server listening on port ' + app.get('port'))
)

app.get('/', routes.index)
app.get('/users', routes.users.all)
app.post('/users/new', routes.users.new)
app.post('/users/signin', routes.users.signin)
app.post('/users/:id/signout', routes.users.signout)
app.put('/users/:id', routes.users.update)
app.del('/users/:id', routes.users.delete)
app.get('/users/createdGames/:creatorId', routes.users.createdGames)
app.get('/users/:id/targets', routes.users.targets)

app.post('/games/new', routes.games.new)
app.post('/games/newWithUsers', routes.games.newWithUsers)
app.put('/games/:gameId/addUser', routes.games.addUser)
app.put('/games/:gameId/removeUser', routes.games.removeUser)
app.put('/games/:gameId/assignTargets', routes.games.assignTargets)
app.post('/games/:gameId/attack', routes.games.attack)


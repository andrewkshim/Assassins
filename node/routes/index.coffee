db = require('../database')
users = db.collection('users')
games = db.collection('games')
util = require('util')

exports.index = (req,res) ->
  res.send("Hello Assassin")

isValidUserParams = (userParams) ->
  userParams.name and userParams.password and userParams.email ? true : false

isExistingUser = (userParams, trueCallback, falseCallback) ->
  users.findOne({ username: userParams.name }, (err, user) ->
    if (err)
      return next(err)
    if (user)
      trueCallback(user)
    else
      falseCallback()
  )

exports.users = {}
exports.users.all = (req,res) ->
  users.find().toArray( (err, results) ->
    if (err)
      return next(err)
    res.send(200, results)
  )

exports.users.new  = (req,res) ->
  console.log('Creating user')
  console.log(req.body)
  userParams = req.body
  if (isValidUserParams(userParams))
    users.findOne(userParams, (err, user) ->
      if (err)
        return next(err)
      if (user)
        console.log("User exists")
        res.send(400, {
          _id: user._id
          error: 'User exists'
        })
      else
        users.insert({
          name: userParams.name.trim()
          email: userParams.email.trim()
          password: userParams.password.trim()
          signedIn: false
        }, {}, (err, results) ->
          if (err)
            return next(err)
          console.log("=====")
          console.log(results[0])
          user = results[0]
          console.log("Creating user: " + user)
          res.send(200, user)
        )
    )
  else
    res.send(400, { error: 'Invalid params' })

exports.users.signin = (req,res) ->
  console.log('Signing in user')
  console.log(req.body)
  userParams = req.body
  users.findOne({ name: userParams.name }, (err, user) ->
    if (err)
      return next(err)
    if (user)
      if (userParams.password is user.password)
        users.update(
          { _id: users.id(user._id) }
          { $set: {
              signedIn: true
            }
          }
          (err, result) ->
            if (err)
              res.send(500, { error: 'Server crashed' } )
              return next(err)
            return res.send(200, user)
        )
      else
        res.send(400, { error: 'Incorrect password' })
    else
      res.send(400, { error: 'User does not exist' })
  )

exports.users.signout = (req,res) ->
  console.log('Signing out user')
  userId = users.id(req.params.id)
  users.findOne({ _id: userId }, (err, user) ->
    if (user)
      users.update(
        { _id: userId }
        { $set: {
          signedIn: false
        }
        }
        (err, result) ->
          if (err)
            res.send(500, { error: 'Server crashed on sign out' } )
            return next(err)
          return res.send(200)
      )
    else
      return res.send(400, { error: 'User does not exist' })
  )
     
exports.users.update = (req,res) ->
  userId = req.params.id
  userParams = req.body
  users.update(
    { _id: users.id(userId) }
    { $set: userParams }
    { safe: true, multi: false }
    (err, result) ->
      if (err)
        return next(err)
      res.send(!result ? 400 : 200)
  )

exports.users.delete = (req,res) ->
  userId = req.params.id
  console.log('deleting user id ' + userId)
  users.remove(
    { _id: users.id(userId) }
    (err, result) ->
      if (err)
        return next(err)
      res.send(200)
  )

exports.games = {}
exports.games.new = (req,res) ->
  creatorId = req.body.creatorId
  if (creatorId)
    gameParams = req.body
    games.insert(gameParams, {}, (err, results) ->
      games.findOne({}, { sort: [[ '_id', -1 ]] }, (err, game) ->
        if (err)
          return next(err)
        console.log("Creating game: ")
        console.log(game)
        res.send(200, game)
      )
    )
  else
    res.send(400, { error: 'Creator id needed' })
    
exports.games.addUser = (req,res) ->
  markerID = req.body.markerID
  userID = users.id(req.body.userID)
  if (not markerID or not userID)
    return res.send(400)
  users.findOne({
    _id: userID
  }, (err, user) ->
    if (err)
      return next(err)
    if (user)
      games.update({
        _id: games.id(req.params.gameId)
      }, {
        $addToSet: {
          'userIds': userID
        }
      }, (err, results) ->
        if (err)
          return next(err)
        users.update(
          { _id: userID }
          { $set: {
              markerID: markerID
            }
          }, (err, result) ->
            if (err)
              return next(err)
            return res.send(200)
        )
      )
    else
      return res.send(400, {
        error: 'No users added'
      })
  )

exports.games.removeUser = (req, res) ->
  userId = users.id(req.body.userId)
  gameId = games.id(req.params.gameId)
  if (userId)
    users.findOne(
      { _id: userId }
      {}, (err, user) ->
        games.update(
          { _id: gameId }
          { $pull: {
              'userIds': userId
            }
          }, (err, results) ->
            if (err)
              return next(err)
            res.send(200)
        )
    )
  else
    res.send(400)

exports.games.assignTargets = (req,res) ->
  gameId = games.id(req.params.gameId)
  if (gameId)
    console.log('Assigning users')
    res.send(200)
    games.findOne(
      { _id: gameId }
      {}, (err, game) ->
        firstUser = null
        currentUser = null
        nextUser = null
        numberOfAssignedUsers = 0
        console.log('  Looping through users')
        console.log(game)
        userIds = game.userIds.forEach( (userId) ->
          userId = users.id(userId)
          userObjects = []
          console.log(userIds)
          users.findOne(
            { _id: userId }, (err, user) ->
              if (err)
                return next(err)

              userObjects.push(user)
              console.log("User =====")
              console.log(user)
              if (not currentUser)
                currentUser = user
                firstUser = user
              else
                nextUser = user
                users.update({
                  _id: users.id(currentUser._id)
                }, {
                  $set: { $targetId: nextUser._id }
                }, (err, result) ->
                  if (err)
                    return next(err)
                  currentUser = nextUser
                  ++numberOfAssignedUsers
                  if (numberOfAssignedUsers is userIds.length)
                    users.update({
                      _id: users.id(currentUser._id)
                    }, {
                      $set: {$targetId: firstUser._id }
                    })
                    console.log('All users assigned')
                )
          )
        )
    )
  else
    res.send(400)

exports.games.attack = (req, res) ->
  attackingUserId = users.id(req.body.attackingUserId)
  targetMarkerId = req.body.targetMarkerId
  gameId = games.id(req.params.gameId)
  console.log(util.format('Attacking user: %s - targeted markerID: %s', attackingUserId, targetMarkerId))
  if (not attackingUserId or targetMarkerId or gameId)
    users.findAndModify({
      query: { markerID: targetMarkerId }
      update: { $set: { markerID: -1 } }
    }, (err, attackedUser) ->
      if (err)
        return next(err)
      if (attackedUser)
        games.update({
          _id: gameId
        }, {
          $pull: {
            'userIds': users.id(attackedUser._id)
          }
        }, (err, results) ->
          if (err)
            return next(err)
          return res.send(200)
        )
        # also update attacking users score
      else
        return res.send(400)
    )
  else
    return res.send(400, { error: 'Invalid parameters' })

  
  

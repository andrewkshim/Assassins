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

assignTargets = (gameId, res) ->
 if (gameId)
    console.log('Assigning users')
    games.findOne(
      { _id: gameId }
      {}, (err, game) ->
        if (err)
          return next(err)
        firstUser = null
        currentUser = null
        nextUser = null
        numberOfAssignedUsers = 0
        console.log('  Looping through users')
        console.log(game)
        res.send(200, game)
        game.userIds.forEach( (userId) ->
          userId = users.id(userId)
          userObjects = []
          users.findOne(
            { _id: userId }, (err, user) ->
              if (err)
                return next(err)

              userObjects.push(user)
              if (currentUser is null)
                console.log("FIRST USER =====")
                console.log(user)
                currentUser = user
                firstUser = user
              else
                console.log("Current USER =====")
                console.log(currentUser)
                nextUser = user
                users.update({
                  _id: users.id(currentUser._id)
                }, {
                  $addToSet: { 'targets': {
                      _id: nextUser._id
                      name: nextUser.name
                      markerId: nextUser.markerId
                      gameId: gameId
                    }
                  }
                }, (err, result) ->
                  if (err)
                    return next(err)
                  ++numberOfAssignedUsers
                  console.log('NUMBER: ' + numberOfAssignedUsers)
                  if (numberOfAssignedUsers is game.userIds.length-1)
                    users.update({
                      _id: users.id(currentUser._id)
                    }, {
                      $addToSet: { 'targets': {
                          _id: users.id(firstUser._id)
                          name: firstUser.name
                          markerId: firstUser.markerId
                        }
                      }
                    }, (err, results) ->
                    )
                    console.log('All users assigned')
                )
                currentUser = nextUser
          )
        )
    )
  else
    res.send(400)



exports.users = {}
exports.users.all = (req,res) ->
  console.log("Getting all users")
  users.find().toArray( (err, results) ->
    if (err)
      return next(err)
    userData = results.map( (user) ->
      name = user.name
      if name is undefined
        name = "Unknown assassin"
      return {
        name: name
        _id: user._id
      }
    )
    res.send(200, { users: userData })
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

exports.users.createdGames = (req, res) ->
  creatorId = users.id(req.params.creatorId)
  if (creatorId)
    users.findOne({ _id: creatorId }, (err, user) ->
      if (err)
        return next(err)
      return res.send(200, user.createdGameIds)
    )
  else
    return res.send(400, { error: 'Creator id required' })
  
exports.users.targets = (req, res) ->
  userId = users.id(req.params.id)
  console.log('getting users targets')
  if (userId)
    users.findOne({ _id: userId }, (err, user) ->
      if (err)
        return next(err)
      console.log({
        targets: user.targets
      })
      return res.send(200, { targets: user.targets })
    )
  else
    return res.send(400, { error: 'User id required' })


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

exports.games.newWithUsers = (req, res) ->
  creatorId = users.id(req.body.creatorId)
  console.log("Creating new game with users")
  console.log(req.body)
  if (creatorId)
    gameParams = req.body
    games.insert(gameParams, {}, (err, results) ->
      games.findOne({}, { sort: [[ '_id', -1 ]] }, (err, game) ->
        if (err)
          return next(err)
        console.log("Creating game: ")
        console.log(game)
        users.update(
          { _id: creatorId }
          { $addToSet: {
              'createdGameIds': games.id(game._id)
            }
          }
          (err, results) ->
            if (err)
              return next(err)
        )
        assignTargets(games.id(game._id), res)
        count = 1
        game.userIds.forEach( (userId) ->
          users.update(
            { _id: users.id(userId) }
            { $set: {
                'markerId': count++
              }
            }
            (err, results) ->
              if (err)
                console.log('could not update')
          )

        )
      )
    )
  else
    res.send(400, { error: 'Creator id needed' })
 
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
  assignTargets(gameId, res)

getUsersNextTarget = (user, gameId) ->
  nextTargetUser = user.targets[0]
  if (nextTargetUser && nextTargetUser.gameId is gameId)
    return nextTargetUser
  console.log('targeting')
  console.log(user)
  nextTargetUser = nextUser for nextUser in user.targets when nextUser.gameId is gameId
  return nextTargetUser

exports.games.attack = (req, res) ->
  attackingUserId = users.id(req.body.attackingUserId)
  targetUserId = users.id(req.body.targetUserId)
  gameId = games.id(req.params.gameId)
  console.log(util.format('Attacking user: %s - targeted user: %s', attackingUserId, targetUserId))
  if (attackingUserId and targetUserId and gameId)
    users.update(
      { _id: attackingUserId }
      { $pull: {
          'targets': { _id: targetUserId }
        }
      }
      (err, result) ->
        if (err)
          return console.log(err)
        console.log('attacking user updated')
        games.findOne(
          { _id: gameId }
          (err, game) ->
            if (err)
              return console.log(err)
            games.update(
              { _id: gameId }
              { $pull: {
                  'userIds': targetUserId
                }
              }
              (err, result) ->
                if (err)
                  return console.log(err)
                return console.log('updated game')
            )
            users.findOne(
              { _id: targetUserId }
              (err, previousTargetUser) ->
                if (err)
                  return console.log(err)
                users.update(
                  { _id: targetUserId }
                  { $set: { markerId: -1 } }
                  (err, results) ->
                    if (err)
                      return console.log(err)
                    return console.log('target updated')
                )
                nextTargetUser = getUsersNextTarget(previousTargetUser, gameId)
                if (game.userIds.length is 1)
                  return res.send(200, { isWinner: 'true' })
                if (not nextTargetUser)
                  return res.send(500, { error: 'Could not find next target' })
                return res.send(200, {
                  isWinner: 'false'
                  previousTargetName: previousTargetUser.name
                  nextTargetName: nextTargetUser.name
                })
                  # TODO: update attacking user
            )
        )
    )
  else
    return res.send(400, { error: 'Invalid parameters' })

  
  

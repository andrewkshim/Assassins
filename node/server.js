var express = require('express')
  , mongoskin = require('mongoskin')

var app = express()
app.use(express.bodyParser())

var db = mongoskin.db('localhost:27017/test', {safe:true});

app.param('collectionName', function(req, res, next, collectionName){
  req.collection = db.collection(collectionName)
  return next()
})
app.get('/', function(req, res) {
  res.send('please select a collection, e.g., /collections/messages')
})

app.get('/collections/:collectionName', function(req, res) {
  req.collection.find({},{limit:10, sort: [['_id',-1]]}).toArray(function(e, results){
    if (e) return next(e)
    res.send(results)
  })
})

app.post('/users', function(req, res) {
  console.log(req.body);
  db.collection("users").insert(req.body, {}, function(e, results) {
    if (e) return next(e)
    res.send(results)
  })
})

app.get('/collections/:collectionName/:id', function(req, res) {
  req.collection.findOne({_id: req.collection.id(req.params.id)}, function(e, result){
    if (e) return next(e)
    res.send(result)
  })
})
app.put('/collections/:collectionName/:id', function(req, res) {
  req.collection.update({_id: req.collection.id(req.params.id)}, {$set:req.body}, {safe:true, multi:false}, function(e, result){
    if (e) return next(e)
    res.send((result===1)?{msg:'success'}:{msg:'error'})
  })
})
app.del('/collections/:collectionName/:id', function(req, res) {
  req.collection.remove({_id: req.collection.id(req.params.id)}, function(e, result){
    if (e) return next(e)
    res.send((result===1)?{msg:'success'}:{msg:'error'})
  })
})

app.listen(3000)

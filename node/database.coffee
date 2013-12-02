databaseUrl = 'localhost:27017/'
databaseName = 'Assassins'
mongo = require('mongoskin')

db = mongo.db(
  databaseUrl,
  database: databaseName,
  safe: true
)

module.exports = db


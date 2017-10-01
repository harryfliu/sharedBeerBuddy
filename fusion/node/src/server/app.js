var Express = require('express'); 
var App = Express(); 
var Router = Express.Router()
var YELPSERVICE = require('../services/yelp-service').Router; 

App.get('/pingService', function(request, response){
    response.send('SUCCES')
});
//localhost:5858/getBeer
App.use('/getBeer', YELPSERVICE)

module.exports = App;
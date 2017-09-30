'use strict';

const yelp = require('yelp-fusion');
var i = 0;

// Place holders for Yelp Fusion's OAuth 2.0 credentials. Grab them
// from https://www.yelp.com/developers/v3/manage_app
const clientId = 'Sge8Bu-UokjPscJR1Xd9yw';
const clientSecret = 'vI44X2b1JnhCFQEPUfEAmHKL4HUx8BjV2M7crwqtEsaEuTQaIHrhfnGOqU8pZT5z';

const searchRequest = {
  term:'beer',
  location: 'san jose, ca',
  radius: 25000,
  limit: 10,
  sort_by: 'rating',
  price: '1, 2, 3',
  open_now: true
};

var venue_names = [];

yelp.accessToken(clientId, clientSecret).then(response => {
  const client = yelp.client(response.jsonBody.access_token);

  client.search(searchRequest).then(response => {
    for (i = 0; i < response.jsonBody.businesses.length; i++) {
      const allResults_names = response.jsonBody.businesses[i].name;
      venue_names.push(allResults_names);
      const allResults_location = response.jsonBody.businesses[i].location.display_address; 
      const allResults_rating = response.jsonBody.businesses[i].rating; 
      const prettyJson1 = JSON.stringify(allResults_names, null, 4);
      const prettyJson2 = JSON.stringify(allResults_location, null, 4);
      const prettyJson3 = JSON.stringify(allResults_rating, null, 4);
      if (allResults_rating >= 3.5){
        console.log("Name of location: " + prettyJson1);
        console.log("Location: " + prettyJson2);
        console.log("Rating: " + prettyJson3);
      }
    }
    const final_destination = venue_names[Math.floor(Math.random() * venue_names.length)];
    console.log(final_destination);
    //console.log('Did I get here?');
  });
}).catch(e => {
  console.log(e);
});
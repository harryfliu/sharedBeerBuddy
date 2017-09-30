'use strict';

const yelp = require('yelp-fusion');

// Place holders for Yelp Fusion's OAuth 2.0 credentials. Grab them
// from https://www.yelp.com/developers/v3/manage_app
const clientId = 'Sge8Bu-UokjPscJR1Xd9yw';
const clientSecret = 'vI44X2b1JnhCFQEPUfEAmHKL4HUx8BjV2M7crwqtEsaEuTQaIHrhfnGOqU8pZT5z';

const searchRequest = {
  term:'beer',
  location: 'san jose, ca'
};

yelp.accessToken(clientId, clientSecret).then(response => {
  const client = yelp.client(response.jsonBody.access_token);

  client.search(searchRequest).then(response => {
    const firstResult = response.jsonBody.businesses[0];
    const prettyJson = JSON.stringify(firstResult, null, 4);
    console.log(prettyJson);
  });
}).catch(e => {
  console.log(e);
});
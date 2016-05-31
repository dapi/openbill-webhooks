var connect = require('connect');
var http = require('http');
var bodyParser = require('body-parser');

var app = connect();

app.use(bodyParser.json());

// respond to all requests
app.use(function(req, res){
  console.log(req.body);
  res.end('password');
});

//create node.js http server and listen on port
http.createServer(app).listen(3000);

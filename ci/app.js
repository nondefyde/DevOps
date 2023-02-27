const express = require('express')
const fs = require("fs");
const https = require("https");
const http = require("http");

const app = express()

console.log('process.env.CERT_PATH ::: ', process.env.CERT_PATH);
const options = {
	pfx: fs.readFileSync(process.env.CERT_PATH || 'cert/cert.pfx'),
	passphrase: 'Cloud_1@###'
};

const httpPort = 8000
const httpsPort = 4443

http.createServer(app)
	.listen(httpPort, () => {
		console.log(`HTTP Example app listening on port >>>>>> update ${httpPort}  --- env --- ${process.env.NODE_ENV}`);
	});

https.createServer(options, app)
	.listen(httpsPort, () => {
		console.log(`HTTPS Example app listening on port >>>>>> update ${httpsPort}  --- env --- ${process.env.NODE_ENV}`);
	});

app.get('/', function (req, res) {
	res.header('Content-type', 'text/html');
	return res.end('<h1>Hello, Secure World!</h1>');
});

app.get('/v1/ping', (req, res) => {
	res.status(200).send(`Ping Successful ${new Date().toISOString()} --- environment --- ${process.env.NODE_ENV}`);
});

app.get('/', (req, res) => {
	res.status(200).json({
		message: `Hello from ${process.env.NODE_ENV}`,
		port: `Running port - ${process.env.PORT}`,
		headers: req.headers
	});
});
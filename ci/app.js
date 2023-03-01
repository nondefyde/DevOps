const express = require('express')

const port = 8000;
const app = express()

console.log('__dirname ::: ', __dirname);
console.log('__filename ::: ', __filename);

app.listen(port, () => {
	console.log(`HTTP app listening on port >>>> ${port}`);
});

app.get('/v1/ping', (req, res) => {
	res.status(200).send(`Ping Successful ${new Date().toISOString()} --- environment --- ${process.env.NODE_ENV}`);
});

app.get('/', (req, res) => {
	res.status(200).json({
		message: `Hello from ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
		body: req.body,
	});
});

app.get('/:url', (req, res) => {
	res.status(200).json({
		message: `Hello from url ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
		body: req.body,
	});
});
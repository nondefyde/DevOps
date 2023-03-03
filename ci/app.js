const express = require('express')

const port = 8000;
const app = express()

app.listen(port, () => {
	console.log(`HTTP app listening on port >>>> ${port}`);
});

app.get('/ping', (req, res) => {
	res.status(200).send(`Ping Successful from ${process.env.NODE_ENV}`);
});

app.get('/', (req, res) => {
	res.status(200).json({
		message: `Hello from ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
	});
});

app.get('/:url', (req, res) => {
	res.status(200).json({
		message: `Hello from url ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
	});
});
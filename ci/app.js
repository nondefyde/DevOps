const express = require('express')

const port = 8000;
const app = express()

app.listen(port, () => {
	console.log(`HTTP app listening on port >>>> ${port}`);
});

app.get('/', (req, res) => {
	res.status(200).json({
		message: `Ping Successful from ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
	});
});
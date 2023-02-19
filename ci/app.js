const express = require('express')
const app = express()
const port = 8000


app.get('/v1/ping', (req, res) => {
	res.status(200).send(`Ping Successful ${new Date().toISOString()} --- environment --- ${process.env.NODE_ENV}`);
})

app.get('/', (req, res) => {
	res.status(200).json({
		message: `Hello World! Confirm from ${process.env.NODE_ENV}`,
		port: `Running port ${process.env.PORT}`,
		headers: req.headers
	});
})

app.listen(port, () => {
	console.log(`Example app listening on port >>>>>> update ${port}  --- env --- ${process.env.NODE_ENV}`);
})
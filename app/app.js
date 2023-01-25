const express = require('express')
const app = express()
const port = 8000


app.get('/v1/ping', (req, res) => {
	res.status(200).send(`Ping Successful ${new Date().toISOString()}`)
})

app.get('/', (req, res) => {
	res.send('Hello World! I did it again')
})

app.listen(port, () => {
	console.log(`Example app listening on port >>>>>> update ${port}  --- environment --- ${process.env.NODE_ENV}`)
})
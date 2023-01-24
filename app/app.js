const express = require('express')
const app = express()
const port = 8000

app.get('/', (req, res) => {
	res.send('Hello World! I want to trust that this deployed well')
})

app.listen(port, () => {
	console.log(`Example app listening on port >>>>>> ${port}`)
})
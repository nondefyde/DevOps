const express = require('express')
const os = require('os');

const port = 8000;
const app = express()

const interfaces = os.networkInterfaces();
const containerInterface = Object.values(interfaces)
	.flat()
	.find(iface => iface.internal === false && iface.mac === '02:42:ac:11:00:02');
console.log('containerInterface ::: ', containerInterface);
let containerIp;
if(containerInterface) {
	containerIp = containerInterface.address;
}

app.listen(port, () => {
	console.log(`HTTP app listening on port >>>> ${port}`);
});

app.get('/ping', (req, res) => {
	const containerIp = containerInterface.address;
	res.status(200).send(`Ping Successful ${new Date().toISOString()} --- containerIp --- ${containerIp}`);
});

app.get('/', (req, res) => {
	res.status(200).json({
		message: `Hello from ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
		containerIp
	});
});

app.get('/:url', (req, res) => {
	res.status(200).json({
		message: `Hello from url ${process.env.NODE_ENV}`,
		headers: req.headers,
		params: req.params,
		containerIp
	});
});
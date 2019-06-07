const express = require('express')
const bodyParser = require('body-parser')

const { CalculatorPort } = require('../../locations')
const type_check_middleware = require('../middleware/type_check.middleware')

const operations = {
	'+': ({ x, y }) => x + y,
	'-': ({ x, y }) => x - y,
	'*': ({ x, y }) => x * y,
	'/': ({ x, y }) => x / y
}

let app = express()
app.use(bodyParser.json())

let type_check = type_check_middleware(Object.keys(operations))
app.use(type_check)

app.post('/calculator', (req, res) => {
	let { operator, values } = req.body
	let result = operations[operator](values)

	console.log(`${values.x} ${operator} ${values.y} = ${result}`)
	res.json({ result })
})

app.listen( CalculatorPort, () => { console.log(`Calculator service started.\nEndpoint: http://localhost:${CalculatorPort}\n`) })

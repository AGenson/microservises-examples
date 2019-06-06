const express = require('express')
const bodyParser = require('body-parser')

const { CalculatorPort } = require('../locations')

const throwErr = (res, err) => {
	console.log(`Error: ${err.type}`)
	res.status(err.code).json(err)
}
const operations = {
	'+': ({ x, y }) => x + y,
	'-': ({ x, y }) => x - y,
	'*': ({ x, y }) => x * y,
	'/': ({ x, y }) => x / y
}

let app = express()
app.use(bodyParser.json())

app.use((req, res, next) => {
	const operators_arr = Object.keys(operations)
	const code = 422

	let { operator, values } = req.body

	if (typeof operator != 'string')
		throwErr(res, { type: 'MISSING_INPUT_ERROR', code, message: "Missing operator: please use one of the following operators.", data: operators_arr })
	else if (!operators_arr.includes(operator))
		throwErr(res, { type: 'INVALID_INPUT_ERROR', code, message: "Invalid operator: please use one of the following operators.", data: operators_arr })
	else if (typeof values != 'object')
		throwErr(res, { type: 'MISSING_INPUT_ERROR', code, message: "Missing input: please specify the field 'values'." })
	else if (typeof values.x != 'number')
		throwErr(res, { type: 'MISSING_INPUT_ERROR', code, message: "Missing input: please specify the field 'values.x'." })
	else if (typeof values.y != 'number')
		throwErr(res, { type: 'MISSING_INPUT_ERROR', code, message: "Missing input: please specify the field 'values.y'." })
	else if (operator == '/' && values.y == 0)
		throwErr(res, { type: 'ZERO_DIVISION_ERROR', code, message: "Zero Division Error: tried to divide a number by 0." })
	else
		next()
})

app.post('/calculator', (req, res) => {
	let { operator, values } = req.body
	let result = operations[operator](values)

	console.log(`${values.x} ${operator} ${values.y} = ${result}`)
	res.json({ result })
})

app.listen( CalculatorPort, () => { console.log(`Calculator service started.\nEndpoint: http://localhost:${CalculatorPort}\n`) })

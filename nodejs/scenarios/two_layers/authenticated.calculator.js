const express = require('express')
const bodyParser = require('body-parser')
const axios = require('axios')

const { ProxyPort, AuthentificatorPort, CalculatorPort } = require('../../locations')
const authorize = require('../../common/middleware/auth.middleware')(`http://localhost:${AuthentificatorPort}`)

const throwErr = (res, err) => {
	console.log(`Error: ${err.type}`)
	res.status(err.code).json(err)
}

const authorisePaths = [ '/calculator' ]

let app = express()
app.use(bodyParser.json())
authorisePaths.forEach( path => app.post(path, authorize) )

app.post('/calculator', (req, res) => {
    axios({
        method: 'post',
        baseURL: `http://localhost:${CalculatorPort}`,
        url: req.path,
        data: req.body
    }).then( response => { res.json({ ...(response.data), key_info: req.body.auth }) })
    .catch( err => { throwErr(res, err.response.data) })
})

app.post('/*', (req, res) => {
    console.log("Hello")
    axios({
        method: 'post',
        baseURL: `http://localhost:${AuthentificatorPort}`,
        url: req.path,
        data: req.body
    }).then( response => { res.json({ ...(response.data) }) })
    .catch( err => { throwErr(res, err.response.data) })
})

app.listen( ProxyPort, () => { console.log(`Authentificator service started.\nEndpoint: http://localhost:${ProxyPort}\n`) })

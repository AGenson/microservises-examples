const express = require('express')
const bodyParser = require('body-parser')
const axios = require('axios')

const { ProxyPort, AuthentificatorPort, CalculatorPort } = require('../../locations')
const authorize = require('./auth.middleware')(`http://localhost:${AuthentificatorPort}`)

const throwErr = (res, err) => {
	console.log(`Error: ${err.type}`)
	res.status(err.code).json(err)
}

const authorisePaths = [ '/calculator' ]

let app = express()
app.use(bodyParser.json())
authorisePaths.forEach( path => app.use(path, authorize) )

app.post('/calculator', async (req, res) => {
    axios({
        method: 'post',
        baseURL: `http://localhost:${CalculatorPort}`,
        url: req.path,
        data: req.body
    }).then( response => { res.json({ ...(response.data), key_info: req.body.auth }) })
    .catch( err => { throwErr(res, err.response.data) })
})

app.listen( ProxyPort, () => { console.log(`Authentificator service started.\nEndpoint: http://localhost:${ProxyPort}\n`) })

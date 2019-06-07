const express = require('express')
const bodyParser = require('body-parser')

const { CircuitBreakerPort, CalculatorPort } = require('../../locations')
const CircuitBreaker = require('../../common/circuit_breaker')

const circuitBreakerPaths = [
    {
        path: '/calculator',
        redirect: `http://localhost:${CalculatorPort}`
    }
]

let circuitBreaker = new CircuitBreaker(circuitBreakerPaths)
let app = express()
app.use(bodyParser.json())

circuitBreakerPaths.forEach( item => {
    app.post(item.path, (req, res) => {
        circuitBreaker.redirect(req, res)
    })
})

app.listen( CircuitBreakerPort, () => { console.log(`Authentificator service started.\nEndpoint: http://localhost:${CircuitBreakerPort}\n`) })

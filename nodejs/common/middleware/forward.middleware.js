const axios = require('axios')
const throwErr = require('../error')
const CircuitBreaker = require('../circuit_breaker')

let circuitBreaker = new CircuitBreaker()

module.exports = (req, res, next) => {
    if (res.locals.req_path.circuit_breaker)
        circuitBreaker.redirect(req, res, next)
    else
        axios({
            method: 'post',
            baseURL: res.locals.req_path.location,
            url: res.locals.req_path.path,
            data: req.body
        }).then( response => {
            res.locals.data = response.data
            next()
        })
        .catch( err => { throwErr(res, err.response.data) })
}

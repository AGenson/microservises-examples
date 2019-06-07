const axios = require('axios')
const throwErr = require('../error')
const { AuthenticatorPort } = require('../../locations')

module.exports = (req, res, next) => {
    if (res.locals.req_path.authorize)
        axios({
            method: 'post',
            baseURL: `http://localhost:${AuthenticatorPort}`,
            url: '/check_key',
            data: { key: req.body.key }
        }).then( response => {
            res.locals.key_info = response.data
            next()
        }).catch( err => { throwErr(res, err.response.data) })
    else
        next()
}

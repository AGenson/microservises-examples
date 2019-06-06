const axios = require('axios')

const throwErr = (res, err) => {
	console.log(`Error: ${err.type}`)
	res.status(err.code).json(err)
}

module.exports = (path) => (req, res, next) => {
    axios({
        method: 'post',
        baseURL: path,
        url: '/check_key',
        data: { key: req.body.key }
    }).then( response => { req.body.auth = response.data; next() })
    .catch( err => { throwErr(res, err.response.data) })
}

const express = require('express')
const bodyParser = require('body-parser')

const check_path_middleware = require('../../common/middleware/check_path.middleware')
const authorize = require('../../common/middleware/authorize.middleware')
const forward = require('../../common/middleware/forward.middleware')

module.exports = (paths) => {
    let check_path = check_path_middleware(paths)
    let app = express()
    app.use(bodyParser.json())

    app.route('/*')
        .post(check_path)
        .post(authorize)
        .post(forward)
        .post((req, res) => {
            let data = res.locals.data

            if (res.locals.req_path.authorize)
                data.key_info = res.locals.key_info

            res.json(data)
        })

    return app
}

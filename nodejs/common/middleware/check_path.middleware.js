const throwErr = require('../error')

module.exports = (paths) => (req, res, next) => {
    let req_path = paths.find( ({ path }) => req.path == path )

    if (typeof req_path == 'undefined')
        throwErr(res, { type: 'PATH_NOT_FOUND', code: 404, message: "Internal Error: path not found." })
    else {
        res.locals.req_path = req_path
        next()
    }
}

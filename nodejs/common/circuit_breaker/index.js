const axios = require('axios')

const { Config, State } = require('./constants')

const throwErr = (res, err) => {
    console.log(`Error: ${err.type}`)
    res.status(err.code).json(err)
}

class CircuitBreaker {
    constructor(redirectPaths) {
        this.timeout = []
        this.success = []
        this.failure = []
        this.state = State.Closed
        this.redirectPaths = {}

        redirectPaths.forEach( item => {
            this.redirectPaths[item.path] = item.location
        })
    }

    _setState(state) {
        this.state = state
        console.log(`Circuit Breaker: switched to ${this.state} State.`)
    }

    _timeout() { this.timeout.push(Date.now()) }
    _success() { this.success.push(Date.now()) }
    _failure() { this.failure.push(Date.now()) }

    _checkRollingWindow() {
        const checkIfOut = timestamp => (Date.now() - timestamp) < Config.RollingWindow

        this.timeout = this.timeout.filter( checkIfOut )
        this.success = this.success.filter( checkIfOut )
        this.failure = this.failure.filter( checkIfOut )
    }

    _checkPath(path) {
        return Object.keys(this.redirectPaths).includes(path)
    }

    _checkShouldTrip() {
        this._checkRollingWindow()
        let rate = 0

        if ((this.timeout.length + this.success.length + this.failure.length) != 0)
            rate = (this.timeout.length + this.failure.length) / (this.timeout.length + this.success.length + this.failure.length) * 100

        let shouldTrip = rate > Config.TripThreshold
        console.log(`Circuit Breaker: check if should trip: rate=${rate}% & shouldTrip=${shouldTrip}`)

        if (shouldTrip) {
            this._setState(State.Open)
            setTimeout( () => { this._setState(State.HalfOpen) } , Config.ResetTimeout * 1000)
        }
    }

    redirect(req, res) {
        if (this._checkPath(req.path)) {
            if (this.state != State.Open) {
                axios({
                    method: 'post',
                    timeout: Config.CallTimeout * 1000,
                    baseURL: this.redirectPaths[req.path],
                    url: req.path,
                    data: req.body
                }).then( response => {
                    this._success()
                    res.json({ ...(response.data) })

                    if (this.state == State.HalfOpen)
                        this._setState(State.Closed)
                }).catch( err => {
                    if (err.code == 'ECONNABORTED') {
                        this._timeout()
                        throwErr(res, { type: 'TIMEOUT_ERROR', code: 504, message: "Service not responding: please retry later.", data: { path: req.path } })
                    } else {
                        this._failure()
                        throwErr(res, err.response.data)
                    }

                    this._checkShouldTrip()
                })
            } else
                throwErr(res, { type: 'CIRCUIT_BREAKER_FAULT', code: 500, message: "Circuit Breaker: access blocked for a short period of time." })
        } else
            throwErr(res, { type: 'PATH_NOT_FOUNT', code: 404, message: "Circuit Breaker: path not aggregated by circuit breaker instance." })
    }
}

module.exports = CircuitBreaker

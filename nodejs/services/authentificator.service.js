const express = require('express')
const bodyParser = require('body-parser')
const uuidv4 = require('uuid/v4')

const { AuthentificatorPort } = require('../locations')
const { Username, Password, KeyDuration } = require('../credentials')

const throwErr = (res, err) => {
	console.log(`Error: ${err.type}`)
	res.status(err.code).json(err)
}

let db_users = { }
let db_valid_keys = { }

db_users[Username] = Password

let app = express()
app.use(bodyParser.json())

app.post('/get_key', (req, res) => {
    let { username, password } = req.body

    if (typeof username != 'string')
        throwErr(res, { type: 'MISSING_INPUT_ERROR', code: 422, message: "Missing input: please specify the field 'username'." })
    else if (typeof password != 'string')
        throwErr(res, { type: 'MISSING_INPUT_ERROR', code: 422, message: "Missing input: please specify the field 'password'." })
    else {
        console.log(`Received credentials: username=${username} & password=${password}`)

        if (db_users[username] == password) {
            key = uuidv4()
            timestamp = Date.now()
            db_valid_keys[key] = timestamp

            console.log(`Created new key: key=${key} & timestamp=${timestamp}`)
            res.json({ key, valid_for: KeyDuration })
        } else
            throwErr(res, { type: 'INVALID_CREDENTIALS', code: 401, message: "Invalid credentials: please retry again." })
    }
})

app.post('/check_key', (req, res) => {
    const invalid_key_err = { type: 'INVALID_KEY', code: 401, message: "Invalid key: please retry or get a new one." }
    let { key } = req.body

    if (typeof key != 'string')
        throwErr(res, { type: 'MISSING_INPUT_ERROR', code: 422, message: "Missing input: please specify the field 'key'." })
    else {
        if (typeof db_valid_keys[key] != 'number')
            throwErr(res, invalid_key_err)
        else {
            let diff = Date.now() - db_valid_keys[key]

            if (diff > KeyDuration) {
                throwErr(res, invalid_key_err)
                delete db_valid_keys[key]
            }
            else {
                console.log("Valid key: true")
                res.json({ key, valid_for: KeyDuration - diff })
            }
        }
    }
})

app.listen( AuthentificatorPort, () => { console.log(`Authentificator service started.\nEndpoint: http://localhost:${AuthentificatorPort}\n`) })

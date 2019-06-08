# <img src="https://ih1.redbubble.net/image.109336634.1604/flat,550x550,075,f.u1.jpg" width="35" height="35" /> - Microservices example in Node.js

The goal of this project is to set a [Node.js](https://nodejs.org/en/) example of **microservices** using the [Express](https://github.com/expressjs/express) framework.

For that purpose we create a **calculator** service for the following scenarios of microservices architecture:

- A simple calculator service alone
- An authentification system around the calculator
- The circuit breaker pattern over the calculator service
- An authentification system covering the circuit breaker pattern above
- The circuit breaker pattern over the authenticated system and calculator

You can install Node.js [here](https://nodejs.org/en/download/).
Then to set up the packages, just run `npm` or `yarn` in the root folder.

---

##Usage

All request are made by passing data via json body.
You can use either `yarn` or `npm` to run the scripts.

### Simple calculator service alone

Run the following command: `yarn run calc`

Request: `/calculator`
Body:

```json
{
  "values": {
    "x": number,
    "y": number
  },
  "operator": string
}
```

The field operator can have the following values: `['+', '-', '*', '/' ]`
The endpoint will be given in the terminal.

### Authentification system around the calculator

Run the following commands:

- `yarn run calc`
- `yarn run auth`
- `yarn run auth_calc`

Request: `/get_key`
Body:

```json
{
  "username": "client",
  "password": "microservices"
}
```

The authentificator will answer with a key valid for 1 min.

Request: `/calculator`
Body:

```json
{
  "values": {
    "x": number,
    "y": number
  },
  "operator": string,
  "key": string
}
```

The endpoint for both requests should be in the terminal `yarn run auth_calc`.

### Circuit breaker pattern over the calculator service

Run the following files:

- `yarn run calc`
- `yarn run cb_calc`

Same request and body as for the calculator. The circuit breaker is transparent, until triggered to an open state.

The endpoint will be given in the terminal from `yarn run cb_calc`.

### Authentification system covering the circuit breaker pattern

Run the following files:

- `yarn run calc`
- `yarn run auth`
- `yarn run auth_cb_calc`

Same request and body as for the authenticated calculator. The circuit breaker is transparent, until triggered to an open state.

The endpoint will be given in the terminal of `yarn run auth_cb_calc`.

### Circuit breaker pattern over the authenticated system and calculator

Run the following files:

- `yarn run calc`
- `yarn run auth`
- `yarn run cb_auth_calc`

Same request and body as for the authenticated calculator. The circuit breaker is transparent, until triggered to an open state.

The endpoint will be given in the terminal of `yarn run cb_auth_calc`.

# <img src="https://blobscdn.gitbook.com/v0/b/gitbook-28427.appspot.com/o/spaces%2F-LEQ-GvX4NRxA4IFsTUC%2Favatar.png?generation=1552493494027109&alt=media" width="35" height="35" /> - Microservices example in Jolie

The goal of this project is to set a [Jolie](https://www.jolie-lang.org/) example of **microservices**.

For that purpose we create a **calculator** service for the following scenarios of microservices architecture:

- A simple calculator service alone
- An authentification system around the calculator
- The circuit breaker pattern over the calculator service
- An authentification system covering the circuit breaker pattern above
- The circuit breaker pattern over the authenticated system and calculator

You can install Jolie [here](https://www.jolie-lang.org/downloads.html).

---

##Usage

All ports support either `http` or `sodep` protocol.
There is a problem of error forwarding in `http` with doesn't exist in `sodep`

All request are made by passing data via json body.

### Simple calculator service alone

Run the following file: `./services/calculator/calculator.ol`

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

Run the following files:

- `./services/calculator/calculator.ol`
- `./services/authentificator/authentificator.ol`
- `./authenticated/calculator/proxy.ol`

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

The endpoint for both requests should be in the terminal `./authenticated/calculator/proxy.ol`.

### Circuit breaker pattern over the calculator service

Run the following files:

- `./services/calculator/calculator.ol`
- `./circuit_breaker/calculator/circuit_breaker.ol`

Same request and body as for the calculator. The circuit breaker is transparent, until triggered to an open state.

The endpoint will be given in the terminal of `./circuit_breaker/calulator/circuit_breaker.ol`.

### Authentification system covering the circuit breaker pattern

Run the following files:

- `./services/calculator/calculator.ol`
- `./services/authentificator/authentificator.ol`
- `./circuit_breaker/calculator/circuit_breaker.ol`
- `./authenticated/circuit_breaker/proxy.ol`

Same request and body as for the authenticated calculator. The circuit breaker is transparent, until triggered to an open state.

The endpoint will be given in the terminal of `./authenticated/circuit_breaker/proxy.ol`.

### Circuit breaker pattern over the authenticated system and calculator

Run the following files:

- `./services/calculator/calculator.ol`
- `./services/authentificator/authentificator.ol`
- `./authenticated/calculator/proxy.ol`
- `./circuit_breaker/authenticated/circuit_breaker.ol`

Same request and body as for the authenticated calculator. The circuit breaker is transparent, until triggered to an open state.

The endpoint will be given in the terminal of `./circuit_breaker/authenticated/circuit_breaker.ol`.

const proxy = require('./common/proxy')
const { ProxyPort, AuthenticatorPort, CalculatorPort } = require('./locations')

let calculator_path = {
    path: '/calculator',
    authorize: false,
    circuit_breaker: false,
    location: `http://localhost:${CalculatorPort}`
}
let get_key_path = {
    path: '/get_key',
    authorize: false,
    circuit_breaker: false,
    location: `http://localhost:${AuthenticatorPort}`
}

let args = process.argv.slice(2)

args.forEach( arg => {
    let param = arg.split('=')

    if (param[0] == '--auth')
        calculator_path.authorize = true
    else if (param[0] == '--cb' && param.length > 1) {
        if (param[1] == 'calc')
            calculator_path.circuit_breaker = true
        else if (param[1] == 'auth')
            get_key_path.circuit_breaker = true
    }
})

let paths = [ calculator_path ]

if (calculator_path.authorize)
    paths.push(get_key_path)

let app = proxy(paths)

app.listen( ProxyPort, () => { console.log(`Proxy started.\nEndpoint: http://localhost:${ProxyPort}\n`) })

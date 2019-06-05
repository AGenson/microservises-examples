include "console.iol"

include "../circuit_breaker_calculator/circuit_breaker.iol"
include "../authentificator/authentificator.iol"
include "../calculator/calculator.iol"
include "../locations.iol"
include "proxy.iol"

execution{ concurrent }

outputPort Authentificator {
	Location: AuthentificatorLocation
	Protocol: http
	Interfaces: AuthentificatorInterface
}

outputPort CircuitBreakerCalculator {
	Location: CircuitBreakerLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

inputPort AuthenticatedCalculator {
	Location: ProxyLocation
	Protocol: http
	Aggregates:
		CircuitBreakerCalculator with ProxyInterface_Extender,
		Authentificator
}

courier AuthenticatedCalculator {
	[ interface CalculatorInterface( request )( response ) ] {
		check_key@Authentificator( { .key = request.key } )( key_info );

		forward( request )( response );

		with( response ) { .key_info << key_info }
	}
}


init { 
	println@Console("Proxy started.\nEndpoint: " + ProxyLocation + "\n")()
}

main {
	in()
}

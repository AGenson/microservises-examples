include "console.iol"
include "string_utils.iol"

include "../authentificator/authentificator.iol"
include "../calculator/calculator.iol"
include "../locations.iol"
include "proxy.iol"

outputPort Authentificator {
	Location: AuthentificatorLocation
	Protocol: http
	Interfaces: AuthentificatorInterface
}

outputPort Calculator {
	Location: CalculatorLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

inputPort Proxy {
	Location: ProxyLocation
	Protocol: http
	Aggregates:
		Calculator with ProxyInterface_Extender,
		Authentificator
}

courier Proxy {
	[ interface CalculatorInterface( request )( response ) ] {
		check_key@Authentificator( { .key = request.key } )( key_info );

		forward( request )( response );

		with( response ) {
			.key_info << key_info
		}
	}
}


init { 
	println@Console("Proxy started.\nEndpoint: " + ProxyLocation + "\n")()
}

main {
	in()
}

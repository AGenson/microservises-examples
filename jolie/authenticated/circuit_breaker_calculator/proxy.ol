include "console.iol"

include "../../services/authentificator/authentificator.iol"
include "../../circuit_breaker/calculator/surface.iol"
include "../../locations.iol"
include "proxy.iol"

execution{ concurrent }

outputPort Authentificator {
	Location: AuthentificatorLocation
	Protocol: http
	Interfaces: AuthentificatorInterface
}

outputPort AuthentificatorSodep {
	Location: AuthentificatorLocationSodep
	Protocol: sodep
	Interfaces: AuthentificatorInterface
}

outputPort CircuitBreakerCalculator {
	Location: CircuitBreakerLocation
	Protocol: http
	Interfaces: CircuitBreakerCalculatorSurface
}

outputPort CircuitBreakerCalculatorSodep {
	Location: CircuitBreakerLocationSodep
	Protocol: sodep
	Interfaces: CircuitBreakerCalculatorSurface
}

inputPort AuthenticatedCalculator {
	Location: ProxyLocation
	Protocol: http
	Aggregates:
		CircuitBreakerCalculator with ProxyInterface_Extender,
		Authentificator
}

inputPort AuthenticatedCalculatorSodep {
	Location: ProxyLocationSodep
	Protocol: sodep
	Aggregates:
		CircuitBreakerCalculatorSodep with ProxyInterfaceSodep_Extender,
		AuthentificatorSodep
}

courier AuthenticatedCalculator {
	[ interface CircuitBreakerCalculatorSurface( request )( response ) ] {
		install( TypeMismatch => println@Console("Error: ServiceError")() );
		check_key@Authentificator( { .key = request.key } )( key_info );
		forward( request )( response );
		with( response ) { .key_info << key_info }
	}
}

courier AuthenticatedCalculatorSodep {
	[ interface CircuitBreakerCalculatorSurface( request )( response ) ] {
		install(
			InvalidKey => println@Console("Error: InvalidKey")(),
			CircuitBreakerFault => println@Console("Error: CircuitBreakerFault")(),
			ZeroDivisionError => println@Console("Error: ZeroDivisionError")()
		);
		check_key@AuthentificatorSodep( { .key = request.key } )( key_info );
		forward( request )( response );
		with( response ) { .key_info << key_info }
	}
}


init {
	println@Console("Proxy started.\nEndpoints: \n\thttp:  " + ProxyLocation + "\n\tsodep: " + ProxyLocationSodep + "\n")()
}

main {
	in()
}

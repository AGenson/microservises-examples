include "console.iol"

include "../../services/authentificator/authentificator.iol"
include "../../services/calculator/calculator.iol"
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

outputPort Calculator {
	Location: CalculatorLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

outputPort CalculatorSodep {
	Location: CalculatorLocationSodep
	Protocol: sodep
	Interfaces: CalculatorInterface
}

inputPort AuthenticatedCalculator {
	Location: ProxyLocation
	Protocol: http
	Aggregates:
		Calculator with ProxyInterface_Extender,
		Authentificator
}

inputPort AuthenticatedCalculatorSodep {
	Location: ProxyLocationSodep
	Protocol: sodep
	Aggregates:
		CalculatorSodep with ProxyInterfaceSodep_Extender,
		AuthentificatorSodep
}

courier AuthenticatedCalculator {
	[ interface CalculatorInterface( request )( response ) ] {
		install( TypeMismatch => println@Console("Error: ServiceError")() );
		check_key@Authentificator( { .key = request.key } )( key_info );
		forward( request )( response );
		with( response ) { .key_info << key_info }
	}
}

courier AuthenticatedCalculatorSodep {
	[ interface CalculatorInterface( request )( response ) ] {
		install(
			InvalidKey => println@Console("Error: InvalidKey")(),
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

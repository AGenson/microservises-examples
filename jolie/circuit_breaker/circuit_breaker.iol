interface CircuitBreakerInterface {
	OneWay:
		callTimeout( void ),
		resetTimeout( void )
}

interface extender CircuitBreakerInterface_Extender {
	RequestResponse:
		*( request )( response ) throws CircuitBreakerFault( string )
}
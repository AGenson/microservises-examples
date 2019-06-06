constants {
	State_Closed = "Closed",
	State_HalfOpen = "Half Open",
	State_Open = "Open"
}

constants {
	CallTimeout = 20, // seconds
	ResetTimeout = 30 // seconds
}

interface CircuitBreakerInterface {
	OneWay:
		callTimeout( void ),
		resetTimeout( void )
}

interface extender CircuitBreakerInterface_Extender {
	RequestResponse:
		*( void )( void ) throws CircuitBreakerFault( string ) TypeMismatch( undefined )
}

interface extender CircuitBreakerSodepInterface_Extender {
	RequestResponse:
		*( void )( void ) throws CircuitBreakerFault( string ) ZeroDivisionError( string )
}

constants {
	State_Closed = "Closed",
	State_HalfOpen = "Half Open",
	State_Open = "Open"
}

constants {
	CallTimeout = 20,
	ResetTimeout = 30
}

interface CircuitBreakerInterface {
	OneWay:
		callTimeout( void ),
		resetTimeout( void )
}

interface extender CircuitBreakerInterface_Extender {
	RequestResponse:
		*( request )( response ) throws CircuitBreakerFault( string )
}

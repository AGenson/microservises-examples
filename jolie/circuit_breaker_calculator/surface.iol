type RequestType: void {
	.x: double
	.y: double
}

type ResponseType: void {
	.result: double
}

interface CircuitBreakerCalculatorSurface {
	RequestResponse:
		div( RequestType )( ResponseType ) throws CircuitBreakerFault( string ) ZeroDivisionError( string ),
		sub( RequestType )( ResponseType ) throws CircuitBreakerFault( string ),
		mul( RequestType )( ResponseType ) throws CircuitBreakerFault( string ),
		sum( RequestType )( ResponseType ) throws CircuitBreakerFault( string ),
}

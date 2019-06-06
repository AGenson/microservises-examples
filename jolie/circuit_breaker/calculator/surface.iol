type OperationsType: void {
	.x: double
	.y: double
}

type RequestType: void {
	.values: OperationsType
	.operator: string
}

type ResponseType: void {
	.result: double
}

interface CircuitBreakerCalculatorSurface {
	RequestResponse:
		calculator( RequestType )( ResponseType ) throws CircuitBreakerFault( string ) ZeroDivisionError( string )
}

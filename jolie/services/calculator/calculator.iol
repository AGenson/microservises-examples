type RequestType: void {
	.x: double
	.y: double
}

type ResponseType: void {
	.result: double
}

interface CalculatorInterface {
	RequestResponse:
		sum( RequestType )( ResponseType ),
		sub( RequestType )( ResponseType ),
		mul( RequestType )( ResponseType ),
		div( RequestType )( ResponseType ) throws ZeroDivisionError( string )
}

type OperationsType: void {
	.x: double
	.y: double
}

type ResponseType: void {
	.result: double
}

interface OperationsInterface {
	RequestResponse:
		sum( OperationsType )( ResponseType ),
		sub( OperationsType )( ResponseType ),
		mul( OperationsType )( ResponseType ),
		div( OperationsType )( ResponseType )
}

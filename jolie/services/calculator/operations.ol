include "console.iol"

include "../../locations.iol"
include "operations.iol"

execution{ concurrent }

inputPort Operations {
	Location: "local"
	Interfaces: OperationsInterface
}

define logOperation {
	println@Console(request.x + " " + _op + " " + request.y + " = " + response.result)()
}

main {
	[ sum( request )( response ) {
		response.result = request.x + request.y;
		_op = "+"; logOperation
	}]

	[ sub( request )( response ) {
		response.result = request.x - request.y;
		_op = "-"; logOperation
	}]

	[ mul( request )( response ) {
		response.result = request.x * request.y;
		_op = "*"; logOperation
	}]

	[ div( request )( response ) {
		response.result = request.x / request.y;
		_op = "/"; logOperation
	}]
}

include "console.iol"

include "../locations.iol"
include "calculator.iol"

execution{ concurrent }

inputPort Calculator {
	Location: CalculatorLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

init {
	println@Console("Calculator service started.\nEndpoint: " + CalculatorLocation + "\n")()
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

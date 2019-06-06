include "console.iol"

include "../../locations.iol"
include "operations.iol"
include "calculator.iol"

execution{ concurrent }

outputPort Operations { Interfaces: OperationsInterface }
embedded { Jolie: "operations.ol" in Operations }

inputPort Calculator {
	Location: CalculatorLocation
	Protocol: http  { .statusCode -> statusCode }
	Interfaces: CalculatorInterface
}

init {
	println@Console("Calculator service started.\nEndpoint: " + CalculatorLocation + "\n")()
}

main {
	[ calculator( request )( response ) {
		install( ZeroDivisionError => println@Console("Error: ZERO_DIVISION_ERROR")() );
		with (values) { .x = request.values.x; .y = request.values.y };

		if (request.operator == "+") sum@Operations( values )( response )
		else if (request.operator == "-") sub@Operations( values )( response )
		else if (request.operator == "*") mul@Operations( values )( response )
		else {
			if ( values.y == 0 ) {
				statusCode = 422;
				throw( ZeroDivisionError, "Tried to do a division by zero." )
			};

			div@Operations( values )( response )
		}
	}]
}

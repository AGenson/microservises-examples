include "console.iol"

include "../locations.iol"
include "calculator.iol"

outputPort TestCalculator {
	Location: CalculatorLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

main {
	with( request ) {
		.x = 5;
		.y = 7
	};

	println@Console("Calculator test with x=" + request.x + " & y=" + request.y)();

	sum@TestCalculator( request )( response );
	println@Console("x + y = " + response.result)();

	sub@TestCalculator( request )( response );
	println@Console("x - y = " + response.result)();

	mul@TestCalculator( request )( response );
	println@Console("x * y = " + response.result)();

	div@TestCalculator( request )( response );
	println@Console("x / y = " + response.result)();

	// Will throw an error as it attemps to do a division by zero
	request.y = 0;
	div@TestCalculator( request )( response );
}

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

	sum@TestCalculator( request )( response );
	println@Console("x + y =" + response.result)();

	sub@TestCalculator( request )( response );
	println@Console("x - y =" + response.result)();

	mul@TestCalculator( request )( response );
	println@Console("x * y =" + response.result)();

	div@TestCalculator( request )( response );
	println@Console("x / y =" + response.result)()
}
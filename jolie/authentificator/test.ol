include "console.iol"

include "../locations.iol"
include "authentificator.iol"

outputPort AuthentificatorTest {
	Location: AuthentificatorLocation
	Protocol: http
	Interfaces: AuthentificatorInterface
}

main {
	// Try raising an error with wrong credentials
	/*with( credentials ) {
		.username = "client";
		.password = "password"
	};

	println@Console("Retreiving key: username=" + credentials.username + " & password=" + credentials.password)();
	getKey@AuthentificatorTest( credentials )( response );
	println@Console("Received new key: " + response.key + " (valid for " + response.valid_for + "ms)")();*/

	// Now with working credentials
	with( credentials ) {
		.username = "client";
		.password = "microservices"
	};

	println@Console("Retreiving key: username=" + credentials.username + " & password=" + credentials.password)();
	getKey@AuthentificatorTest( credentials )( response );
	println@Console("Received new key: " + response.key + " (valid for " + response.valid_for + "ms)")();

	// Will raise an error if the validation time for the key is expired (must have a key validation time short for testing)
	for ( i = 0, i < 10, i++ ) {
		println@Console("\nChecking key: " + response.key)();
		checkKey@AuthentificatorTest( { .key = response.key } )( response );
		println@Console("Key still valid for " + response.valid_for + "ms")()
	}
}

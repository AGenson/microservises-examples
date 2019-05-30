include "console.iol"

include "../locations.iol"
include "authentificator.iol"

outputPort AuthentificatorTest {
	Location: AuthentificatorLocation
	Protocol: http
	Interfaces: AuthentificatorInterface
}

main {
	with( credentials ) {
		.username = "client";
		.password = "microservices"
	};

	println@Console("Retreiving key: username=" + credentials.username + " & password=" + credentials.password)();
	getKey@AuthentificatorTest( credentials )( response );
	println@Console("Received new key: " + response.key + " (valid for " + response.valid_for + "ms)")();

	for ( i = 0, i < 10, i++ ) {
		println@Console("\nChecking key: " + response.key)();
		checkKey@AuthentificatorTest( { .key = response.key } )( response );
		println@Console("Key still valid for " + response.valid_for + "ms")()
	}
}

include "console.iol"
include "time.iol"

include "../locations.iol"
include "../credentials.iol"
include "authentificator.iol"

execution{ concurrent }

inputPort Authentificator {
	Location: AuthentificatorLocation
	Protocol: http
	Interfaces: AuthentificatorInterface
}

init {
	global.credentials.( Username ) = Password;

	println@Console("Authentificator service started.\nEndpoint: " + AuthentificatorLocation)()
}

define throwCredentialsError {
	throw( InvalidCredentials, "Invalid credentials, please retry again." );
	println@Console("Error: INVALID_CREDENTIALS")()
}

define throwKeyError {
	throw( InvalidKey, "Invalid key, please retry or get a new one." );
	println@Console("Error: INVALID_KEY")()
}

main {
	[getKey( request )( response ) {
		println@Console("\nReceived credentials: username=" + request.username + " & password=" + request.password)();

		if ( global.credentials.( request.username ) == request.password ) {
			response.key = new;
			response.valid_for = KeyDuration;
			getCurrentTimeMillis@Time()( timestamp );
			global.valid_keys.( response.key ) = timestamp;
			println@Console("Created new key: key=" + response.key + " & timestamp=" + timestamp)()
		}
		else {
			throwCredentialsError
		}
	}]

	[checkKey( request )( response ) {
		if ( is_defined( global.valid_keys.( request.key ) ) ) {
			println@Console("\nReceived key: " + request.key)();
			getCurrentTimeMillis@Time()( timestamp );
			diff = timestamp - global.valid_keys.( request.key );

			if ( diff > KeyDuration ) {
				undef( global.valid_keys.( request.key ) );
				throwKeyError
			};

			with( response ) {
				.key = request.key;
				.valid_for = KeyDuration - diff
			};

			println@Console("Key still valid")()
		}
		else {
			throwKeyError
		}
	}]
}

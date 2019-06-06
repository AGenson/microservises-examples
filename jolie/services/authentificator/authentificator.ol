include "console.iol"
include "time.iol"

include "../../locations.iol"
include "../../credentials.iol"
include "authentificator.iol"

execution{ concurrent }

inputPort Authentificator {
	Location: AuthentificatorLocation
	Protocol: http { .statusCode -> statusCode }
	Interfaces: AuthentificatorInterface
}

inputPort AuthentificatorSodep {
	Location: AuthentificatorLocationSodep
	Protocol: sodep
	Interfaces: AuthentificatorInterface
}

init {
	global.credentials.( Username ) = Password;

	println@Console("Authentificator service started.\nEndpoints: \n\thttp:  " + AuthentificatorLocation + "\n\tsodep: " + AuthentificatorLocationSodep + "\n")()
}

main {
	[ get_key( request )( response ) {
		statusCode = 200;
		install( InvalidCredentials => println@Console("Error: INVALID_CREDENTIALS")() );
		println@Console("Received credentials: username=" + request.username + " & password=" + request.password)();

		if ( global.credentials.( request.username ) == request.password ) {
			with( response ) {
				.key = new;
				.valid_for = KeyDuration
			};
			getCurrentTimeMillis@Time()( timestamp );
			global.valid_keys.( response.key ) = timestamp;
			println@Console("Created new key: key=" + response.key + " & timestamp=" + timestamp)()
		}
		else {
			statusCode = 401;
			throw( InvalidCredentials, "Invalid credentials, please retry again." )
		}
	}]

	[ check_key( request )( response ) {
		statusCode = 200;
		install( InvalidKey => println@Console("Error: INVALID_KEY")() );

		if ( is_defined( global.valid_keys.( request.key ) ) ) {
			println@Console("Received key: " + request.key)();
			getCurrentTimeMillis@Time()( timestamp );
			diff = timestamp - global.valid_keys.( request.key );

			if ( diff > KeyDuration ) {
				statusCode = 401;
				undef( global.valid_keys.( request.key ) );
				throw( InvalidKey, "Invalid key, please retry or get a new one." )
			};

			with( response ) {
				.key = request.key;
				.valid_for = KeyDuration - diff
			};
			println@Console("Valid key: true")()
		}
		else {
			statusCode = 401;
			throw( InvalidKey, "Invalid key, please retry or get a new one." )
		}
	}]
}

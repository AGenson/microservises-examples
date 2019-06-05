include "console.iol"
include "time.iol"

include "circuit_breaker.iol"
include "../../locations.iol"
include "../../services/circuit_breaker/stats.iol"
include "../../authenticated/calculator/surface.iol"

execution{ concurrent }

outputPort Stats { Interfaces: StatsInterface }
embedded { Jolie: "../../services/circuit_breaker/stats.ol" in Stats }

outputPort AuthenticatedCalculator {
	Location: ProxyLocation
	Protocol: http
	Interfaces: AuthenticatedCalculatorSurface
}

inputPort CircuitBreaker {
	Location: CircuitBreakerLocation
	Protocol: http
	Aggregates: AuthenticatedCalculator with CircuitBreakerInterface_Extender
}

inputPort CircuitBreakerInternal {
	Location: "local"
	Interfaces: CircuitBreakerInterface
}

define getState { synchronized( state ){ state = global.state } }
define setState { synchronized( state ){ global.state = state } }

define trip {
	state = State_Open; setState;
	println@Console("Circuit Breaker: switched to Open State.")();
	scheduleTimeout@Time( int(ResetTimeout*1000) { .operation = "resetTimeout" } )()
}

define checkErrorRate {
	getState;

	if ( state == State_Closed ) {
		checkShouldTrip@Stats()( shouldTrip );
		if ( shouldTrip ) trip
	} else if ( global.state == State_HalfOpen ) trip
}

courier CircuitBreaker {
	[ interface AuthenticatedCalculatorSurface( request )( response ) ] {
		install( CircuitBreakerFault => println@Console("Error: CIRCUIT_BREAKER_FAULT")() );
		getState;

		if (state == State_Open) throw( CircuitBreakerFault, "Server not available." )
		else {
			scheduleTimeout@Time( int(CallTimeout*1000) { .operation = "callTimeout" } )( timeoutID );
			install( default => println@Console("Error: SERVICE_ERROR")(); cancelTimeout@Time( timeoutID )(); failure@Stats(); checkErrorRate );

			forward( request )( response );
			
			cancelTimeout@Time( timeoutID )();
			success@Stats();

			if (state == State_HalfOpen) {
				state = State_Closed; setState;
				println@Console("Circuit Breaker: switched to Close State.")()
			}
		}
	}
}

init {
	state = State_Closed; setState;

	println@Console("Circuit Breaker: service started.\nEndpoint: " + CircuitBreakerLocation + "\n")()
}

main {
	[ callTimeout() ] {
		timeout@Stats();
		checkErrorRate
	}

	[ resetTimeout() ] {
		reset@Stats();
		state = State_HalfOpen; setState;
		println@Console("Circuit Breaker: switched to Half-Open State.")()
	}
}

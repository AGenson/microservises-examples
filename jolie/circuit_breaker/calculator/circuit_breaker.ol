include "console.iol"
include "time.iol"

include "../../locations.iol"
include "circuit_breaker.iol"
include "../../services/circuit_breaker/stats.iol"
include "../../services/calculator/calculator.iol"

execution{ concurrent }

outputPort Stats { Interfaces: StatsInterface }
embedded { Jolie: "../../services/circuit_breaker/stats.ol" in Stats }

outputPort Calculator {
	Location: CalculatorLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

outputPort CalculatorSodep {
	Location: CalculatorLocationSodep
	Protocol: sodep
	Interfaces: CalculatorInterface
}

inputPort CircuitBreaker {
	Location: CircuitBreakerLocation
	Protocol: http
	Aggregates: Calculator with CircuitBreakerInterface_Extender
}

inputPort CircuitBreakerSodep {
	Location: CircuitBreakerLocationSodep
	Protocol: sodep
	Aggregates: CalculatorSodep with CircuitBreakerSodepInterface_Extender
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

define handleError {
	println@Console("Error: ServiceError")();
	cancelTimeout@Time( timeoutID )();
	failure@Stats();
	checkErrorRate
}

define handleSuccess {
	cancelTimeout@Time( timeoutID )();
	success@Stats();

	if (state == State_HalfOpen) {
		state = State_Closed; setState;
		println@Console("Circuit Breaker: switched to Close State.")()
	}
}

courier CircuitBreaker {
	[ interface CalculatorInterface( request )( response ) ] {
		install( CircuitBreakerFault => println@Console("Error: CircuitBreakerFault")() );
		getState;

		if (state == State_Open) throw( CircuitBreakerFault, "Server not available." )
		else {
			scheduleTimeout@Time( int(CallTimeout*1000) { .operation = "callTimeout" } )( timeoutID );
			install( TypeMismatch => handleError );

			forward( request )( response );
			handleSuccess
		}
	}
}

courier CircuitBreakerSodep {
	[ interface CalculatorInterface( request )( response ) ] {
		install( CircuitBreakerFault => println@Console("Error: CircuitBreakerFault")() );
		getState;

		if (state == State_Open) throw( CircuitBreakerFault, "Server not available." )
		else {
			scheduleTimeout@Time( int(CallTimeout*1000) { .operation = "callTimeout" } )( timeoutID );
			install( default => handleError );

			forward( request )( response );
			handleSuccess
		}
	}
}

init {
	state = State_Closed; setState;

	println@Console("Circuit Breaker: service started.\nEndpoints: \n\thttp:  " + CircuitBreakerLocation + "\n\tsodep: " + CircuitBreakerLocationSodep + "\n")()
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

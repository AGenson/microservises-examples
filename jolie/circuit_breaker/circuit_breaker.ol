include "console.iol"
include "time.iol"

include "stats.iol"
include "../locations.iol"
include "circuit_breaker.iol"
include "../calculator/calculator.iol"

execution{ concurrent }

outputPort Stats { Interfaces: StatsInterface }
embedded { Jolie: "stats.ol" in Stats }

outputPort Calculator {
	Location: CalculatorLocation
	Protocol: http
	Interfaces: CalculatorInterface
}

inputPort CircuitBreaker {
	Location: CircuitBreakerLocation
	Protocol: http
	Aggregates: Calculator with CircuitBreakerInterface_Extender
}

inputPort CircuitBreakerInternal {
	Location: "local"
	Interfaces: CircuitBreakerInterface
}

define getState { synchronized( state ){ state = global.state } }
define setState { synchronized( state ){ global.state = state } }

define trip {
	state = State_Open; setState;
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
	[ interface CalculatorInterface( request )( response ) ] {
		getState;

		if (state == State_Closed) {
			scheduleTimeout@Time( int(CallTimeout*1000) { .operation = "callTimeout" } )( timeoutID );
			handleFault;
			forward( request )( response );
			procedureAfterForward
		}
		else if (state == State_Open) throwFault
		else {
			checkCanPass@Stats()( canPass );

			if ( canPass ) {
				scheduleTimeout@Time( int(CallTimeout*1000) { .operation = "callTimeout" } )( timeoutID );
				handleFault;
				forward( request )( response );
				procedureAfterForward
			}
		}
	}
}

init {
	state = State_Closed; setState;

	println@Console("Circuit Breaker service started.\nEndpoint: " + CircuitBreakerLocation + "\n")()
}

main {
	[ callTimeout() ] {
		timeout@Stats();
		checkErrorRate
	}

	[ resetTimeout() ] {
		synchronized( state ){
			if ( global.state == State_Open ) {
				reset@Stats();
				global.state = State_HalfOpen
			}
		}
	}
}

include "console.iol"

include "constants.iol"
include "stats.iol"

execution{ concurrent }

inputPort Stats {
	Location: "local"
	Protocol: sodep
	Interfaces: StatsInterface
}

init {
	timeout -> global.stats.timeout;
	success -> global.stats.success;
	failure -> global.stats.failure
}

define checkRate { // Need to verify if it actually is the same code for canPass and shouldTrip (not sure)
	rate = 0;

	if ( timeout + success + failure != 0 )
		rate = ( timeout + failure ) / ( timeout + success + failure ) * 100;

	response = ( rate < TripThreshold );
}

main {
	[ checkShouldTrip()( response ) {
		synchronized( stats ){
			checkRate;
			println@Console("Check if should trip: rate=" + rate + "% & shouldTrip=" + response)()
		}
	}]

	[ checkCanPass()( response ) {
		synchronized( stats ){
			checkRate;
			println@Console("Check if can pass: rate=" + rate + "% & canPass=" + response)()
		}
	}]

	[ timeout() ] {
		synchronized( stats ){
			timeout++;
			println@Console("Timeout called")
		}
	}

	[ success() ] {
		synchronized( stats ){
			success++;
			println@Console("Success called")
		}
	}

	[ failure() ] {
		synchronized( stats ){
			failure++;
			println@Console("Failure called")
		}
	}

	[ reset() {
		synchronized( stats ){
			timeout = success = failure = 0;
			println@Console("Reset called")()
		}
	}]
}

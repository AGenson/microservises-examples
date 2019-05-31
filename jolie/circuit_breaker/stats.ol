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
	failure -> global.stats.failure;
}

define addNewTimestamp {
	getCurrentTimeMillis@Time()( timestamp );
	array[#array] = timestamp;
}

define rollingWindowCheck {
	getCurrentTimeMillis@Time()( timestamp );

	foreach ( item : array ) {
		if ( ( timestamp - item ) < ( RollingWindow * 1000 ) )
			newArray[#newArray] = item;
	}

	undef( array )
	array << newArray
}

define rollingWindowCheckForAll {
	array -> timeout;
	rollingWindowCheck;
	array -> success;
	rollingWindowCheck;
	array -> failure;
	rollingWindowCheck;
}

define checkRate { // Need to verify if it actually is the same code for canPass and shouldTrip (not sure)
	rollingWindowCheckForAll;
	rate = 0;

	if ( #timeout + #success + #failure != 0 )
		rate = ( #timeout + #failure ) / ( #timeout + #success + #failure ) * 100;

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
			array -> timeout;
			addNewTimestamp;
			println@Console("Timeout called")
		}
	}

	[ success() ] {
		synchronized( stats ){
			array -> timeout;
			addNewTimestamp;
			println@Console("Success called")
		}
	}

	[ failure() ] {
		synchronized( stats ){
			array -> timeout;
			addNewTimestamp;
			println@Console("Failure called")
		}
	}

	[ reset() {
		synchronized( stats ){
			undef( timeout );
			undef( success );
			undef( failure );
			println@Console("Reset called")()
		}
	}]
}

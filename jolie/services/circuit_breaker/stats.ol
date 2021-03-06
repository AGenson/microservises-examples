include "console.iol"
include "time.iol"

include "stats.iol"

execution{ concurrent }

inputPort Stats {
	Location: "local"
	Interfaces: StatsInterface
}

init {
	timeout -> global.stats.(TimeoutName);
	success -> global.stats.(SuccessName);
	failure -> global.stats.(FailureName)
}

define addNewTimestamp {
	getCurrentTimeMillis@Time()( timestamp );
	global.stats.(name)[#global.stats.(name)] = timestamp
}

define rollingWindowCheck {
	getCurrentTimeMillis@Time()( timestamp );

	for (i = 0, i < #global.stats.(name), i = i) {
		if ( ( timestamp - global.stats.(name)[i] ) > ( RollingWindow * 1000 ) )
			undef( global.stats.(name)[i] )
		else
			i = #global.stats.(name)
	}
}

define undefArray {
	for (i = 0, i < #global.stats.(name), i = i)
		undef( global.stats.(name)[i] )
}

main {
	[ checkShouldTrip()( response ) {
		synchronized( stats ) {
			rate = 0;

			name = TimeoutName; rollingWindowCheck;
			name = SuccessName; rollingWindowCheck;
			name = FailureName; rollingWindowCheck;

			if ( #timeout + #success + #failure != 0 )
				rate = int( double( #timeout + #failure ) / ( #timeout + #success + #failure ) * 100 );

			response = ( rate > TripThreshold );
			println@Console("Stats: check if should trip: rate=" + rate + "% & shouldTrip=" + response)()
		}
	}]

	[ timeout() ] {
		synchronized( stats ) {
			name = TimeoutName; addNewTimestamp;
			println@Console("Stats: timeout called")()
		}
	}

	[ success() ] {
		synchronized( stats ) {
			name = SuccessName; addNewTimestamp;
			println@Console("Stats: success called")()
		}
	}

	[ failure() ] {
		synchronized( stats ) {
			name = FailureName; addNewTimestamp;
			println@Console("Stats: failure called")()
		}
	}

	[ reset() ] {
		synchronized( stats ) {
			name = TimeoutName; undefArray;
			name = SuccessName; undefArray;
			name = FailureName; undefArray;
			println@Console("Stats: reset called")()
		}
	}
}

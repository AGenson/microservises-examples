constants {
	TripThreshold = 5,
	RollingWindow = 60 // Need to implement it in some way, it's not used
}

interface StatsInterface {
	OneWay:
		success( void ),
		failure( void ),
		timeout( void ),
		reset( void )

	RequestResponse:
		checkShouldTrip( void )( bool ),
		checkCanPass( void )( bool )

}

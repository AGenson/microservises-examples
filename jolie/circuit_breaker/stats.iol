constants {
	TripThreshold = 5, // percentage
	RollingWindow = 60 // seconds
}

constants {
	TimeoutName = "timeout",
	SuccessName = "success",
	FailureName = "failure"
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

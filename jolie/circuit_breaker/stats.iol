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

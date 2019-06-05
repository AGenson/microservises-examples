type CredentialsType: void {
	.password: string
	.username: string
}

type KeyInfoType: void {
	.key: string
	.valid_for: long
}

type KeyType: void {
	.key: string
}

type AuthenticatedCalculator_RequestType: void {
	.x: double
	.y: double
	.key: string
}

type AuthenticatedCalculator_ResponseType: void {
	.result: double
	.key_info: KeyInfoType
}

interface AuthenticatedCalculatorSurface {
	RequestResponse:
		div( AuthenticatedCalculator_RequestType )( AuthenticatedCalculator_ResponseType ) throws CircuitBreakerFault( string ) InvalidKey( string ) ZeroDivisionError( string ),
		sub( AuthenticatedCalculator_RequestType )( AuthenticatedCalculator_ResponseType ) throws CircuitBreakerFault( string ) InvalidKey( string ),
		mul( AuthenticatedCalculator_RequestType )( AuthenticatedCalculator_ResponseType ) throws CircuitBreakerFault( string ) InvalidKey( string ),
		sum( AuthenticatedCalculator_RequestType )( AuthenticatedCalculator_ResponseType ) throws CircuitBreakerFault( string ) InvalidKey( string ),
		get_key( CredentialsType )( KeyInfoType ) throws CircuitBreakerFault( string ) InvalidCredentials( string ),
		check_key( KeyType )( KeyInfoType ) throws CircuitBreakerFault( string ) InvalidKey( string )
}

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

type OperationsType: void {
	.x: double
	.y: double
}

type AuthenticatedCalculator_RequestType: void {
	.values: OperationsType
	.operator: string
	.key: string
}

type AuthenticatedCalculator_ResponseType: void {
	.result: double
	.key_info: KeyInfoType
}

interface AuthenticatedCalculatorSurface {
	RequestResponse:
		calculator( AuthenticatedCalculator_RequestType )( AuthenticatedCalculator_ResponseType ) throws InvalidKey( string ) ZeroDivisionError( string ) TypeMismatch( undefined ),
		get_key( CredentialsType )( KeyInfoType ) throws InvalidCredentials( string ),
		check_key( KeyType )( KeyInfoType ) throws InvalidKey( string )
}

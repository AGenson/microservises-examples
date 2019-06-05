type CredentialsType: void {
	.username: string
	.password: string
}

type KeyType: void {
	.key: string
}

type KeyInfoType: void {
	.key: string
	.valid_for: long
}

interface AuthentificatorInterface {
	RequestResponse:
		get_key( CredentialsType )( KeyInfoType ) throws InvalidCredentials( string ),
		check_key( KeyType )( KeyInfoType ) throws InvalidKey( string )
}

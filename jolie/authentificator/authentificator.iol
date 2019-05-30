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
		getKey( CredentialsType )( KeyInfoType ) throws CredentialsError( string ),
		checkKey( KeyType )( KeyInfoType ) throws InvalidKey( string )
}

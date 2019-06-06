type KeyType: void {
	.key: string
}

type KeyInfoType: void {
	.key: string
	.valid_for: long
}

type AuthResponseType: void {
	.key_info: KeyInfoType
}

interface extender ProxyInterface_Extender {
	RequestResponse: *( KeyType )( AuthResponseType ) throws TypeMismatch( string )
}

interface extender ProxyInterfaceSodep_Extender {
	RequestResponse: *( KeyType )( AuthResponseType ) throws InvalidKey( string ) ZeroDivisionError( string )
}

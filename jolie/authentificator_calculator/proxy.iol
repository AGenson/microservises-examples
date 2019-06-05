// include type KeyType from "authentificator.iol

type KeyType: void {
	.key: string
}

type AuthResponseType: void {
	.key_info: void {
		.key: string
		.valid_for: long
	}
}

interface extender ProxyInterface_Extender {
	RequestResponse: *( KeyType )( AuthResponseType ) throws InvalidKey( string )
}

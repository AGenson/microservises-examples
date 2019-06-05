// include types KeyType, KeyInfoType from "authentificator.iol"

type AuthResponseType: void {
	.key_info: KeyInfoType
}

interface extender ProxyInterface_Extender {
	RequestResponse: *( KeyType )( AuthResponseType ) throws InvalidKey( string )
}

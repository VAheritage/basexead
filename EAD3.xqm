module namespace ead3 = 'http://localhost/ead3'; 

declare function ead3:EAD2002toEAD3( $doc as node() ) as node()  {
	xslt:transform( $doc, 'static/xslt/EAD2002ToEAD3schema_undeprecated.xsl')
};

declare function ead3:EAD3toHTML( $doc as node() ) as node() {
	xslt:transform( $doc, 'static/xslt/EAD3toHTML.xsl')
};


declare function ead3:EAD2002toHTML( $doc as node() ) as node() {
	ead3:EAD2002toEAD3( $doc ) => xslt:transform( 'static/xslt/EAD3-cToc0n.xsl')=> ead3:EAD3toHTML()
};


declare
	%rest:path( '/ead3')
	%rest:query-param( "docId", "{$query}", "")
	%rest:GET
function ead3:convert( $query as xs:string ) { 
    let $params := map:merge( for $p in tokenize( concat( 'docId=', $query), ';' ) 
		return apply( map:entry#2, array{ tokenize($p, '=') }) )
		return ead3:EAD2002toEAD3( doc( $params( 'docId' ) ))
	
};

declare
  %rest:path( '/ead3view')
  %rest:query-param( "docId", "{$query}", "")
  %rest:GET
  %output:method('html')
  %output:version( '5.0')
function ead3:view( $query as xs:string) {
    let $params := map:merge( for $p in tokenize( concat( 'docId=', $query), ';' ) 
		return apply( map:entry#2, array{ tokenize($p, '=') }) )
		return ead3:EAD2002toHTML( doc( $params( 'docId' ) ) )
	
};
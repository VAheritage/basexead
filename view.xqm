module namespace view = 'http://localhost/view';

import module namespace ead3 = 'http://localhost/ead3' at "EAD3.xqm" ;

(: NOTE: Only stylesheet locations for EAD2002 have been updated in this module
   Others would need to be updated to display other document types. 
 :)

(:~  Parses a XTF-like view URL i.e. a single docId param with additional params separated by ";" : ?docId=document-path;chunk.id=c2;toc.id=t2 :)
declare
  %rest:path( '/view')
  %rest:query-param( "docId", "{$query}", "")
  %rest:query-param( "ead3", "{$ead3}", "" )
  %rest:GET
  %output:method('html')
  %output:version( '5.0')
function view:view( $query as xs:string, $ead3 as xs:string? ) {
   let $params := map:merge( for $p in tokenize( concat( 'docId=', $query), ';' ) 
   		return apply( map:entry#2, array{ tokenize($p, '=') }) )
	let  $doc := doc( $params('docId'))
   return switch( view:doctype( $params('docId') ))
       case 'EAD2002'
	   return 
	   		if ( $ead3 ) then 
	   	 			ead3:EAD2002toHTML( view:xinclude($doc) )
	   			 else
       xslt:transform( util:strip-namespaces( xslt:transform( view:xinclude($doc), 'static/xslt/EAD2002-cToCn.xsl'  ) ),
                "https://ead.lib.virginia.edu/vivaxtf/style/dynaXML/docFormatter/VIVAead/eadDocFormatter.xsl" ,
               $params )
		case 'EAD3' 
		return ead3:EAD3toHTML( $doc )
    default return $doc
};

(:~ dispatch on doctype: first try namespace and then root element :)
declare
function view:doctype( $path as xs:string ) {
   let $doc := doc($path)
   let $node := $doc/*
   let $ns := namespace-uri($node)
   return switch ( $ns )
   case 'urn:isbn:1-931666-22-9'
      return   'EAD2002'
   case 'http://ead3.archivists.org/schema/'
      return  'EAD3'
   case 'http://www.tei-c.org/ns/1.0' (: TEIP5 :)
      return 'TEIP5'
   case 'http://www.w3.org/1999/xhtml' (: XHTML :)
      return 'xhtml'
   default  return typeswitch ($node)
      case element(ead) (: no namespace, assume EAD2002 :)
          return "EAD2002"
      case element(TEI) (: TEIP5 :)
          return "TEIP5"
      case element(TEI.2) (: TEIP4 :)
          return  "TEIP4"
      case element(HTML) (: html :)
          return "html"
      case element(html) (: html :)
          return "html"
      default return  name($node)
};



declare function view:xinclude( $doc ) {
	xslt:transform( $doc, 'static/xslt/xipr.xsl' )
};
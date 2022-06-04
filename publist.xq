import module namespace request = "http://exquery.org/ns/request";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:omit-xml-declaration "no";
declare option output:method "xhtml";
(: http://docs.basex.org/wiki/XQuery_3.0#Serialization  :)

(: 
declare variable $contains := 
try { request:parameter( 'contains' ) }
catch basex:http { '' }; 

 Simpler to use implicit assignment: http://docs.basex.org/wiki/REST#Assigning_Variables
"All query parameters that have not been processed before will be treated as variable assignments:"
:)

declare variable $contains as xs:string external := "";
declare variable $htmlstyle := "http://localhost:8008/vivaxtf/style/dynaXML/docFormatter/VIVAead/eadDocFormatter.xsl" ;
declare variable $preprocessor := "http://localhost:8008/vivaxtf/style/textIndexer/ead/VIVAeadPreFilter.xsl" ;


<html><head><title>test</title></head><body>
<div>
{ if ( $contains != '' ) then
  <h3>{ 'Titles containing: "' || $contains || '"' }</h3> 
  else () }
</div>
<ol>
{ for $doc in collection( substring-after( request:path(), request:context-path()|| '/rest'  ) )/*:ead/*:eadheader//*:titlestmt/*:titleproper
  where contains($doc, $contains )
  return <li>{ $doc//text() } &#160; <a href="{ request:context-path() || '/rest'  || fn:base-uri($doc)}" > [XML] </a>
  &#160; <a href="{ request:context-path() || '/view?docId=' || fn:base-uri($doc)}" > [HTML] </a></li>
}
</ol>
</body></html>
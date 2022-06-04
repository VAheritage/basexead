
module namespace xtfview = 'http://localhost/view';


(:~  Parses a XTF-like view URL i.e. a single docId param with additional params separated by ";" : ?docId=document-path;chunk.id=c2;toc.id=t2 :)
declare
  %rest:path( '/view')
  %rest:query-param( "docId", "{$query}", "")

  %rest:GET
function xtfview:view( $query as xs:string) {
   let $params := map:merge( for $p in tokenize( concat( 'docId=', $query), ';' ) return apply( map:entry#2, array{ tokenize($p, '=') }) )
   return switch( xtfview:doctype( $params('docId') ))
    case 'TEIP4'
   return xslt:transform( xslt:transform( doc($params('docId')), "/projects/SIB/add_id_bov.xsl" ),
                  "/usr/local/projects/XTF/xtf.lib/style/dynaXML/docFormatter/tei/teiDocFormatter.xsl" ,
                  $params )
    case 'TEIP5'
      return xslt:transform( doc($params('docId')), '/projects/TEI/tei2html/tei2html.xsl'  )
      (: return xslt:transform( doc($params('docId')),  "/projects/TEI/tei2html/tei2html.xsl" ) :)
    case 'EAD2002'
      return xslt:transform( util:strip-namespaces(doc($params('docId'))),
                "/usr/local/projects/XTF/vivaxtf/style/dynaXML/docFormatter/VIVAead/eadDocFormatter.xsl" ,
                $params )
    default return doc($params('docId'))
};

(:~ dispatch on doctype: first try namespace and then root element :)
declare
function xtfview:doctype( $path as xs:string ) {
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

declare %rest:path( '/search' )
        %rest:GET
        %rest:query-param( "title", "{$title}" )
        %rest:query-param( "subject", "{$subject}")
        %output:method('html')       
function xtfview:search( $title as xs:string? , $subject as xs:string? ) {
<html xmlns='http://www.w3.org/1999/xhtml'>
<head></head>
<body>
<div id="search_form">
<form method="get" action="/search">
  <div>
    <dt>Title:</dt>
    <dd><input type="text" name="title" label="title" value="{$title}" /></dd>
    <dt>Subject:</dt>
    <dd><input type="text" name="subject" label="subject" value="{$subject}"/></dd>
    <input type="submit" value="Search" />
  </div>
</form>
</div>
<div id="search_results">
 <h4>
 { if ($title) then concat( 'TITLE:', $title), '; ' }
 { if ($subject) then concat('SUBJECT:', $subject), ';' }
 { request:parameter-names() }
 </h4>
 { for $doc in xtfview:findByTitle( collection('published'), $title ) =>
 xtfview:findBySubj( $subject ) 

    return <p>{ $doc//*:titleproper/normalize-space() }</p> }
</div>
</body>     
</html>        
};

(: DEVELOPMENT: reload and parse restxq modules :)
declare %rest:path( 'WTF')
        %rest:GET
function xtfview:reset(){
  (rest:init(),rest:wadl())
};  



declare function xtfview:findBySubj( $ctx, $subj as xs:string )  {
  if ( $subj )  then $ctx/*[ //*:subject contains text { ft:tokenize($subj) } all ]
  else $ctx 
};   

declare function xtfview:findByTitle( $ctx as node()*, $title as xs:string )  {
  if ( $title ) then $ctx/*[ //*:titlestmt contains text { ft:tokenize($title) } all ]
  else $ctx
};  
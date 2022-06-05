
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
        %rest:query-param( "subj_mode", "{$subj_mode}")
        %rest:query-param( "title_mode", "{$title_mode}" )
        %output:method('html')       
function xtfview:search( $title as xs:string? , $subject as xs:string?, 
 $subj_mode as xs:string, $title_mode as xs:string ) {
<html xmlns='http://www.w3.org/1999/xhtml'>
<head></head>
<body>
<div id="search_form">
<form method="get" action="/search">
  <div>
    <dt>Title:</dt>
    <dd><input type="text" name="title" label="title" value="{$title}" />
    { xtfview:HTMLselect( 'title_mode', ('all', 'any')) }</dd>
    <dt>Subject:</dt>
    <dd><input type="text" name="subject" label="subject" value="{$subject}"/>
    { xtfview:HTMLselect( 'subj_mode', ('all', 'any')) }</dd>
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
 <ul>
 { for $doc in xtfview:findByTitle( collection('published'), $title, 
   map{ 'mode' : $subj_mode } )
  =>  xtfview:findBySubj( $subject, map{ 'mode' : $subj_mode } ) 

    return <li> { xtfview:linkto( $doc ) } </li> }
    
    </ul>
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



declare function xtfview:findBySubj( $ctx, $subj as xs:string, $opt  )  {
  if ( $subj )  then $ctx/*[ft:contains( .//*:subject, ft:tokenize($subj), $opt )]
  else $ctx 
};   

declare function xtfview:findByTitle( $ctx as node()*, $title as xs:string, $opt )  {
  if ( $title ) 
  then
  $ctx/*[ft:contains( .//*:titlestmt, ft:tokenize($title), $opt)]
  else $ctx
};  

declare function xtfview:linkto( $doc  ) { 

   <a href="{ request:context-path() || '/view?docId=' || fn:base-uri($doc)}" >
    {  root($doc)//*:ead/*:eadheader//*:titlestmt/normalize-space()  }
   </a>

};

declare function xtfview:HTMLselect( $name, $values ) { 
  <select name="{$name}">
     { for $v in $values return <option>{$v}</option> }
  </select>
};
module namespace eadsearch = 'http://localhost/eadsearch';

declare default element namespace "urn:isbn:1-931666-22-9" ; (: EAD2002 :)

(: TODO: add search by persname, unittitles, IDs ( top unitid and /titlestmt//num, vi# ),  
	any text &	publisher select & facets, ( other facets if possible? )
:)


declare %rest:path( '/search' )
        %rest:GET
        %rest:query-param( "title", "{$title}" )
        %rest:query-param( "subject", "{$subject}")
        %rest:query-param( "subj_mode", "{$subj_mode}")
        %rest:query-param( "title_mode", "{$title_mode}" )
        %output:method('html')       
function eadsearch:search( $title as xs:string? , $subject as xs:string?, 
 $subj_mode as xs:string?, $title_mode as xs:string? ) {
<html xmlns='http://www.w3.org/1999/xhtml'>
<head></head>
<body>
<div id="search_form">
<form method="get" action="{rest:uri()}">
  <div>
    <dt>Title:</dt>
    <dd><input type="text" name="title" label="title" value="{$title ?: '' }" />
    { eadsearch:HTMLselect( 'title_mode', ('all', 'any')) }</dd>
    <dt>Subject:</dt>
    <dd><input type="text" name="subject" label="subject" value="{$subject ?: ''}"/>
    { eadsearch:HTMLselect( 'subj_mode', ('all', 'any')) }</dd>
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
 { for $doc in eadsearch:findByTitle( collection('published'), $title, 
   map{ 'mode' : $title_mode ?: "all" } )
  =>  eadsearch:findBySubj( $subject, map{ 'mode' : $subj_mode ?: "all" } ) 

    return <li> { eadsearch:linkto( $doc ) } </li> }
    
    </ul>
</div>
</body>     
</html>        
};




declare function eadsearch:findBySubj( $ctx, $subj as xs:string?, $opt  )  {
  if ( $subj )  then $ctx/*[ft:contains( .//subject, ft:tokenize($subj), $opt )]
  else $ctx 
};   

declare function eadsearch:findByTitle( $ctx as node()*, $title as xs:string?, $opt )  {
  if ( $title ) 
  then
  $ctx/*[ft:contains( .//titlestmt, ft:tokenize($title), $opt)]
  else $ctx
};  

declare function eadsearch:linkto( $doc  ) { 

	<span>{ root($doc)//ead/eadheader/eadid/@mainagencycode/string() }: 
   <a href="{ rest:base-uri() || '/view?docId=' || base-uri($doc)}" >
    {  root($doc)//ead/eadheader//titlestmt/normalize-space()  }
   </a></span>

};

declare function eadsearch:HTMLselect( $name, $values ) { 
  <select name="{$name}">
     { for $v in $values return <option value="{$v}"  >{$v}</option> }
  </select>
};
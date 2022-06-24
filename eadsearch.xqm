module namespace eadsearch = 'http://localhost/eadsearch';

declare default element namespace "urn:isbn:1-931666-22-9" ; (: EAD2002 :)

(: TODO: add search by persname, unittitles, IDs ( top unitid and /titlestmt//num, vi# ),  
	any text &	publisher select & facets, ( other facets if possible? )
:)


declare %rest:path( '/search' )
        %rest:GET
        %rest:query-param( "title", "{$title}" )
        %rest:query-param( "subject", "{$subject}")
		%rest:query-param( "person", "{$person}")
        %rest:query-param( "subj_mode", "{$subj_mode}")
        %rest:query-param( "title_mode", "{$title_mode}" )
		%rest:query-param( "pers_mode", "{$pers_mode}" )
		%rest:query-param( "start", "{$start}")
		%rest:query-param( "count", "{$count}")
        %output:method('html')       
function eadsearch:search( $title as xs:string? , $subject as xs:string?, $person as xs:string?, 
 $subj_mode as xs:string?, $title_mode as xs:string?, $pers_mode as xs:string?, 
 $start as xs:int?, $count as xs:int? ) {
<html xmlns='http://www.w3.org/1999/xhtml'>
<head></head>
<body>
<div id="search_form">
<form method="get" action="search">
  <div>
    <dt>Title:</dt>
    <dd><input type="text" name="title" label="title" value="{$title ?: '' }" />
    { eadsearch:HTMLselect( 'title_mode', ('all', 'any')) }</dd>
    <dt>Subject:</dt>
    <dd><input type="text" name="subject" label="subject" value="{$subject ?: ''}"/>
    { eadsearch:HTMLselect( 'subj_mode', ('all', 'any')) }</dd>
	<dt>Persons:</dt>
	<dd><input type="text" name="person" label="person"   value="{$person ?: ''}" />
	{ eadsearch:HTMLselect( 'pers_mode', ('all', 'any')) }</dd>
    <input type="submit" value="Search" />
  </div>
</form>
</div>
<div id="search_results">
 <h4>
 { if ($title) then concat( 'TITLE:', $title), '; ' }
 { if ($subject) then concat('SUBJECT:', $subject), ';' }
 { if ($person) then concat('PERSON:', $person), ';' }
 (: { request:parameter-names() } :)
 </h4>
 <ul>
 { for $doc in eadsearch:findBy( collection('published'), 'titlestmt', $title,
   map{ 'mode' : $title_mode ?: "all" } )
  =>  eadsearch:findBy( 'subject', $subject, map{ 'mode' : $subj_mode ?: "all" } )
  =>  eadsearch:findBy( 'persname', $person, map{ 'mode' : $pers_mode ?: "all" } )
  => subsequence( if ($start) then $start else 1, if ($count) then $count else 100 )

    return <li> { eadsearch:linkto( $doc ) } </li> }
    
    </ul>
</div>
</body>     
</html>        
};


declare function eadsearch:findBy( $ctx, $field as xs:string, $what as xs:string?, $opt ) {
	if( $what ) then
	$ctx/*[ft:contains( xquery:eval( ".//*:" || $field, map{ '' : . } ), ft:tokenize($what), $opt )]
	else $ctx
};



declare function eadsearch:linkto( $doc  ) { 

	<span>{ root($doc)//ead/eadheader/eadid/@mainagencycode/string() }: 
   <a href="{ 'view?docId=' || base-uri($doc)}" >
    {  root($doc)//ead/eadheader//titlestmt/normalize-space()  }
   </a></span>

};

declare function eadsearch:HTMLselect( $name, $values ) { 
  <select name="{$name}">
     { for $v in $values return <option value="{$v}"  >{$v}</option> }
  </select>
};
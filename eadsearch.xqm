module namespace eadsearch = 'http://localhost/eadsearch';

import module namespace pf='http://localhost/pubfacets' at "pubfacets.xqm" ;

declare default element namespace "urn:isbn:1-931666-22-9" ; (: EAD2002 :)

(: TODO: add search by persname, unittitles, IDs ( top unitid and /titlestmt//num, vi# ),  
	any text &	publisher select & facets, ( other facets if possible? )
:)


declare %rest:path( '/search' )
        %rest:GET %rest:POST
        %rest:query-param( "title", "{$title}" )
        %rest:query-param( "subject", "{$subject}")
		%rest:query-param( "person", "{$person}")
        %rest:query-param( "subj_mode", "{$subj_mode}")
        %rest:query-param( "title_mode", "{$title_mode}" )
		%rest:query-param( "pers_mode", "{$pers_mode}" )
		%rest:query-param( "start", "{$start}", 1)
		%rest:query-param( "count", "{$count}", 25 )
        %output:method('html')       
function eadsearch:search( $title as xs:string* , $subject as xs:string*, $person as xs:string*, 
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
    { eadsearch:HTMLselect( 'title_mode', ('all', 'any'), $title_mode ) }</dd>
    <dt>Subject:</dt>
    <dd><input type="text" name="subject" label="subject" value="{$subject ?: ''}"/>
    { eadsearch:HTMLselect( 'subj_mode', ('all', 'any'), $subj_mode ) }</dd>
	<dt>Persons:</dt>
	<dd><input type="text" name="person" label="person"   value="{$person ?: ''}" />
	{ eadsearch:HTMLselect( 'pers_mode', ('all', 'any'), $pers_mode ) }</dd>
    <input type="submit" value="Search" />
	<input type="reset" value="Clear Search" onclick="location.href='search'"/>
	<input type="hidden" name="count" value="25" />
	<input type="hidden" name="start" value="1" /> 
  </div>
</form>
</div>
<div id="search_results">

 { let $docs := eadsearch:findBy( collection('published'), 'titlestmt', $title,
   map{ 'mode' : $title_mode ?: "all" } )
  =>  eadsearch:findBy( 'subject', $subject, map{ 'mode' : $subj_mode ?: "all" } )
  =>  eadsearch:findBy( 'persname', $person, map{ 'mode' : $pers_mode ?: "all" } ) 
  return  <div><h4> {$start} to {$start+$count} of { count($docs) } found:
  { for $p in request:parameter-names()
    where ( not(ends-with($p, "_mode")) and not($p = ("start", "count")) and request:parameter($p)[1]  ) 
    return concat($p,'=', string-join(request:parameter($p), ';' )) }
   </h4> <ul>
  {
	  for $doc in subsequence( $docs, $start, $count )
	    return <li> { eadsearch:linkto( $doc ) } </li> 	   
  }
  </ul>
  <div><h4>Publishers:</h4><ol>
  { for $x in pf:countpubfacets( collection('published/oai')) 
  	  where  ( array:size($x) = 4 )
      return <li>{ array:flatten($x) }</li> }
   </ol></div>
  </div>
}
</div>
<div>
<hr/><br/>

<a href="search?{ substring-before(request:query(), '&amp;start=' ) }&amp;start={ string($start + $count) }" >

<input type="button"  value="Next" />
</a>
<br/><hr/><br/>
</div>
</body>     
</html>        
};


declare function eadsearch:findBy( $ctx, $field as xs:string, $what as xs:string*, $opt ) {
	if( $what[1] ) then
	$ctx/*[ft:contains( xquery:eval( ".//*:" || $field, map{ '' : . } ), ($what ! ft:tokenize(.)), $opt )]
	else $ctx
};



declare function eadsearch:linkto( $doc  ) { 

	<div>
   <a href="{ 'view?docId=' || base-uri($doc)}" >
    {  root($doc)//ead/eadheader//titlestmt/normalize-space()  }
   </a>
   <div> 
   {  concat(root($doc)//ead/eadheader/eadid/@mainagencycode/string(), ': ', root($doc)/ead/eadheader//publisher/string()) } 
   </div>
   <br/>
   </div>

};

declare function eadsearch:HTMLselect( $name, $values, $selected as xs:string? ) { 
  <select name="{$name}">
     { for $v in $values return 
		 if ($v = $selected ) then <option value="{$v}" selected="selected"  >{$v}</option>  
		 else
		 <option value="{$v}" >{$v}</option> }
  </select>
};
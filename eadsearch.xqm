module namespace eadsearch = 'http://localhost/eadsearch';

import module namespace pf='http://localhost/pubfacets' at "pubfacets.xqm" ;

declare default element namespace "urn:isbn:1-931666-22-9" ; (: EAD2002 :)

(: TODO: add search by [persname, unittitles,] IDs ( top unitid and /titlestmt//num, vi# ),  
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
		%rest:query-param( "publisher", "{$publisher}")
		%rest:query-param( "text", "{$text}")
		%rest:query-param( "start", "{$start}", 1)
		%rest:query-param( "count", "{$count}", 25 )
		%output:method('html')
		%output:version( '5.0')
function eadsearch:search( $title as xs:string* , $subject as xs:string*, $person as xs:string*, 
	$publisher as xs:string?, $text as xs:string*, 
	$subj_mode as xs:string?, $title_mode as xs:string?, $pers_mode as xs:string?, 
	$start as xs:int?, $count as xs:int? ) {

<html xmlns='http://www.w3.org/1999/xhtml'>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Search</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0-beta1/dist/css/bootstrap.min.css" 
	rel="stylesheet" integrity="sha384-0evHe/X+R7YkIZDRvuzKMRqM+OrBnVFBL6DOitfPri4tjfHxaWutUpFmBp4vmVor" 
	crossorigin="anonymous" />
</head>
<body>


<div class="container" >
<img src="/static/images/ARVAS_fullnamelogo.png"  class="img-thumbnail" />
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
			<dt>Publisher:</dt>
			<dd><input type="text" name="publisher" label="publisher"   value="{$publisher ?: ''}" /></dd>

			<dt>text (anywhere):</dt>
			<dd><input type="text" name="text" label="text"   value="{$text ?: ''}" /></dd>

			<input type="submit" value="Search" />
			<input type="reset" value="Clear Search" onclick="location.href='search'"/>
			<input type="hidden" name="count" value="25" />
			<input type="hidden" name="start" value="1" /> 
		</div>
	</form>
</div><!-- search-form -->

<div id="search_results">

{ let $docs := eadsearch:findBy( collection('published'), 'titlestmt', $title, map{ 'mode' : $title_mode ?: "all" } )
  =>  eadsearch:findBy( 'subject', $subject, map{ 'mode' : $subj_mode ?: "all" } )
  =>  eadsearch:findBy( 'persname', $person, map{ 'mode' : $pers_mode ?: "all" } ) 
  =>  eadsearch:findBy(  'publisher', ( $publisher ?: '' ), map{ 'mode' : "phrase"} )
  =>  eadsearch:findBy(  'archdesc', $text, map{ 'mode' : 'all' } )
  return
    
	<div><h4> {$start} to {$start+$count} of  { count($docs) }  found:
		{ for $p in request:parameter-names()
		where ( not(ends-with($p, "_mode")) and not($p = ("start", "count")) and request:parameter($p)[1]  ) 
		return concat($p,'=', string-join(request:parameter($p), ';' )) }
		</h4>
		<ul class="list-group">
		{
			let $debug := prof:variables()
			for $doc in subsequence( $docs, $start, $count )
			return <li class="list-group-item"> { eadsearch:linkto( $doc ) } </li>
		}
		</ul>
		<div id="publishers" ><h4>Publishers: { count($docs) }</h4><ul class="list-group">
		{ 
			let $debug := prof:variables()
			for $x in fn:trace( pf:countpubfacets( $docs ) )
			where  ( array:size($x) = 4 )
			return <li class="list-group-item">
			<a href="search?{ request:query() }&amp;publisher={ $x(4) }">{ ( $x(3), $x(4)) }</a>
			[{$x(1)}]</li> }
			</ul>
		</div> <!-- publishers -->

  	  </div>
}
</div><!-- search results -->

<div id="next">
	<hr/><br/>
	<a href="search?{ substring-before(request:query(), '&amp;start=' ) }&amp;start={ string($start + $count) }" >
	<input type="button"  value="Next" />
	</a>
	<br/><hr/><br/>
</div> <!-- next -->
</div > <!-- container --> 
</body>
</html>        
};


declare function eadsearch:findBy( $ctx, $field as xs:string, $what as xs:string*, $opt ) {
	if( $what[1] ) then
	$ctx/*[ft:contains( xquery:eval( ".//*:" || $field, map{ '' : . } ), ($what ! ft:tokenize(.)), $opt )] ! root(.)
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
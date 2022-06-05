
module namespace vivaead = 'http://localhost/vivaead';


declare %rest:path( '/search' )
        %rest:GET
        %rest:query-param( "title", "{$title}" )
        %rest:query-param( "subject", "{$subject}")
        %rest:query-param( "subj_mode", "{$subj_mode}")
        %rest:query-param( "title_mode", "{$title_mode}" )
        %output:method('html')       
function vivaead:search( $title as xs:string? , $subject as xs:string?, 
 $subj_mode as xs:string?, $title_mode as xs:string? ) {
<html xmlns='http://www.w3.org/1999/xhtml'>
<head></head>
<body>
<div id="search_form">
<form method="get" action="/search">
  <div>
    <dt>Title:</dt>
    <dd><input type="text" name="title" label="title" value="{$title ?: '' }" />
    { vivaead:HTMLselect( 'title_mode', ('all', 'any')) }</dd>
    <dt>Subject:</dt>
    <dd><input type="text" name="subject" label="subject" value="{$subject ?: ''}"/>
    { vivaead:HTMLselect( 'subj_mode', ('all', 'any')) }</dd>
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
 { for $doc in vivaead:findByTitle( collection('published'), $title, 
   map{ 'mode' : $title_mode ?: "all" } )
  =>  vivaead:findBySubj( $subject, map{ 'mode' : $subj_mode ?: "all" } ) 

    return <li> { vivaead:linkto( $doc ) } </li> }
    
    </ul>
</div>
</body>     
</html>        
};

(: DEVELOPMENT: reload and parse restxq modules :)
declare %rest:path( 'WTF')
        %rest:GET
function vivaead:reset(){
  (rest:init(),rest:wadl())
};  



declare function vivaead:findBySubj( $ctx, $subj as xs:string?, $opt  )  {
  if ( $subj )  then $ctx/*[ft:contains( .//*:subject, ft:tokenize($subj), $opt )]
  else $ctx 
};   

declare function vivaead:findByTitle( $ctx as node()*, $title as xs:string?, $opt )  {
  if ( $title ) 
  then
  $ctx/*[ft:contains( .//*:titlestmt, ft:tokenize($title), $opt)]
  else $ctx
};  

declare function vivaead:linkto( $doc  ) { 

   <a href="{ request:context-path() || '/view?docId=' || fn:base-uri($doc)}" >
    {  root($doc)//*:ead/*:eadheader//*:titlestmt/normalize-space()  }
   </a>

};

declare function vivaead:HTMLselect( $name, $values ) { 
  <select name="{$name}">
     { for $v in $values return <option value="{$v}"  >{$v}</option> }
  </select>
};
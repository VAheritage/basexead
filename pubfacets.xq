(:
	test of collecting publisher facets from @mainagencycode works acceptably 
    however, tests of using the same method for //subject or //persname was unacceptable slow. 
    There are less than 100 unique publishers and the code is found in the same location, 
    while there are 10s of thousands of subjects or persons mentioned and they can be scattered 
    in many places in the document. 

 :)


declare function local:normalize( $s ) {
  translate( replace( lower-case($s), '^(us-)+', '' ), '-', '' )
};

declare variable  $orgs := doc('ead-inst/ead-inst.xml');
declare variable $orgcodes :=  collection('published')/ead/eadheader/eadid/@mainagencycode ! local:normalize(.) => distinct-values() ;

declare function local:countpubfacets( $c ) {

for $x in  (  
for $ead in $c
let $ORG := local:normalize($ead/*:ead/*:eadheader/*:eadid/@mainagencycode)
group by $ORG
order by $ORG
let $inst := if ($ORG != "") then ($orgs/list/inst[@prefix=$ORG],$orgs/list/inst[lower-case(@oclc) = $ORG] )
return array{ count($ead), $ORG, $inst/@orgcode/string(),  $inst/string() } ) 
 order by $x(1) descending return $x
};

local:countpubfacets( collection('published'))
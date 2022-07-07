
## BaseX/XQuery implementation of search and display webapp for EAD xml
###  intended as an experimental replacement for XTF  ( in Development )


xtfview.xqm was written for some earlier tests and dispatches to existing legacy XTF stylesheets
based on document type. However, those stylesheets are not included. The EAD stylesheets are
the only display type used in this project, and initially, they are accessed from http://ead.lib.virginia.edu 

Final version will include stylesheets locally, and they will likely be re-written. 
( EAD3 stylesheets are local. I attempted to copy XTF stylesheets into local directory, but it includes or imports
stylesheets outside of VIVAead directory, and also pulls in header & trailer info from XTF/brand/ directory, with
relative file paths. Need to sort these out and deal with the "../../..?" pathnames : probably better to edit those
paths than to try to recreate relative positions. ) 

BaseX DB are also not included within this project. 

Requires Saxon 9 or 10 for processing XSLT 2.0 ( or later ) stylesheets. ( added CLASSPATH or to BaseX /lib/custom )
*[ NOTE: Saxon 11 FAILS with: 
`javax.xml.transform.TransformerFactoryConfigurationError: 
Provider net.sf.saxon.TransformerFactoryImpl could not be instantiated: 
java.lang.reflect.InvocationTargetException` 
However, if new xmlresolver jars are included in CLASSPATH, Saxon 11.3 appears to work. ]*


#### issues: 

- SearchBy publisher does not included the normalization of various publisher sources done currently in XTF, and does not match by @mainagencycode: it sometimes fails as there are multiple publisher fields that don't always agree. Need to rewrite using @mainagencycode or some combination of multiple searches. 

- Gathering and sorting publisher facets real-time works, but there are less than 50 publishers. Trying to build subject or persons facets where there are tens of thousands of distinct-values hasn't worked acceptable using the same method. It will likely require building an auxilary index when documents are added. Could be done in BaseX or maybe use SOLR. 

- Subjects listed under document search results are truncated. Probably should provide some indication of that. 

- BaseX Full Text search has a bunch of options and some performance issues with [mixed content](https://docs.basex.org/wiki/Full-Text#Mixed_Content) that I haven't sorted out yet. This hasn't been an issue with searches within title,subject, etc. It remains to be determined if I can get reasonable performance with desired options on searches of full text of document. ( actually, everything below /ead/archdesc/ - we can ignore eadheader and [deprecated] frontmatter )

- default sort order is newest file first. Add sort order options later. 

- XTF textinderer does some other preprocessing besides stripping namespaces. One of those is converting unnumbered <c> elements to numbered elements. OAI feed from ArchivesSpace by default exports unnumbered <c> elements unless specially configured to export numbered <c0n> elements. ( Ours at UVA is configured this way. ) It appears that the EAD3toHTML stylesheet also requires numbered <c> elements. So initially, this view was only showing the first level series. I have added conversion stylesheets for both to the pipeline. However, I should look further at preprocessing stylesheets (which are used for textIndexer in XTF and are not used in this implementation ) to see if there are any other necessary transforms. 


#### Other:

- /rest/$DB/$PATH... e.g. /rest/published/org/finding-aid.xml 

- append '?run=toEAD3.xq' to the end of a REST URL resolving to a single document to convert to return document converted to EAD3 from EAD2002 

- Append *"?ead3=true"* to /search or "&ead=true" to /view?docId=... URLs to convert EAD2002 to EAD3 and display using EAD3 to HTML stylesheet. ( EAD3 stylesheet is still a work-in-progress, starting from: (https://github.com/saa-ead-roundtable/ead3-stylesheets.git)







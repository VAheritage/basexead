
## BaseX/XQuery implementation of search and display webapp for EAD xml
###  intended as an experimental replacement for XTF  ( in Development )


xtfview.xqm was written for some earlier tests and dispatches to existing legacy XTF stylesheets
based on document type. However, those stylesheets are not included. The EAD stylesheets are
the only display type used in this project, and initially, they are accessed from http://ead.lib.virginia.edu 

Final version will include stylesheets locally, and they will likely be re-written. 

BaseX DB are also not included within this project. 

#### issues: 

- SearchBy publisher does not included the normalization of various publisher sources done currently in XTF, and does not match by @mainagencycode: it sometimes fails. Need to rewrite using @mainagencycode.

- BaseX Full Text search has a bunch of options and some performance issues with [mixed content](https://docs.basex.org/wiki/Full-Text#Mixed_Content) that I haven't sorted out yet. This hasn't been an issue with searches within title,subject, etc. It remains to be determined if I can get reasonable performance with desired options on searches of full text of document. ( actually, everything below /ead/archdesc/ - we can ignore eadheader and [deprecated] frontmatter )


Requires Saxon 9 or 10 for processing XSLT 2.0 ( or later ) stylesheets. ( added to BaseX /lib )
*( Saxon 11 FAILS with: javax.xml.transform.TransformerFactoryConfigurationError: Provider net.sf.saxon.TransformerFactoryImpl could not be instantiated: java.lang.reflect.InvocationTargetException 
However, if new xmlresolver jars are included in CLASSPATH, Saxon 11.3 appears to work. )*





## BaseX/XQuery implementation of search and display webapp for EAD xml
###  intended as an experimental replacement for XTF  ( in Development )


xtfview.xqm was written for some earlier tests and dispatches to existing legacy XTF stylesheets
based on document type. However, those stylesheets are not included. The EAD stylesheets are
the only display type used in this project, and initially, they are accessed from http://ead.lib.virginia.edu 

Final version will include stylesheets locally, and they will likely be re-written. 

BaseX DB are also not included within this project. 

Requires Saxon 9 or 10 for processing XSLT 2.0 ( or later ) stylesheets. ( added to BaseX /lib )
*( Saxon 11 FAILS with: javax.xml.transform.TransformerFactoryConfigurationError: Provider net.sf.saxon.TransformerFactoryImpl could not be instantiated: java.lang.reflect.InvocationTargetException )*




(: Transform EAD2002 to EAD3
   to be used from /rest API by appending "?run=toEAD3.xq" to /rest document URI :)
   
xslt:transform( ., 'static/xslt/EAD2002ToEAD3schema_undeprecated.xsl')

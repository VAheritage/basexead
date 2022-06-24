module namespace viva = 'http://localhost/viva-redirects';

(: Redirect requests for static resources (css,logo,etc.) 
   to ead.lib server. Hopefully, a temporary hack.  :)

declare %rest:path( "/css/viva/{$css}" )
		%rest:GET
function viva:css( $css ) {
	web:redirect( "https://ead.lib.virginia.edu/vivaxtf/css/viva/" || $css )
};

declare %rest:path( "/vivaxtf/{$path=.+}" )
		%rest:GET
function viva:vivaxtf( $path ) {
	web:redirect( "https://ead.lib.virginia.edu/vivaxtf/" || $path )
};

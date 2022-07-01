module namespace develop = 'http://localhost/develop' ;

(:  DEVELOPMENT: 
	reload and parse restxq modules so you don't have to restart server when live editing
	on further reading of the documentation, I see you can get a reset at  /.init URL as well,
	but I like the feedback from wadl report. 
:)

declare %rest:path( 'WTF')
        %rest:GET
function develop:reset(){
  (rest:init(),rest:wadl())
};  

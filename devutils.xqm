module namespace develop = 'http://localhost/develop' ;

(:  DEVELOPMENT: 
	reload and parse restxq modules so you don't have to restart server when live editing :)

declare %rest:path( 'WTF')
        %rest:GET
function develop:reset(){
  (rest:init(),rest:wadl())
};  

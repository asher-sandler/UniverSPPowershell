
function fetchCors () {
    console.log("Fetch Hello!");
    
    return fetch(url,{
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin':  'origin'
         
         
        }})
    .then(response => response.json())
    
 
}
var url; //= 'https://jsonplaceholder.typicode.com/todos/1';
var corsAny = "https://cors-anywhere.herokuapp.com/";
url =  'https://api.elsevier.com/content/search/scopus?query=AU-ID%28%22Abramovitch%2C%20Rinat%22%207006021357%29&apikey=aae05ff3e3bf429e9f7fe79991a89ad3';

fetchCors()
.then(data => {
    console.log ("Data :", data);
    var i=0;
        for(var k in data["search-results"]["entry"]) {
          
                document.getElementById("id02").innerHTML+=data["search-results"]["entry"][i]["dc:creator"];

				document.getElementById("id02").innerHTML+=", <b>"+data["search-results"]["entry"][i]["dc:title"] + "</b>";
				
				document.getElementById("id02").innerHTML+=", "+data["search-results"]["entry"][i]["prism:publicationName"];
				
				document.getElementById("id02").innerHTML+=", "+data["search-results"]["entry"][i]["prism:volume"];
				
				document.getElementById("id02").innerHTML+=", "+data["search-results"]["entry"][i]["prism:pageRange"];
				
				document.getElementById("id02").innerHTML+=", "+data["search-results"]["entry"][i]["prism:coverDisplayDate"];

				document.getElementById("id02").innerHTML+=", DOI: "+data["search-results"]["entry"][i]["prism:doi"] + "<br><br>";
                i++;
                        
        }
}).catch(e => {
    console.error(e);
});
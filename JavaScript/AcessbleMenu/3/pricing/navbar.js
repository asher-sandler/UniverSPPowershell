/* Set the width of the side navigation to 250px */
var canIncrease = true;
var canDecrease = true;
function openNav() {
    document.getElementById("mySidenav").style.width = "250px";
    //document.getElementById("container").style.marginLeft = "250px";
  }
  
  /* Set the width of the side navigation to 0 */
  function closeNav() {
    document.getElementById("mySidenav").style.width = "0";
    //document.getElementById("container").style.marginLeft = "0";
  }

function toggleLR(){
  const navPanel = document.querySelector('#mySidenav');
  const toolBarIcon = document.querySelector('#tBarIcon');
  const toggleClassName = "panel-right";

  
  if (navPanel.classList.contains(toggleClassName)){
    navPanel.classList.remove(toggleClassName);
    toolBarIcon.classList.remove(toggleClassName);
  }
  else
  {
    navPanel.classList.add(toggleClassName);
    toolBarIcon.classList.add(toggleClassName);
  }
}
  
function incrFont() {
	
	// Get all the elements on the page
	var elements = document.getElementsByTagName('*');

	// Define an empty array to store the classes
	var classes = [];

	// Loop through all the elements
	for (var i = 0; i < elements.length; i++) {
	  var elementClasses = elements[i].classList;
	  // Check if the element has any classes
	  if (elementClasses.length) {
		// Loop through all the classes
		for (var j = 0; j < elementClasses.length; j++) {
		  var currentClass = elementClasses[j];
		  // Check if the class is already in the array
		  if (classes.indexOf(currentClass) === -1) {
			// If the class is not in the array, add it
			classes.push(currentClass);
		  }
		}
	  }
	}
	// Output the array of classes
	//console.log('canIncrease:',canIncrease);
	//console.log('canDecrease:',canDecrease);

	// Loop through all the classes and increase font size by 150%, but not exceeding 300%
	if (canIncrease){
		for (var i = 0; i < classes.length; i++) {
		  var elementsWithClass = document.getElementsByClassName(classes[i]);
		  // Loop through all elements with this class and increase font size
		  for (var j = 0; j < elementsWithClass.length; j++) {
			var currentElement = elementsWithClass[j];
			currentElement.style.fontSize = '';
			var currentFontSize = window.getComputedStyle(currentElement, null).getPropertyValue('font-size');
			var newFontSize = parseInt(currentFontSize) * 1.1;
			//console.log(newFontSize);
			
            //console.log('Increase Font');
		    currentElement.style.fontSize = newFontSize + 'px';
		
		  }
		}
		canIncrease = false;
		canDecrease = true;
	}

		
}

function decrFont() {
	console.log('Decrease Font');
	// Get all the elements on the page
	var elements = document.getElementsByTagName('*');

	// Define an empty array to store the classes
	var classes = [];

	// Loop through all the elements
	for (var i = 0; i < elements.length; i++) {
	  var elementClasses = elements[i].classList;
	  // Check if the element has any classes
	  if (elementClasses.length) {
		// Loop through all the classes
		for (var j = 0; j < elementClasses.length; j++) {
		  var currentClass = elementClasses[j];
		  // Check if the class is already in the array
		  if (classes.indexOf(currentClass) === -1) {
			// If the class is not in the array, add it
			classes.push(currentClass);
		  }
		}
	  }
	}
	// Output the array of classes
	//console.log('canIncrease:',canIncrease);
	//console.log('canDecrease:',canDecrease);

	// Loop through all the classes and increase font size by 150%, but not exceeding 300%
	if (canDecrease){
		for (var i = 0; i < classes.length; i++) {
		  var elementsWithClass = document.getElementsByClassName(classes[i]);
		  // Loop through all elements with this class and increase font size
		  for (var j = 0; j < elementsWithClass.length; j++) {
			var currentElement = elementsWithClass[j];
			currentElement.style.fontSize = '';
			var currentFontSize = window.getComputedStyle(currentElement, null).getPropertyValue('font-size');
			var newFontSize = parseInt(currentFontSize) * 0.8;
			//console.log(newFontSize);
			
			//console.log('Decrease Font');
			
			currentElement.style.fontSize = newFontSize + 'px';
			
		  }
		}
		canIncrease = true;
		canDecrease = false;
	}
	
}
function retToZero(){
	console.log("Zero!");
}
function toggleBW() {
  const allElements = document.querySelectorAll('*');
  const htmlElements = Array.from(allElements).filter(element => {
    return element.tagName.toLowerCase() !== 'script' && element.tagName.toLowerCase() !== 'style';
  });

  htmlElements.forEach(element => {
    //const isDiv = true; //element.tagName === 'DIV' ;
    //console.log(element);
    //if (isDiv){

      //debugger;	
      // Check if background-color and color properties are set to black and white, respectively
      if (element.style.backgroundColor === 'rgb(0, 0, 0)' && element.style.color === 'rgb(255, 255, 255)') {
        element.style.backgroundColor = '';
        element.style.color = ''
      }
      else{
        element.style.backgroundColor = 'rgb(0, 0, 0)';
        element.style.color = 'rgb(255, 255, 255)';
      }
    //}
});
}





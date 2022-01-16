window.onclick = function(event) {
  if (!$(event.target).hasClass('dropbtn')) {
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
    }
  }
}

function addClassToRow(fieldName,formName){
	//console.log('15',nameOfClass,fieldName,formName);
	var formNameLabel = document.getElementById("form5503-name");  
	formNameLabel.textContent = formName;
	var allInputs = allInputElements(fieldName);
	//console.log(allInputs);
	
}

function allInputElements(fieldName){
      var inputArr = [];
      var reqrFHeb = "שדה נדרש";
	  var reqrFEng = "Required Field";

      var inputArr = document.querySelectorAll('input');
	  var inpCount= inputArr.length;
	  for(var i=0; i<inpCount;i++){
		  var inpElem = inputArr[i];
		  if (inpElem.id.toString().indexOf('$TextField') > 0){
			var fieldTitle = inpElem.title;
			if ((fieldTitle.indexOf(reqrFHeb) > 0 ) ||
				(fieldTitle.indexOf(reqrFEng) > 0 )){}
			else{
				//console.log(i,' : ',fieldTitle);
				var fieldsList = fieldName.split(',')
				
				setRowClasses(inpElem.id,'');
				for(var k=0;k < fieldsList.length;k++){
					var fieldEl = fieldsList[k].toLowerCase().trim();
					var fieldTitlLc = fieldTitle.toLowerCase().trim(); 
					if (fieldEl === fieldTitlLc){
						//console.log('Field Found: ',fieldTitlLc)
						setRowClasses(inpElem.id,'tofes-row-hide');
					}
				}
				
			}
		  }
	  }
	  /*
	  .forEach((el) => {
		if(!el.hidden && el.title ){
			if(!(el.title.toLowerCase().includes(reqrFEng) || 
			el.title.toLowerCase().includes(reqrFHeb))){
            const fieldRealName	= el.title.toLowerCase().replace(reqrFEng,"").replace(reqrFHeb,"").trim();		
		    if(el.id.includes("_x0") || el.id.toLowerCase().includes(fieldRealName)){
					//console.log(el);
					
					let tEl = {};
					tEl.ID = el.id;
					tEl.isRequired = false;
					tEl.Title = el.title.toLowerCase();
					if (tEl.Title.includes(reqrFEng)){
					  tEl.isRequired = true;
					  //console.log('128',tEl.Title);
					  tEl.Title = tEl.Title.replace(reqrFEng,"").trim();
					}
					if (tEl.Title.includes(reqrFHeb)){
					  tEl.isRequired = true;
					  //console.log('133',tEl.Title);
					  tEl.Title = tEl.Title.replace(reqrFHeb,"").trim();
					}        
					inputArr.push(tEl);
					
					//this.#inputElements.push(tEl);
					//console.log('input-1',el.title);
				}
			}
		}
      });
      return inputArr;
    } 
	*/
	return inputArr;
  }
function setRowClasses(inputID,nameOfClass){ 
 var srcRowField = document.getElementById(inputID);
 var parentEl = srcRowField.parentNode;
 var trElement = null;
 var maxRecurseLevel = 7;
 var isElementFound = false;
      while(true){
        if (parentEl instanceof HTMLTableRowElement){
          trElement = parentEl;
		  isElementFound = true;
          break;
        }
        //console.log(parentEl);
        //console.log(parentEl instanceof HTMLTableRowElement);
        parentEl = parentEl.parentNode;
        //debugger;
		maxRecurseLevel--;
		if (maxRecurseLevel === 0){
			break;
		}
    }
	if (isElementFound){ 	  
		trElement.className = "";
		if (nameOfClass){
			trElement.classList.add(nameOfClass);
		}
    }
        
}   

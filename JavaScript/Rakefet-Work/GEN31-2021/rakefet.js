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
      
      processControl('input','$TextField',fieldName);
      processControl('select','$DropDownChoice',fieldName);
      processControl('input','$BooleanField',fieldName);
      processControl('input','$DateTimeFieldDate',fieldName);
      processControl('input','$UrlFieldUrl',fieldName);

 	  
	
  }
function processControl(controlType,ControlText,fieldName){
	var reqrFHeb = "שדה נדרש";
	  var reqrFEng = "Required Field";	
      var selectArr = document.querySelectorAll(controlType);
	  var selCount= selectArr.length;

	  for(var i=0; i<selCount;i++){
		  var selElem = selectArr[i];
		  if (selElem.id.toString().indexOf(ControlText) > 0){
			var fieldTitle1 = selElem.title;
			if ((fieldTitle1.indexOf(reqrFHeb) > 0 ) ||
				(fieldTitle1.indexOf(reqrFEng) > 0 )){}
			else{
				//console.log(i,' : ',fieldTitle);
				var fieldsList1 = fieldName.split(',')
				
				setRowClasses(selElem.id,'');
				for(var k=0;k < fieldsList1.length;k++){
					var fieldEl1 = fieldsList1[k].toLowerCase().trim();
					var fieldTitlLc1 = fieldTitle1.toLowerCase().trim(); 
					if (fieldEl1 === fieldTitlLc1){
						//console.log('Field Found: ',fieldTitlLc)
						setRowClasses(selElem.id,'tofes-row-hide');
					}
				}
				
			}
		  }
	  }
	
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

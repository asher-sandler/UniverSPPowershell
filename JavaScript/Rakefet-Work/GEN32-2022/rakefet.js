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

function clearHide(formName){
	//var x=document.querySelectorAll("table > tbody > tr");
	var x=document.getElementsByTagName("tr");
	
	for(var i=0;i < x.length;i++){
		if ($(x[i]).hasClass('tofes-row-hide')){
			//console.log(i,'found');
			$(x[i]).removeClass('tofes-row-hide');
		}
		//x[i].className = "";
		//x[i].classList.remove('tofes-row-hide');
		//console.log(i, x[i].className);
		}
	if (formName){	
		var formNameLabel = document.getElementById("form5503-name");  
		formNameLabel.textContent = formName;
	}
	//console.log(x);	
}
function addClassToRow(fieldName,formName){
	//console.log('15',fieldName,formName);
	var formNameLabel = document.getElementById("form5503-name"); 
    //console.log(34,formNameLabel,formName);	
	formNameLabel.textContent = formName;
	var allInputs = allInputElements(fieldName);
	//console.log(allInputs);
	
}

function allInputElements(fieldName){
      clearHide();
      processControl('input','$TextField',fieldName);
      processControl('textarea','$TextField',fieldName);
      processControl('select','$DropDownChoice',fieldName);
      processControl('input','$BooleanField',fieldName);
      processControl('input','$DateTimeFieldDate',fieldName);
      processControl('input','$UrlFieldUrl',fieldName);
      processControl('table','$DateTimeFieldTopTable',fieldName);

 	  
	
  }
function processControl(controlType,ControlText,fieldName){
	var reqrFHeb = "שדה נדרש";
	  var reqrFEng = "Required Field";	
      var selectArr = document.querySelectorAll(controlType);
	  var selCount= selectArr.length;
      
	  for(var i=0; i<selCount;i++){
		  var selElem = selectArr[i];
		  if (selElem.id.toString().indexOf(ControlText) > 0){
			//console.log(60,selectArr);
			var fieldTitle1 = selElem.title;
			if (ControlText === '$UrlFieldUrl' || 
			ControlText === '$DateTimeFieldTopTable'){
			//	console.log("1111");
				fieldTitle1 = selElem.id;
			//	console.log("fieldTitle1",fieldTitle1);
			}
			if ((fieldTitle1.indexOf(reqrFHeb) > 0 ) ||
				(fieldTitle1.indexOf(reqrFEng) > 0 )){
					fieldTitle1 = fieldTitle1.replace(reqrFHeb,'').replace(reqrFEng,'')
			}
			//else{
				//console.log(i,' : ',fieldTitle);
				var fieldsList1 = fieldName.split(',')
				//console.log("fieldsList1",fieldsList1);
				setRowClasses(selElem.id,'');
				for(var k=0;k < fieldsList1.length;k++){
					var fieldEl1 = fieldsList1[k].toLowerCase().trim();
					var fieldTitlLc1 = fieldTitle1.toLowerCase().trim(); 
					if (ControlText === '$UrlFieldUrl' || 
						ControlText === '$DateTimeFieldTopTable'){
						//console.log("fieldTitlLc1",fieldTitlLc1);
						//console.log("indexof",fieldTitlLc1.indexOf(fieldEl1));
						if (fieldTitlLc1.indexOf('lastsubmit') > -1){
							//console.log("fieldTitle1",fieldTitle1);
							//debugger;
						}
						else{						
							if (fieldTitlLc1.indexOf(fieldEl1) > -1){
							//console.log("fieldTitle1",fieldTitle1);
							setRowClasses(selElem.id,'tofes-row-hide');
						
							}
						}
					}
					else{
						if (fieldEl1 === fieldTitlLc1){
						if (fieldTitlLc1.indexOf('lastsubmit') > -1){
							//console.log("fieldTitle1",fieldTitle1);
							//debugger;
						}
						else{
							
								//console.log('Field Found: ',fieldTitlLc)
								setRowClasses(selElem.id,'tofes-row-hide');
							}
						}
					}
				}
				
			//}
		  }
	  }
	
}
function setRowClasses(inputID,nameOfClass){ 
 var srcRowField = document.getElementById(inputID);
 //console.log(107,inputID);
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

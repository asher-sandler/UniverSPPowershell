/* When the user clicks on the button,
toggle between hiding and showing the dropdown content */
function pressdown5503(){
	
	var ddown5503 = document.getElementById("down5503"); //console.log('28',ddown5503);

	var currClasName = ddown5503.className;
	console.log('30', currClasName);
	var showClassName = "show";

	if (currClasName.includes(showClassName)) {
		ddown5503.className = "dropdown-content";
	} else {
		ddown5503.className = "dropdown-content " + showClassName;
	}
	console.log('40',ddown5503.className);
	console.log('41',document.getElementById("down5503"));
  //ddown5503.classList.toggle("show");
}

// Close the dropdown menu if the user clicks outside of it
window.onclick = function(event) {
  if (!event.target.matches('.dropbtn')) {
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
class htmlElements{

  
  static createDropDownMenu(arrUsers){
      
    let dEl = document.createElement('div');

    arrUsers.forEach((el) => {
        let dropDownEl = document.createElement('div');
        dropDownEl.textContent = el.user;
        dropDownEl.className = "div-link";
        dropDownEl.setAttribute('onclick',
              "htmlElements.addClassToRow('"+el.className+"','"+el.fields+"','"+el.formName+"')");
        dEl.append(dropDownEl);

    });

    return dEl;
  }
  



  // ================================================== //
  static addClassToRow(nameOfClass,fieldName,formName){

	const formNameLabel = document.getElementById("form5503-name");  
	formNameLabel.textContent = formName;

    const allInputs = allInputElements();
    //console.log('66',allInputs);
	
	

    allInputs.map((el) => {
      // clear all classes for row
	  if (el.Title){
		
			setRowClasses(el.ID,"");
		
	  }
        
    });
    
    const arrOfFields = fieldName.split(',');
	//console.log('arrOfFields',arrOfFields);
    for(let fieldItem of arrOfFields){

    
      const inputContolID = allInputs.find((el) => {
        
        return el.Title === fieldItem.toLowerCase()
      });

      //console.log('123',inputContolID);
    //debugger;
      if (inputContolID && inputContolID.ID){
		//setRowClasses(inputContolID.ID,""); // clear classes
        setRowClasses(inputContolID.ID,nameOfClass);
      }
    }
    // ----------------------------------------------------
    function setRowClasses(inputID,nameOfClass){
      const srcRowField = document.getElementById(inputID);
      //console.log(srcRowField);
      //debugger;
      let parentEl = srcRowField.parentNode;
      let trElement = null;
      
         
      let maxRecurseLevel = 7;
	  let isElementFound = false;
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
    // ----------------------------------------------------
    function allInputElements(){
      const inputArr = [];
      const reqrFHeb = "שדה נדרש";
	  const reqrFEng = "required field";

      document.querySelectorAll('input').forEach((el) => {
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
  }


}

const user1Fields = ["כוס מים","Field004","Field007"];
const user2Fields = ["Field001","Field004","Title"];
const user3Fields = ["Title","Field014","Field009",
					"Field001","Field002","Field003",
					"Field004","Field005","Field006",
					"Field007","Field008","Field010",
					"Field011","Field012","Field013","SHOP"];

const userActions = [{user:"חזרה למקור",className:"",fields:"",formName : ""},
  {user:"טופס1",className:"tofes-row-hide",fields:user1Fields,formName : "טופס 1 "},
{user:"טופס2",className:"tofes-row-hide",fields:user2Fields,formName : "טופס 2"},
{user:"טופס3",className:"tofes-row-hide",fields:user3Fields,formName : "טופס 3"}]


let dropDown = document.querySelector('#down5503');
dropDown.append(htmlElements.createDropDownMenu(userActions));

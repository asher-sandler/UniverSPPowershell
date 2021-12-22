/* When the user clicks on the button,
toggle between hiding and showing the dropdown content */
function myFunction() {
  document.getElementById("myDropdown").classList.toggle("show");
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
              "htmlElements.addClassToRow('"+el.className+"','"+el.fields+"')");
        dEl.append(dropDownEl);

    });

    return dEl;
  }

  static addCssStyle(){

    const htmlEl = new htmlElements();

    // Get HTML head element
    var head = document.getElementsByTagName('HEAD')[0]; 
      
    // Create new link Element
    var link = document.createElement('link');
    
    // set the attributes for link element 
    link.rel = 'stylesheet'; 
    
    link.type = 'text/css';
    
    link.href = 'FormCustomStyle.css'; 
    
    // Append link element to HTML head
    head.appendChild(link); 
    
  }

  // ================================================== //
  static addClassToRow(nameOfClass,fieldName){

    const allInputs = allInputElements();
    //console.log('66',allInputs);

    allInputs.map((el) => {
      // clear all classes for row
      setRowClasses(el.ID,"");
        
    });
    
    const arrOfFields = fieldName.split(',');
    for(let fieldItem of arrOfFields){

    
      const inputContolID = allInputs.find((el) => {
        
        return el.Title === fieldItem.toLowerCase()
      });

      //console.log('123',inputContolID);
    //debugger;
      if (inputContolID){
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
      
         
      
      while(true){
        if (parentEl instanceof HTMLTableRowElement){
          trElement = parentEl;
          break;
        }
        //console.log(parentEl);
        //console.log(parentEl instanceof HTMLTableRowElement);
        parentEl = parentEl.parentNode;
        //debugger;
      } 
      trElement.className = "";
      if (nameOfClass){
        trElement.classList.add(nameOfClass);
      }
        
    }   
    // ----------------------------------------------------
    function allInputElements(){
      const inputArr = [];
      document.querySelectorAll('input').forEach((el) => {
        const reqrFHeb = "שדה נדרש";
        const reqrFEng = "required field";
        
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
      });
      return inputArr;
    } 
  }


}
class mapUser{
  #userID = [];
  constructor(item){
    if (item){
      this.#userID.push(item);
    }
  }

  pushEl(item) {
    this.#userID.push(item);
  }

  getEl(){
    return this.#userID;
  }

  getUniqueUsers(){
    const users = this.#userID.map((el,idx) => {
        return el[1];
    });
    const resultArr = [];
   
    users.forEach((el) => {
      el.forEach((nEl) => {
        resultArr.push(nEl);
      })
    } );

    const retArr = resultArr.filter((v, i, a) => a.indexOf(v) === i).sort();
    return retArr;
  }
}

htmlElements.addCssStyle();  
//const mapUsersToId = new mapUser();
const user1Fields = ["כוס מים","Field004","כותרת"];
const user2Fields = ["Field001","כותרת"];
const user3Fields = ["Title","Field004","Field014","כותרת"];

const userActions = [{user:"Return to Origin",className:"",fields:""},
  {user:"user1",className:"tofes-row-indigo",fields:user1Fields},
{user:"user2",className:"tofes-row-red",fields:user2Fields},
{user:"user3",className:"tofes-row-coral",fields:user3Fields}]

//{User:"user3",Action:'htmlElements.addClassToRow("tofes-row-coral","Field001")'},]

/*
mapUsersToId.pushEl(["",["user1","user2"]]);
mapUsersToId.pushEl(['',["user1","user3"]]);
mapUsersToId.pushEl(["",["user2","user1","user3"]]);
mapUsersToId.pushEl(["",["user2","user3"]]);
*/
//console.log(mapUsersToId.getEl());

//console.log('getUniqueN',mapUsersToId.getUniqueUsers());

let dropDown = document.querySelector('#myDropdown');
dropDown.append(htmlElements.createDropDownMenu(userActions));



// const fieldControlId = 'Title_fa564e0f-0c70-4ab9-b863-0177e6ddd247_$TextField';
// const filed2Id = "Field001_1e0e6d49-cc66-49ba-a55f-53feeab74e05_$TextField";

// const asherDiv = document.querySelector('#ashrS-InsertedField');

// //let tempVar = mapUsersToId.map((menu,idx,mapArray) => {return mapArray[idx]?.[100]});
// //console.log(tempVar);

// const sourceField = document.getElementById(fieldControlId);


// const addedField = document.createElement('input');

// addedField.type = sourceField.type;
// addedField.value = sourceField.value;
// addedField.maxLength = sourceField.maxLength;
// addedField.title = sourceField.title;
// addedField.style = sourceField.style;
// addedField.className = sourceField.className;

// sourceField.remove();
// addedField.id=fieldControlId;
// //console.log('sourceField: ',sourceField.value);
// //console.log('addedField: ',addedField);


// asherDiv.append(addedField);



// const srcRowField = document.getElementById(filed2Id);

// var parentEl = srcRowField.parentNode;

// var trElement = null;

// console.log("111");


// while(true){
//   if (parentEl instanceof HTMLTableRowElement){
//     trElement = parentEl;
//     break;
//   }
//   //console.log(parentEl);
//   //console.log(parentEl instanceof HTMLTableRowElement);
//   parentEl = parentEl.parentNode;
//   //debugger;
// }

// parentEl.classList.add('tofes-row-hide');
// console.log(parentEl);
// //const trName = document.createElement('tr').constructor.name;
// console.log(trElement);
console.log('Done');








  
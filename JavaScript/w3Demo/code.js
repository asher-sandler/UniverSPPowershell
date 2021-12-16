function openCity(cityName) {
    var i;
    var x = document.getElementsByClassName("city");
    for (i = 0; i < x.length; i++) {
      x[i].style.display = "none";  
    }
    document.getElementById(cityName).style.display = "block";  
  }

const capitalIsrael = document.createElement('div');
capitalIsrael.className = 'w3-container city';
capitalIsrael.id = 'Jerusalem';
capitalIsrael.innerHTML = '<h2>Jerusalem</h2><p>Jerusalem is the capital city of Israel.</p>';
capitalIsrael.style = 'display:none;'

const capitals =document.querySelector('#Capitals');
capitals.append(capitalIsrael);


const buttonJerusalem = document.createElement('button');
buttonJerusalem.className = 'w3-bar-item w3-button';
buttonJerusalem.textContent='Jerusalem';
buttonJerusalem.setAttribute('onclick',"openCity('Jerusalem')");

const buttonsNav = document.querySelector('.w3-bar');

buttonsNav.append(buttonJerusalem);

const asherText = document.createElement('p');
asherText.textContent = "bla-bla";

const asherDiv = document.querySelector('#ashrS-InsertedField');

asherDiv.append(asherText);

const fieldControlId = 'Title_fa564e0f-0c70-4ab9-b863-0177e6ddd247_$TextField';
const sourceField = document.getElementById(fieldControlId);


const addedField = document.createElement('input');

addedField.type = sourceField.type;
addedField.value = sourceField.value;
addedField.maxLength = sourceField.maxLength;
addedField.title = sourceField.title;
addedField.style = sourceField.style;
addedField.className = sourceField.className;

sourceField.remove();
addedField.id=fieldControlId;
//console.log('sourceField: ',sourceField.value);
//console.log('addedField: ',addedField);


asherDiv.append(addedField);







  
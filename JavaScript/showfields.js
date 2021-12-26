"use strict";

function _createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }

/* When the user clicks on the button,
toggle between hiding and showing the dropdown content */
function pressdown5503() {
  var ddown5503 = document.getElementById("down5503"); //console.log('28',ddown5503);

  var currClasName = ddown5503.className;
  console.log('30', currClasName);
  var showClassName = "show";

  if (currClasName.includes(showClassName)) {
    ddown5503.className = "dropdown-content";
  } else {
    ddown5503.className = "dropdown-content " + showClassName;
  }

  console.log('40', ddown5503.className);
  console.log('41', document.getElementById("down5503")); //ddown5503.classList.toggle("show");
} // Close the dropdown menu if the user clicks outside of it


window.onclick = function (event) {
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
};

var htmlElements = /*#__PURE__*/function () {
  function htmlElements() {
    _classCallCheck(this, htmlElements);
  }

  _createClass(htmlElements, null, [{
    key: "createDropDownMenu",
    value: function createDropDownMenu(arrUsers) {
      var dEl = document.createElement('div');
      arrUsers.forEach(function (el) {
        var dropDownEl = document.createElement('div');
        dropDownEl.textContent = el.user;
        dropDownEl.className = "div-link";
        dropDownEl.setAttribute('onclick', "htmlElements.addClassToRow('" + el.className + "','" + el.fields + "','" + el.formName + "')");
        dEl.append(dropDownEl);
      });
      return dEl;
    } // ================================================== //

  }, {
    key: "addClassToRow",
    value: function addClassToRow(nameOfClass, fieldName, formName) {
      var formNameLabel = document.getElementById("form5503-name");
      formNameLabel.textContent = formName;
      var allInputs = allInputElements(); //console.log('66',allInputs);

      allInputs.map(function (el) {
        // clear all classes for row
        if (el.Title) {
          setRowClasses(el.ID, "");
        }
      });
      var arrOfFields = fieldName.split(','); //console.log('arrOfFields',arrOfFields);

      var _iterator = _createForOfIteratorHelper(arrOfFields),
          _step;

      try {
        var _loop = function _loop() {
          var fieldItem = _step.value;
          var inputContolID = allInputs.find(function (el) {
            return el.Title === fieldItem.toLowerCase();
          }); //console.log('123',inputContolID);
          //debugger;

          if (inputContolID && inputContolID.ID) {
            //setRowClasses(inputContolID.ID,""); // clear classes
            setRowClasses(inputContolID.ID, nameOfClass);
          }
        };

        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          _loop();
        } // ----------------------------------------------------

      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }

      function setRowClasses(inputID, nameOfClass) {
        var srcRowField = document.getElementById(inputID); //console.log(srcRowField);
        //debugger;

        var parentEl = srcRowField.parentNode;
        var trElement = null;
        var maxRecurseLevel = 7;
        var isElementFound = false;

        while (true) {
          if (parentEl instanceof HTMLTableRowElement) {
            trElement = parentEl;
            isElementFound = true;
            break;
          } //console.log(parentEl);
          //console.log(parentEl instanceof HTMLTableRowElement);


          parentEl = parentEl.parentNode; //debugger;

          maxRecurseLevel--;

          if (maxRecurseLevel === 0) {
            break;
          }
        }

        if (isElementFound) {
          trElement.className = "";

          if (nameOfClass) {
            trElement.classList.add(nameOfClass);
          }
        }
      } // ----------------------------------------------------


      function allInputElements() {
        var inputArr = [];
        var reqrFHeb = "שדה נדרש";
        var reqrFEng = "required field";
        document.querySelectorAll('input').forEach(function (el) {
          if (!el.hidden && el.title) {
            if (!(el.title.toLowerCase().includes(reqrFEng) || el.title.toLowerCase().includes(reqrFHeb))) {
              var fieldRealName = el.title.toLowerCase().replace(reqrFEng, "").replace(reqrFHeb, "").trim();

              if (el.id.includes("_x0") || el.id.toLowerCase().includes(fieldRealName)) {
                //console.log(el);
                var tEl = {};
                tEl.ID = el.id;
                tEl.isRequired = false;
                tEl.Title = el.title.toLowerCase();

                if (tEl.Title.includes(reqrFEng)) {
                  tEl.isRequired = true; //console.log('128',tEl.Title);

                  tEl.Title = tEl.Title.replace(reqrFEng, "").trim();
                }

                if (tEl.Title.includes(reqrFHeb)) {
                  tEl.isRequired = true; //console.log('133',tEl.Title);

                  tEl.Title = tEl.Title.replace(reqrFHeb, "").trim();
                }

                inputArr.push(tEl); //this.#inputElements.push(tEl);
                //console.log('input-1',el.title);
              }
            }
          }
        });
        return inputArr;
      }
    }
  }]);

  return htmlElements;
}();

var user1Fields = ["כוס מים", "Field004", "Field007"];
var user2Fields = ["Field001", "Field004", "Title"];
var user3Fields = ["Title", "Field014", "Field009", "Field001", "Field002", "Field003", "Field004", "Field005", "Field006", "Field007", "Field008", "Field010", "Field011", "Field012", "Field013", "SHOP"];
var userActions = [{
  user: "חזרה למקור",
  className: "",
  fields: "",
  formName: ""
}, {
  user: "טופס1",
  className: "tofes-row-hide",
  fields: user1Fields,
  formName: "טופס 1 "
}, {
  user: "טופס2",
  className: "tofes-row-hide",
  fields: user2Fields,
  formName: "טופס 2"
}, {
  user: "טופס3",
  className: "tofes-row-hide",
  fields: user3Fields,
  formName: "טופס 3"
}];
var dropDown = document.querySelector('#down5503');
dropDown.append(htmlElements.createDropDownMenu(userActions));
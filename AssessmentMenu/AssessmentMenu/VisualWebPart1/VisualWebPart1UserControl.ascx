<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="VisualWebPart1UserControl.ascx.cs" Inherits="AssessmentMenu.VisualWebPart1.VisualWebPart1UserControl" %>
<style>
.sidenav {
    height: 100%; /* 100% Full-height */
    width: 0; /* 0 width - change this with JavaScript */
    position: fixed; /* Stay in place */
    z-index: 1; /* Stay on top */
    top: 0; /* Stay at the top */
    background-color: #111; /* Black*/
    overflow-x: hidden; /* Disable horizontal scroll */
    padding-top: 60px; /* Place content 60px from the top */
    transition: 0.5s; /* 0.5 second transition effect to slide in the sidenav */
  }
  .panel-left {
    left: 0;
    
  }
  .panel-right {
    right: 0; 
  }
  .panel-left a{
    left: 0; 
  }
  .panel-right a{
    right: 0; 
  }
  
  /* The navigation menu links */
  .sidenav a {
    padding: 8px 8px 8px 32px;
    text-decoration: none;
    font-size: 25px;
    color: #818181;
    display: block;
    transition: 0.3s;
  }
  .toolbar-toggle{
    width: 50px;
  }
  .toolbar-icon{
    width: 50px;
	position: fixed;
    top: 40px;
  }
    .panel-show {
    width:250px;
    }

 
  
  /* When you mouse over the navigation links, change their color */
  .sidenav a:hover {
    color: #f1f1f1;
  }
    .assets-dir-rl {
    -webkit-transform: scaleX(-1);
    transform: scaleX(-1);
    }



  
  /* Position and style the close button (top right corner) */
  .sidenav .closebtn {
    position: absolute;
    top: 0;
    right: 25px;
    font-size: 36px;
    margin-left: 50px;
  }
  
  /* Style page content - use this if you want to push the page content to the right when you open the side navigation */
  #main {
    transition: margin-left .5s;
    padding: 20px;
  }
  
  /* On smaller screens, where height is less than 450px, change the style of the sidenav (less padding and a smaller font size) */
  @media screen and (max-height: 450px) {
    .sidenav {padding-top: 15px;}
    .sidenav a {font-size: 18px;}
  }
</style>

</div>

<div id="mySidenav" class="sidenav" runat="server" >
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav();">&times;</a>
        <a href="#"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="1em" viewBox="0 0 448 448" tabindex="-1"><path fill="currentColor" d="M224 344v-48c0-4.5-3.5-8-8-8h-48c-4.5 0-8 3.5-8 8v48c0 4.5 3.5 8 8 8h48c4.5 0 8-3.5 8-8zM288 176c0-45.75-48-80-91-80-40.75 0-71.25 17.5-92.75 53.25-2.25 3.5-1.25 8 2 10.5l33 25c1.25 1 3 1.5 4.75 1.5 2.25 0 4.75-1 6.25-3 11.75-15 16.75-19.5 21.5-23 4.25-3 12.5-6 21.5-6 16 0 30.75 10.25 30.75 21.25 0 13-6.75 19.5-22 26.5-17.75 8-42 28.75-42 53v9c0 4.5 3.5 8 8 8h48c4.5 0 8-3.5 8-8v0c0-5.75 7.25-18 19-24.75 19-10.75 45-25.25 45-63.25zM384 224c0 106-86 192-192 192s-192-86-192-192 86-192 192-192 192 86 192 192z" tabindex="-1"></path></svg>About</a>
        <a href="#" onclick='toggleBW();'><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="1em" viewBox="0 0 448 448" tabindex="-1"><path fill="currentColor" d="M192 360v-272c-75 0-136 61-136 136s61 136 136 136zM384 224c0 106-86 192-192 192s-192-86-192-192 86-192 192-192 192 86 192 192z" "="" tabindex="-1"></path></svg>Toggle B/W</a>
       <% if (IS_LR_AVAILABLE)
           { %>
        <a href="#" onclick='toggleLR();'><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-left-right" viewBox="0 0 16 16"> <path fill-rule="evenodd" d="M1 11.5a.5.5 0 0 0 .5.5h11.793l-3.147 3.146a.5.5 0 0 0 .708.708l4-4a.5.5 0 0 0 0-.708l-4-4a.5.5 0 0 0-.708.708L13.293 11H1.5a.5.5 0 0 0-.5.5zm14-7a.5.5 0 0 1-.5.5H2.707l3.147 3.146a.5.5 0 1 1-.708.708l-4-4a.5.5 0 0 1 0-.708l4-4a.5.5 0 1 1 .708.708L2.707 4H14.5a.5.5 0 0 1 .5.5z"/> </svg>Toggle Left/Right</a>
      <%} %>
        <a href="#" onclick='incrFont()'><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="1em" viewBox="0 0 448 448" tabindex="-1"><path fill="currentColor" d="M256 200v16c0 4.25-3.75 8-8 8h-56v56c0 4.25-3.75 8-8 8h-16c-4.25 0-8-3.75-8-8v-56h-56c-4.25 0-8-3.75-8-8v-16c0-4.25 3.75-8 8-8h56v-56c0-4.25 3.75-8 8-8h16c4.25 0 8 3.75 8 8v56h56c4.25 0 8 3.75 8 8zM288 208c0-61.75-50.25-112-112-112s-112 50.25-112 112 50.25 112 112 112 112-50.25 112-112zM416 416c0 17.75-14.25 32-32 32-8.5 0-16.75-3.5-22.5-9.5l-85.75-85.5c-29.25 20.25-64.25 31-99.75 31-97.25 0-176-78.75-176-176s78.75-176 176-176 176 78.75 176 176c0 35.5-10.75 70.5-31 99.75l85.75 85.75c5.75 5.75 9.25 14 9.25 22.5z" "="" tabindex="-1"></path></svg>Increase Font</a>
        <a href="#" onclick='decrFont()'><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="1em" viewBox="0 0 448 448" tabindex="-1"><path fill="currentColor" d="M256 200v16c0 4.25-3.75 8-8 8h-144c-4.25 0-8-3.75-8-8v-16c0-4.25 3.75-8 8-8h144c4.25 0 8 3.75 8 8zM288 208c0-61.75-50.25-112-112-112s-112 50.25-112 112 50.25 112 112 112 112-50.25 112-112zM416 416c0 17.75-14.25 32-32 32-8.5 0-16.75-3.5-22.5-9.5l-85.75-85.5c-29.25 20.25-64.25 31-99.75 31-97.25 0-176-78.75-176-176s78.75-176 176-176 176 78.75 176 176c0 35.5-10.75 70.5-31 99.75l85.75 85.75c5.75 5.75 9.25 14 9.25 22.5z" tabindex="-1"></path></svg>Decrease Font</a>
        <a href="#" onclick='retToZero()'><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="1em" viewBox="0 0 448 448" tabindex="-1"><path fill="currentColor" d="M384 224c0 105.75-86.25 192-192 192-57.25 0-111.25-25.25-147.75-69.25-2.5-3.25-2.25-8 0.5-10.75l34.25-34.5c1.75-1.5 4-2.25 6.25-2.25 2.25 0.25 4.5 1.25 5.75 3 24.5 31.75 61.25 49.75 101 49.75 70.5 0 128-57.5 128-128s-57.5-128-128-128c-32.75 0-63.75 12.5-87 34.25l34.25 34.5c4.75 4.5 6 11.5 3.5 17.25-2.5 6-8.25 10-14.75 10h-112c-8.75 0-16-7.25-16-16v-112c0-6.5 4-12.25 10-14.75 5.75-2.5 12.75-1.25 17.25 3.5l32.5 32.25c35.25-33.25 83-53 132.25-53 105.75 0 192 86.25 192 192z" tabindex="-1"></path></svg>Return to origin</a>

</div>
      
      <!-- Use any element to open the sidenav -->
             
        <div class="toolbar-toggle" id="accessMain">
            <a class="pojo-a11y-toolbar-link pojo-a11y-toolbar-toggle-link" href="javascript:void(0);" onclick="openNav()" title="Accessibility tools" role="link" tabindex="0">
            
            <svg xmlns="http://www.w3.org/2000/svg" id="tBarIcon"  class="toolbar-icon  <%=POSITION_CLASS %> <%=ASSEST_DIR %>" viewBox="0 0 100 100" fill="currentColor" width="1em" tabindex="-1" >
                <g tabindex="-1"><path d="M60.4,78.9c-2.2,4.1-5.3,7.4-9.2,9.8c-4,2.4-8.3,3.6-13,3.6c-6.9,0-12.8-2.4-17.7-7.3c-4.9-4.9-7.3-10.8-7.3-17.7c0-5,1.4-9.5,4.1-13.7c2.7-4.2,6.4-7.2,10.9-9.2l-0.9-7.3c-6.3,2.3-11.4,6.2-15.3,11.8C7.9,54.4,6,60.6,6,67.3c0,5.8,1.4,11.2,4.3,16.1s6.8,8.8,11.7,11.7c4.9,2.9,10.3,4.3,16.1,4.3c7,0,13.3-2.1,18.9-6.2c5.7-4.1,9.6-9.5,11.7-16.2l-5.7-11.4C63.5,70.4,62.5,74.8,60.4,78.9z" tabindex="-1"></path><path d="M93.8,71.3l-11.1,5.5L70,51.4c-0.6-1.3-1.7-2-3.2-2H41.3l-0.9-7.2h22.7v-7.2H39.6L37.5,19c2.5,0.3,4.8-0.5,6.7-2.3c1.9-1.8,2.9-4,2.9-6.6c0-2.5-0.9-4.6-2.6-6.3c-1.8-1.8-3.9-2.6-6.3-2.6c-2,0-3.8,0.6-5.4,1.8c-1.6,1.2-2.7,2.7-3.2,4.6c-0.3,1-0.4,1.8-0.3,2.3l5.4,43.5c0.1,0.9,0.5,1.6,1.2,2.3c0.7,0.6,1.5,0.9,2.4,0.9h26.4l13.4,26.7c0.6,1.3,1.7,2,3.2,2c0.6,0,1.1-0.1,1.6-0.4L97,77.7L93.8,71.3z" tabindex="-1"></path></g>					</svg>
            </a>
        </div>
       
<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
  <symbol id="check" viewBox="0 0 16 16">
    <title>Check</title>
    <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"/>
  </symbol>
</svg>

<%--<asp:Label ID="menuPosition" runat="server"></asp:Label>--%>
<%--<asp:Label ID="showElClass" runat="server"></asp:Label>--%>
<%--<div>IS_LEFT_POSITION:<p><%=POSITION_CLASS %></p>--%>

<script>
    var canIncrease = true;
    var canDecrease = true;
    var classes = [];
    var elements = document.getElementsByTagName('*');


    /* Set the width of the side navigation to 250px */
    function openNav() {
        //console.log("Open Nav");
        var qSelID = '#<%=mySidenav.ClientID%>';
        var el = document.querySelector(qSelID);
        el.classList.add('panel-show');
        //console.log('333', el.classList);

    }

    /* Set the width of the side navigation to 0 */
    function closeNav() {
        //console.log("Close Nav");
        var qSelID = '#<%=mySidenav.ClientID%>';
        var el = document.querySelector(qSelID);
        //console.log('666', el.classList);
        el.classList.remove('panel-show');
        //console.log('777', el.classList);
        // el.style.width = "0px";
        //document.getElementById("container").style.marginLeft = "0";
    }

    function toggleLR() {
        var qSelID = '#<%=mySidenav.ClientID%>';
        var el = document.querySelector(qSelID);
        var mainEl = document.querySelector("#tBarIcon");
        const toggleClassName = "panel-right";

        var clList = el.classList;
        //console.log('098', mainEl.classList);
        if (clList.contains(toggleClassName)) {
            mainEl.classList.remove(toggleClassName);
            mainEl.classList.remove('assets-dir-rl');
            mainEl.classList.add('panel-left');

            el.classList.remove(toggleClassName);
            el.classList.add('panel-left');
        }
        else {
            mainEl.classList.remove('panel-left');
            mainEl.classList.add(toggleClassName);
            mainEl.classList.add('assets-dir-rl');
            el.classList.remove('panel-left');
            el.classList.add(toggleClassName);
        }
        //console.log('abc', mainEl.classList);
    }
    function incrFont() {

        // Get all the elements on the page

        // Define an empty array to store the classes
        getClasses();
        // Loop through all the elements
  
        // Output the array of classes
        //console.log('canIncrease:',canIncrease);
        //console.log('canDecrease:',canDecrease);

        // Loop through all the classes and increase font size by 150%, but not exceeding 300%
        if (canIncrease) {
            fontsClear();
            for (var i = 0; i < classes.length; i++) {
                var elementsWithClass = document.getElementsByClassName(classes[i]);
                // Loop through all elements with this class and increase font size
                for (var j = 0; j < elementsWithClass.length; j++) {
                    var currentElement = elementsWithClass[j];
 
                    var currentFontSize = window.getComputedStyle(currentElement, null).getPropertyValue('font-size');
                    var newFontSize = parseFloat(currentFontSize) * 1.1;
                    //console.log(newFontSize);

                    //console.log('Increase Font');
                    currentElement.style.fontSize = newFontSize + 'px';

                }
            }
            canIncrease = false;
            canDecrease = true;
        }


    }

    function fontsClear() {
        for (var i = 0; i < classes.length; i++) {
            var elementsWithClass = document.getElementsByClassName(classes[i]);
            // Loop through all elements with this class and increase font size
            for (var j = 0; j < elementsWithClass.length; j++) {
                var currentElement = elementsWithClass[j];
                currentElement.style.fontSize = '';
            }
        }
    }

    function getClasses() {
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
    }

    function decrFont() {
        //console.log('Decrease Font');
        // Get all the elements on the page
        //var elements = document.getElementsByTagName('*');

        // Define an empty array to store the classes
        
        getClasses();
        // Loop through all the elements
  
        // Output the array of classes
        //console.log('canIncrease:',canIncrease);
        //console.log('canDecrease:',canDecrease);

        // Loop through all the classes and increase font size by 150%, but not exceeding 300%
        if (canDecrease) {
            fontsClear();
            for (var i = 0; i < classes.length; i++) {
                var elementsWithClass = document.getElementsByClassName(classes[i]);
                // Loop through all elements with this class and increase font size
                for (var j = 0; j < elementsWithClass.length; j++) {
                    var currentElement = elementsWithClass[j];
                    //currentElement.style.fontSize = '';
                    var currentFontSize = window.getComputedStyle(currentElement, null).getPropertyValue('font-size');
                    //console.log(classes[i]);
                    //console.log(currentFontSize);
                    
                    var newFontSize = parseFloat(currentFontSize) * 0.95;
                    //console.log(newFontSize);
                    //console.log(newFontSize);

                    //console.log('Decrease Font');

                    currentElement.style.fontSize = newFontSize + 'px';

                }
            }
            canIncrease = true;
            canDecrease = false;
        }

    }
    function retToZero() {
        //console.log("Zero!");
        toggleBW(true);
        fontsClear();
        canIncrease = true;
        canDecrease = true;
        var mainEl = document.querySelector("#tBarIcon");
        var qSelID = '#<%=mySidenav.ClientID%>';
        var el = document.querySelector(qSelID);

        mainEl.classList.remove('panel-left');
        mainEl.classList.remove('panel-right');
        el.classList.remove('panel-left');
        el.classList.remove('panel-right');
        el.classList.add('<%=POSITION_CLASS%>');
        mainEl.classList.remove('assets-dir-rl');

        <%if (!String.IsNullOrEmpty(ASSEST_DIR))
          {%>
            mainEl.classList.add('<%=ASSEST_DIR%>');
        <%}  %>
        mainEl.classList.add('<%=POSITION_CLASS%>');
        closeNav();

    }
    function toggleBW(isReset) {
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
            if (isReset || (element.style.backgroundColor === 'rgb(0, 0, 0)' && element.style.color === 'rgb(255, 255, 255)')) {
                element.style.backgroundColor = '';
                element.style.color = ''
            }
            else {
                element.style.backgroundColor = 'rgb(0, 0, 0)';
                element.style.color = 'rgb(255, 255, 255)';
            }
            //}
        });
    }





</script>



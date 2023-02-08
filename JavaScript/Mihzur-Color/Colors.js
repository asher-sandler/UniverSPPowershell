<script type="text/javascript">

SPClientTemplates.TemplateManager.RegisterTemplateOverrides({
  OnPostRender: function(ctx) {
    var rows = ctx.ListData.Row;
    for (var i=0;i<rows.length;i++)
    {
	/*
		0 - חדש
		1 - בביצוע
		2 - ארכיון בוצע
		3 - מתבצע ניקוי לאחר ארכוב
		4 - ניקוי לאחר ארכוב בוצע
		5 - עדכון לאחר ניקוי
		6 - ממתין לבדיקה פנימית
		7 - ממתין למזמין
		8 - ממתין לעלייה לאוויר
		9 - טופל
		99 - לא עולה לאוויר

	*/
	  var sts = -1;
	  var sts1 = -1;
      if (rows[i]["status"] == "0 - חדש"){
		 var sts = 0; 
	  }
      if (rows[i]["status"] == "1.1 - ארכיון תוכנן"){
		 var sts = 11; 
	  }
     if (rows[i]["status"] == "1 - בביצוע"){
		 var sts = 1; 
	  }
      if (rows[i]["status"] == "2 - ארכיון בוצע"){
		 var sts = 2; 
	  }
      if (rows[i]["status"] == "3 - מתבצע ניקוי לאחר ארכוב"){
		 var sts = 3; 
	  }
      if (rows[i]["status"] == "4 - ניקוי לאחר ארכוב בוצע"){
		 var sts = 4; 
	  }
      if (rows[i]["status"] == "4 - ניקוי לאחר ארכוב בוצע"){
		 var sts = 4; 
	  }
      if (rows[i]["status"] == "5 - עדכון לאחר ניקוי"){
		 var sts = 5; 
	  }
      if (rows[i]["status"] == "6 - ממתין לבדיקה פנימית"){
		 var sts = 6; 
	  }
      if (rows[i]["status"] == "7 - ממתין למזמין"){
		 var sts = 7; 
	  }
      if (rows[i]["status"] == "8 - ממתין לעלייה לאוויר"){
		 var sts = 8; 
	  }
      if (rows[i]["status"] == "9 - טופל"){
		 var sts = 9; 
	  }
      if (rows[i]["status"] == "99 - לא עולה לאוויר"){
		 var sts = 99; 
	  }
      if (rows[i]["SiteCleaned"] == "כן"){
		 var sts1 = 4; 
	  }
       if (rows[i]["SiteCleaned"] == "לא"){
		 var sts1 = 9; 
	  }
     if (sts1 == 4)
      {
       var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
		//console.log(rowElementId);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "PaleGreen";
		tr.style.background = "linear-gradient(180deg,#39b54a,#34aa44)";
        tr.style.fontWeight="bold";
		var children = tr.children;
        for(var i=0; i<children.length; i++){
            var child = children[i];
            child.style.color = "yellow";
			var a = child.getElementsByTagName('a');
			for (var k = 0; k < a.length; k++) {
				a[k].style.color = "white";
			}	
        }
		  
	  }
     if (sts1 == 9)
      {
         var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "PaleVioletRed";
        tr.style.background = "linear-gradient(180deg,#fd9a18,#f16911)";
        tr.style.borderColor = "#f16911";
		var children = tr.children;
        for(var i=0; i<children.length; i++){
            var child = children[i];
            child.style.color = "white";
			var a = child.getElementsByTagName('a');
			for (var k = 0; k < a.length; k++) {
				a[k].style.color = "white";
			}	
        }
		  
	  }
      if (sts == 0)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "PaleTurquoise";
      }     
     if (sts == 11)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
		//console.log(rowElementId);
        var tr = document.getElementById(rowElementId);
        //tr.style.backgroundColor = "linear-gradient(180deg,#fd9a18,#f16911);";
        tr.style.backgroundColor = "#886ce6";
        tr.style.background = "linear-gradient(180deg,#fd9a18,#f16911)";
        tr.style.borderColor = "#f16911";
		var children = tr.children;
        for(var i=0; i<children.length; i++){
            var child = children[i];
            child.style.color = "white";
			var a = child.getElementsByTagName('a');
			for (var k = 0; k < a.length; k++) {
				a[k].style.color = "white";
			}	
        }
		//console.log(tr);
      }     
	  if (sts == 1)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "#ffde24";
      }	  

	  if (sts == 2)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "#ffbdde";
      }
	  if (sts == 3)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "Bisque";
      }
	  if (sts == 4)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
		//console.log(rowElementId);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "PaleGreen";
        tr.style.fontWeight="bold";
		/*
		const img552803 = document.createElement("img");
		img552803.src = "https://picsum.photos/200/301";
		tr.appendChild(img552803);
		*/
      }
	  if (sts == 5)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "DarkKhaki";
      }
	  if (sts == 6)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "DeepSkyBlue";
      }
	  if (sts == 7)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "Gainsboro";
      }
	  if (sts == 8)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "LightCyan";
      }
	  if (sts == 9)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "PaleVioletRed";
      }
	  if (sts == 99)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "SeaShell";
      }
	  
    }
  }
});
</script>
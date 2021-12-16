<script type="text/javascript">
SPClientTemplates.TemplateManager.RegisterTemplateOverrides({
  Templates: {
    Footer: function(ctx) {
      return "Hello world from " + ctx.ListTitle + "!";
    }
  }
});
SPClientTemplates.TemplateManager.RegisterTemplateOverrides({
  OnPostRender: function(ctx) {
    var rows = ctx.ListData.Row;
    for (var i=0;i<rows.length;i++)
    {
      var isShop1 = rows[i]["Shop"] == "Shop 1";
      var isShop2 = rows[i]["Shop"] == "Shop 2";
      var isShop3 = rows[i]["Shop"] == "Shop 3";
      if (isShop1)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "#ada";
      }     
	  if (isShop2)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "#ffde24";
      }	  
	  if (isShop3)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "#ffbdde";
      }
    }
  }
});
</script>
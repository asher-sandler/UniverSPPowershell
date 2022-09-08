<script type="text/javascript">

SPClientTemplates.TemplateManager.RegisterTemplateOverrides({
  OnPostRender: function(ctx) {
    var rows = ctx.ListData.Row;
    for (var i=0;i<rows.length;i++)
    {
	
      var exportF = rows[i]["Export_Files"] == 'כן';
     
      if (exportF)
      {
        var rowElementId = GenerateIIDForListItem(ctx, rows[i]);
        var tr = document.getElementById(rowElementId);
        tr.style.backgroundColor = "#eaeaea";
      }     
	 
    }
  }
});
</script>
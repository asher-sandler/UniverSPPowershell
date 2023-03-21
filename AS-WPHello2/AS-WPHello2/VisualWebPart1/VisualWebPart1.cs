using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace AS_WPHello2.VisualWebPart1
{
    [ToolboxItemAttribute(false)]
    public class VisualWebPart1 : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private const string _ascxPath = @"~/_CONTROLTEMPLATES/15/AS_WPHello2/VisualWebPart1/VisualWebPart1UserControl.ascx";
        [Personalizable(PersonalizationScope.Shared)]
        [WebBrowsable(true)]
        [Category("AS")]
        [WebDisplayName("Category")]
        public string Category { get; set; }

        [Personalizable(PersonalizationScope.Shared)]
        [WebBrowsable(true)]
        [Category("AS")]
        [WebDisplayName("Year")]
        public int Year { get; set; }

        public VisualWebPart1()
        {
            if (Category == null) { Category = "Nasi"; }
            if (Year == 0) { Year = 2046; }
        }
        /*
        protected void Page_Load(object sender, EventArgs e)
        {
            lblCategory.Text = Category;
            lblYear.Text = Year.ToString();
        }
        */
        protected override void CreateChildControls()
        {
            Control control =(VisualWebPart1UserControl) Page.LoadControl(_ascxPath);
            //ntrol. = Category;
            Controls.Add(control);
        }
    }
}

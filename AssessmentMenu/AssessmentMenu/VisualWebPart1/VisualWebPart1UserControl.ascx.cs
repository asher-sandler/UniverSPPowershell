using Microsoft.SharePoint;
using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace AssessmentMenu.VisualWebPart1
{
    public partial class VisualWebPart1UserControl : UserControl
    {
        public VisualWebPart1 _webpart { get; set; }
        public bool IS_LR_AVAILABLE { get; set; }
        public string POSITION_CLASS { get; set; }
        public string ASSEST_DIR { get; set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }
            SPSecurity.RunWithElevatedPrivileges(delegate ()
            {

                ASWP_Start();
            });

        }
        private void ASWP_Start()
        {
            SPSecurity.RunWithElevatedPrivileges(delegate ()
            {
                this._webpart = this.Parent as VisualWebPart1;
                //menuPosition.Text = this._webpart.Menu_Position.ToString();
                IS_LR_AVAILABLE = this._webpart.LR_AVAILABLE;
                POSITION_CLASS = "panel-left";
                ASSEST_DIR = "";
                //HtmlGenericControl mySidenavX = (HtmlGenericControl)FindControl("mySidenav");
                mySidenav.Attributes["class"] = mySidenav.Attributes["class"].Replace("panel-left", "");
                mySidenav.Attributes["class"] = mySidenav.Attributes["class"].Replace("panel-right", "");

                if (this._webpart.Menu_Position.ToString() == "right") {
                    POSITION_CLASS = "panel-right";
                    ASSEST_DIR = "assets-dir-rl";

                }
                mySidenav.Attributes["class"] += " "+ POSITION_CLASS;




            });
        }
      
       
    }
}

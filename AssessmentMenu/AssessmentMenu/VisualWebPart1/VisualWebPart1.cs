using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace AssessmentMenu.VisualWebPart1
{
    [ToolboxItemAttribute(false)]
    public class VisualWebPart1 : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private const string _ascxPath = @"~/_CONTROLTEMPLATES/15/AssessmentMenu/VisualWebPart1/VisualWebPart1UserControl.ascx";
        public enum MENU_POSITION {  left = 0, right = 1 };
        protected MENU_POSITION menu_position;
        [System.Web.UI.WebControls.WebParts.WebBrowsable(true),
        System.Web.UI.WebControls.WebParts.WebDisplayName("Select menu position:"),
        System.Web.UI.WebControls.WebParts.WebDescription(""),
        System.Web.UI.WebControls.WebParts.Personalizable(
        System.Web.UI.WebControls.WebParts.PersonalizationScope.Shared),
        System.ComponentModel.Category("Look & Feel")]
        public MENU_POSITION Menu_Position
        {
            get
            {
                return menu_position;
            }
            set
            {
               menu_position = value;
            }
        }
        protected bool is_lr_available;
        [System.Web.UI.WebControls.WebParts.WebBrowsable(true),
        System.Web.UI.WebControls.WebParts.WebDisplayName("Allow Left To Right"),
        System.Web.UI.WebControls.WebParts.WebDescription(""),
        System.Web.UI.WebControls.WebParts.Personalizable(
        System.Web.UI.WebControls.WebParts.PersonalizationScope.Shared),
        System.ComponentModel.Category("Look & Feel")]
        public bool LR_AVAILABLE
        {
            get
            {
                return is_lr_available;
            }
            set
            {
                is_lr_available = value;
            }
        }

        public VisualWebPart1()
        {
            
            menu_position = 0;
            is_lr_available = true;


        }

        protected override void CreateChildControls()
        {
            Control control = Page.LoadControl(_ascxPath);
            Controls.Add(control);
        }
    }
} 

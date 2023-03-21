using Microsoft.SharePoint;
using System;
using System.Collections.Specialized;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace AS_WPHello2.VisualWebPart1
{
    public partial class VisualWebPart1UserControl : UserControl
    {
        public VisualWebPart1 _webpart { get; set; }

        //internal void ConnectWebPart()
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }
            /*
            this._webpart = this.Parent as VisualWebPart1;
            lblCategory.Text = this._webpart.Category;
            lblYear.Text = this._webpart.Year.ToString();
            */
            SPSecurity.RunWithElevatedPrivileges(delegate ()
            {

                Start();
            });

        }
        /// <summary>
        /// This is a central method that takes place on the page load.
        /// </summary>
        private void Start()
        {
            SPSecurity.RunWithElevatedPrivileges(delegate ()
            {
                this._webpart = this.Parent as VisualWebPart1;
                lblCategory.Text = this._webpart.Category;
                lblYear.Text = this._webpart.Year.ToString();

                string siteURL = SPContext.Current.Web.Url;

                using (SPSite _site = new SPSite(siteURL))
                {
                    lblSiteURL.Text = siteURL;
                    using (SPWeb _web = _site.OpenWeb())
                    {
                        // Get all the lists in the web
                        SPListCollection lists = _web.Lists;

                        // Create a String collection to hold the list titles
                        StringCollection listTitles = new StringCollection();

                        // Loop through each list and add its title to the collection
                        foreach (SPList list in lists)
                        {
                            listTitles.Add(list.Title);
                        }

                        // Use the String collection as needed
                        foreach (string title in listTitles)
                        {
                            var newItem = new HtmlGenericControl("li");
                            newItem.InnerText = title;
         
                            // Add the class to the item
                            newItem.Attributes.Add("class", "list-group-item"); 
                            ulLists.Controls.Add(newItem);
                        }
                    }
                }


            });
        }
    }
}

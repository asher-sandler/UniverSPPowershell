using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.SharePoint.Client;

namespace Test_CSOM
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void LoadCsom_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Ok");
            string webUrl = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
            using (var context = new ClientContext(webUrl))
            {
                //context.Credentials = new (userName, pwd);
                context.Credentials = new System.Net.NetworkCredential("ashersa", "GrapeFloor789", "ekmd");
                var web = context.Web;
                context.Load(web);

                var query = from list in web.Lists
                            where list.Hidden == false &&
                            list.ItemCount > 0
                            select list;
                var lists = context.LoadQuery(query);

                Microsoft.SharePoint.Client.List lst = web.Lists.GetByTitle("fruits");
                context.Load(lst);
                context.ExecuteQuery();
                MessageBox.Show(lst.Title);
                MessageBox.Show(lst.ItemCount.ToString());

            }
        }

       

        

       
    }
}

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

namespace Test_CSOM.Controls
{
    /// <summary>
    /// Interaction logic for RibbonControl.xaml
    /// </summary>
    public partial class RibbonControl : UserControl
    {
        public RibbonControl()
        {
            InitializeComponent();
        }

        private void SPConect_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("SP Connect");
        }

        private void SPDisconnect_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("SP Disconnect");
        }
    }
}

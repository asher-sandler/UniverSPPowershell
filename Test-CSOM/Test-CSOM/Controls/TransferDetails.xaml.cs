using System.Windows;
using System.Windows.Controls;

namespace Test_CSOM.Controls
{
    /// <summary>
    /// Interaction logic for TransferDetails.xaml
    /// </summary>
    public partial class TransferDetails : UserControl
    {
        public TransferDetails()
        {
            InitializeComponent();
        }

        private void TransferDetails_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Transfer Details");
        }
    }
}

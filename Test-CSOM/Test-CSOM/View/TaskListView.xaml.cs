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
using Test_CSOM.Data;
using Test_CSOM.ViewModel;

namespace Test_CSOM.View
{
    /// <summary>
    /// Interaction logic for TaskListView.xaml
    /// </summary>
    public partial class TaskListView : UserControl
    {
        private GeneralRequestViewModel _viewModel;

        public TaskListView()
        {
            InitializeComponent();
            _viewModel = new GeneralRequestViewModel(new GeneralRequestDataProvider());
            this.DataContext = _viewModel;
            this.Loaded += GeneralRequestView_Loaded;

        }
     
        private async void GeneralRequestView_Loaded(object sender, RoutedEventArgs e)
        {
           await  _viewModel.LoadAsync();
        }
        private async void SPConect_Click(object sender, RoutedEventArgs e)
        {
            
            //MessageBox.Show("SP Connect");

            await _viewModel.LoadAsync();
        }
       
       
    }
}

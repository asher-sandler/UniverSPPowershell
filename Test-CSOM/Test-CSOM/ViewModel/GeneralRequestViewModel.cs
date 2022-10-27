using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Test_CSOM.Data;
using Test_CSOM.Model;

namespace Test_CSOM.ViewModel
{
    public class GeneralRequestViewModel
    {
        private readonly IGeneralRequestDataProvider _generalRequestDataProvider;
        public GeneralRequestViewModel(IGeneralRequestDataProvider generalRequestDataProvider)
        {
            this._generalRequestDataProvider = generalRequestDataProvider;
        }
        public ObservableCollection<GeneralRequest> GeneralRequests { get; } =
            new ObservableCollection<GeneralRequest>();
        public GeneralRequest SelectedGeneralRequest { get;  set; }
       
            public async Task LoadAsync()
        {
            if (GeneralRequests.Any()) {
                GeneralRequests.Clear();
            }

            var generalRequests = await _generalRequestDataProvider.GetAllAsync();
            if (generalRequests is null) { }
            else
            {
                foreach (var genRequest in generalRequests)
                {
                    GeneralRequests.Add(genRequest);
                }
            }
        }

    }
}

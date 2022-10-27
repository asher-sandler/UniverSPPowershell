using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Test_CSOM.Model;

namespace Test_CSOM.Data {
    public interface IGeneralRequestDataProvider
    {
        Task<IEnumerable<GeneralRequest>> GetAllAsync();
    };
    
    class GeneralRequestDataProvider : IGeneralRequestDataProvider
    {
        private GeneralRequest CreateItem(int id, string email,string fname, string lname, 
            string phone,string details, 
            string status, string url, string uname) {
            GeneralRequest itm = new GeneralRequest();

            itm.Id = id;
            itm.Email = email;
            itm.FName = fname;
            itm.LName = lname;
            itm.Phone = phone;
            itm.RequestDetails = details;
            itm.Status = status;
            itm.Url = url;
            itm.UserName = uname;
            itm.FullName = fname + "\n" + lname;
            itm.FullDetails = id.ToString().Trim() + "\n" +
                 email + "\n" +
                 fname + "\n" +
                 lname + "\n" +
                 phone + "\n" +
                 details + "\n" +
                 status + "\n" +
                 url + "\n" +
                 uname + "\n";

            return itm;

        }
        
        public async Task<IEnumerable<GeneralRequest>> GetAllAsync()
        {
            List<GeneralRequest> genList = new List<GeneralRequest>();
            
            await Task.Delay(1000);

            genList.Clear();
            genList.Add(CreateItem(1,  "a@b.com", "Asher",  "Malkiel Sandler",
                     "1234",  "Details",  "Ok", "www.asher.com",  "ashersa"));
            genList.Add(CreateItem(2,  "s@b.com", "Simcha",  "Sandler",
                     "5678",  "Details Simcha",  "Ok Simcha", "www.Simcha.com",  "simchasa"));
            genList.Add(CreateItem(3,  "p@b.com", "Ptahia",  "Sandler jr.",
                     "6543",  "Details Ptahia",  "Ok Ptahia", "www.ptahia.com",  "ptahiasa"));


            return genList;
          
        }

    }
}

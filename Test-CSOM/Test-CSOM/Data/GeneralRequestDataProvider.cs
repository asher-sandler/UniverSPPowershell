using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Test_CSOM.Model;
using Microsoft.SharePoint.Client;

namespace Test_CSOM.Data {
    public interface IGeneralRequestDataProvider
    {
        Task<IEnumerable<GeneralRequest>> GetAllAsync();
    };
    
    class GeneralRequestDataProvider : IGeneralRequestDataProvider
    {
        private GeneralRequest CreateItem(int id, string email,string fname, string lname, 
            string phone,string details, 
            string status, string url, string uname,string subject) {
            GeneralRequest itm = new GeneralRequest();

            itm.Id = id;
            itm.Email = email;
            itm.FName = fname;
            itm.LName = lname;
            itm.Phone = phone;
            itm.RequestSubject = subject;
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

            //await Task.Delay(1000);

            genList.Clear();

            // https://portals2.ekmd.huji.ac.il/home/huca/spSupport/
            string webUrl = "https://portals.ekmd.huji.ac.il/home/huca/spSupport/";
            using (var context = new ClientContext(webUrl))
            {
                //context.Credentials = new (userName, pwd);
                context.Credentials = new System.Net.NetworkCredential("ashersa", "GrapeFloor789", "ekmd");
                var web = context.Web;
                context.Load(web);

                Microsoft.SharePoint.Client.List list = web.Lists.GetByTitle("generalRequestList");

                var q = new CamlQuery() { ViewXml = "<View><Query><Where><Eq><FieldRef Name='status' /><Value Type='Choice'>בביצוע</Value></Eq></Where></Query></View>" };
                var items = list.GetItems(q);
                context.Load(list);
                context.Load(list.Fields);
                context.Load(items);
                context.ExecuteQuery();
                
                
                foreach (ListItem itm in items) {
                    context.Load(itm);
                    context.ExecuteQuery();
                    int id = itm.Id;

                    string contactFN = "";
                    string contactLN = "";
                    string contactEmail = "";
                    string contactPhone = "";
                    string url = "";
                    string details = "";
                    string uName = "";
                    string status = "";
                    string subject = "";
                    foreach (var fValues in itm.FieldValues)
                    {
                        var fldTitle = fValues.Key;
                        var fldValue = fValues.Value;
                        if (fldTitle == "contactFirstNameEn") {
                            contactFN = fldValue.ToString();
                        }
                        if (fldTitle == "contactLastNameEn")
                        {
                            contactLN = fldValue.ToString();
                        }
                        if (fldTitle == "contactEmail")
                        {
                            contactEmail = fldValue.ToString();
                        }
                        if (fldTitle == "contactPhone")
                        {
                            contactPhone = fldValue.ToString();
                        }
                        if (fldTitle == "relevantUrl")
                        {
                            url = fldValue.ToString();
                        }
                        if (fldTitle == "requestDetails")
                        {
                            details = fldValue.ToString();
                        }
                        if (fldTitle == "requestSubject")
                        {
                            subject = fldValue.ToString();
                        }
                        if (fldTitle == "userName")
                        {
                            uName = fldValue.ToString();
                        }
                        if (fldTitle == "status")
                        {
                            status = fldValue.ToString();
                        }
                    }

                    genList.Add(CreateItem(id , contactEmail, contactFN, contactLN,
                     contactPhone, details, status, url, uName,subject));
                }
                

            }
            /*
             genList.Add(CreateItem(1,  "a@b.com", "Asher",  "Malkiel Sandler",
                     "1234",  "Details",  "Ok", "www.asher.com",  "ashersa"));
            genList.Add(CreateItem(2,  "s@b.com", "Simcha",  "Sandler",
                     "5678",  "Details Simcha",  "Ok Simcha", "www.Simcha.com",  "simchasa"));
            genList.Add(CreateItem(3,  "p@b.com", "Ptahia",  "Sandler jr.",
                     "6543",  "Details Ptahia",  "Ok Ptahia", "www.ptahia.com",  "ptahiasa"));

             */
            return genList;
          
        }

    }
}

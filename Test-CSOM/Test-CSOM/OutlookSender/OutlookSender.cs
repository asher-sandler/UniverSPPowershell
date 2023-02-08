using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Outlook = Microsoft.Office.Interop.Outlook;

namespace Test_CSOM.OutlookSender
{
    class OSender
    {
        public OSender(string subject, string body, string email)
        {
            this.Subject = subject;
            this.Body = body;
            this.Email = email;
        }
        public string Subject { get; set; }
        public string Body { get; set; }
        public string Email { get; set; }

        public void SendMessage() {
            Outlook.Application oApp = new Outlook.Application();
            Outlook.MailItem mailItem = (Outlook.MailItem)oApp.CreateItem(Outlook.OlItemType.olMailItem);
            // sets the subject of mail
            mailItem.Subject = Subject;
            // adds the attachment to the mail             
            //mailItem.Attachments.Add("D:/Test/SampleAttachment.xlsx");
            // sets the To recepients of mail
            mailItem.To = Email;
            mailItem.CC = "supportsp@savion.huji.ac.il";
            //mailItem.SentOnBehalfOfName = "supportsp@savion.huji.ac.il";
            //mailItem = "supportsp@savion.huji.ac.il";
            // sets the mail body
            mailItem.HTMLBody = Body;
            // sets the mail importance
            mailItem.Importance = Outlook.OlImportance.olImportanceLow;
            mailItem.Display(true);
            // sends the mail
            //mailItem.Send();
        }

    }
}

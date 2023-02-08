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
using Test_CSOM.OutlookSender;
using Test_CSOM.ViewModel;
using System.Runtime.InteropServices;
using Outlook = Microsoft.Office.Interop.Outlook;
using System.Diagnostics;
using System.Reflection;
using System.Collections.Specialized;

namespace Test_CSOM.View
{
    /// <summary>
    /// Interaction logic for TaskListView.xaml
    /// </summary>
    public partial class TaskListView : UserControl
    {
        private GeneralRequestViewModel _viewModel;
        private Boolean canSend = false;

        public TaskListView()
        {
            InitializeComponent();
            _viewModel = new GeneralRequestViewModel(new GeneralRequestDataProvider());
            this.DataContext = _viewModel;
            this.Loaded += GeneralRequestView_Loaded;

        }

        private async void GeneralRequestView_Loaded(object sender, RoutedEventArgs e)
        {
            await _viewModel.LoadAsync();
        }
        private async void SPConect_Click(object sender, RoutedEventArgs e)
        {

            //MessageBox.Show("SP Connect");

            await _viewModel.LoadAsync();
        }

        private void TransferDetails_Click(object sender, RoutedEventArgs e)
        {
            if (_viewModel.SelectedGeneralRequest is null)
            {
                canSend = false;
            }
            else
            {
                textBox_Subject.Text = "Re: " + _viewModel.SelectedGeneralRequest.RequestSubject;
                //textBox_SendTo.Text = "ashersa@ekmd.huji.ac.il"; //_viewModel.SelectedGeneralRequest.Email;
                textBox_SendTo.Text = _viewModel.SelectedGeneralRequest.Email;
                textBox_Body.Text = _viewModel.SelectedGeneralRequest.RequestDetails;
                canSend = true;
            }


        }
        /*

        private void label1_Click(object sender, EventArgs e)
        {
          // mainform.BringToFront(); // doesn't work
          BeginInvoke(new VoidHandler(OtherFormToFront));
        }

        delegate void VoidHandler();

        private void OtherFormToFront()
        {
          mainform.BringToFront(); // works
        }             
        */
        private async void SendOutlook_Click(object sender, RoutedEventArgs e)
        {
            if (canSend)
            {
                //OSender outlookSender = new OSender(textBox_Subject.Text, textBox_Body.Text, textBox_SendTo.Text);
                //outlookSender.SendMessage();
                // MessageBox.Show("Outlook Sent.");
                //Outlook.Application GetApplicationObject()
                string subj =  textBox_Subject.Text;
                string bodyLines = "<html xmlns='http://www.w3.org/1999/xhtml'><head><title>";
                bodyLines += "<title>"+ subj + "</title>";
                bodyLines += "<p>שלום " + _viewModel.SelectedGeneralRequest.FName+".</p>";
                bodyLines += "<p></p>";
                bodyLines += "<p></p>";
                bodyLines += "<p>____________________________________________</p>";
                string signature = @"<p class=MsoNormal align=right style='text-align:right'><span dir=RTL></span><b>
<span lang=HE dir=RTL style='font-family:'Arial',sans-serif;mso-fareast-font-family:Calibri;color:#7030A0'>
<span dir=RTL></span><span style='mso-spacerun:yes'></span>בברכה</span></b><b>
<span style='font-family:'Arial',sans-serif;mso-fareast-font-family:Calibri;color:#7030A0'><o:p></o:p></span></b></p>
<p class=MsoNormal><span style='font-size:12.0pt;mso-ascii-font-family:Calibri;mso-fareast-font-family:Calibri;mso-hansi-font-family:Calibri;mso-bidi-font-family:Calibri;color:#1F3864'><o:p>&nbsp;</o:p></span></p>
<div align=right>
<table class=MsoNormalTable dir=rtl border=0 cellspacing=0 cellpadding=0 width=326 style='width:244.4pt;border-collapse:collapse;mso-yfti-tbllook:1184; mso-padding-alt:0in 0in 0in 0in;mso-table-dir:bidi'>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;height:78.05pt'>
<td width=100 valign=top style='width:75.3pt;padding:0in 5.4pt 0in 5.4pt;height:78.05pt'>
<p class=MsoNormal dir=LTR><span style='color:#1F497D;mso-no-proof:yes'>
<img width=58 height=62  src='data:image/png;base64,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' alt='The Hebrew University in Jerusalem'/>
</span>
</p>
</td>
<td width=225 valign=top style='width:169.1pt;padding:0in 5.4pt 0in 5.4pt;height:78.05pt'>
<p class=MsoNormal dir=RTL style='text-align:right;direction:rtl;unicode-bidi:embed'>
<b>
<span lang=HE style='font-size:10.0pt;font-family:'Arial',sans-serif; color:#1F497D'>היחידה לפיתוח מערכות מידע </span></b>
<b>
<span dir=LTR  style='font-size:10.0pt;font-family:'Arial',sans-serif;color:#1F497D'>
<br>
</span>
</b>
<b>
<span lang=HE style='font-size:10.0pt;font-family:'Arial',sans-serif;  color:#1F497D'>מקומיות ומשלימות</span>
</b>
<span dir=LTR style='font-size:  10.0pt;font-family:'Arial',sans-serif;color:#1F497D'></span>
</p>
<p class=MsoNormal dir=RTL style='margin-bottom:12.0pt;text-align:right; direction:rtl;unicode-bidi:embed'><b><span lang=HE style='font-size:10.0pt;  font-family:'Arial',sans-serif;color:#1F497D'>האגף למחשוב, תקשורת ומידע</span></b>
<span lang=AR-SA style='font-size:10.0pt;font-family:'Arial',sans-serif;color:#1F497D; mso-bidi-language:AR-SA'><br>
</span><span lang=HE style='font-size:10.0pt;font-family:'Arial',sans-serif; color:#1F497D'>האוניברסיטה העברית בירושלים<br>
</span>
<span lang=HE style='font-family:'Arial',sans-serif;color:#1F497D'>
<a href='mailto:supportsp@savion.huji.ac.il'>
<span lang=EN-US dir=LTR style='font-family:'Calibri',sans-serif;mso-ascii-theme-font:minor-latin;  mso-hansi-theme-font:minor-latin;mso-bidi-font-family:Arial;mso-bidi-theme-font:  minor-bidi'>supportsp@savion.huji.ac.il</span>
</a>
</span>
<span dir=LTR  style='mso-ascii-font-family:Calibri;mso-hansi-font-family:Calibri;mso-bidi-font-family:Calibri;color:#1F497D'><o:p></o:p></span></p>
</td>
</tr>
</table>
</div>";

                int lineCount = textBox_Body.LineCount;
                for (int line = 0; line < lineCount; line++)
                {
                    // GetLineText takes a zero-based line index.
                    bodyLines += "<p>"+ textBox_Body.GetLineText(line)+ "</p>";
                }
                bodyLines += "<p>____________________________________________</p>";
                bodyLines += "<p></p>";
                bodyLines += "<p></p>";
                bodyLines += "<p></p>";
                bodyLines += signature;
                string sendto = textBox_SendTo.Text;
                //string body = textBox_Body.Text;
                bodyLines += "</body></html>";
                

                await Task.Run(() =>
                {
                    try
                    {
                        Outlook.Application application = null;

                        // Check whether there is an Outlook process running.
                        if (Process.GetProcessesByName("OUTLOOK").Count() > 0)
                        {

                            // If so, use the GetActiveObject method to obtain the process and cast it to an Application object.
                            application = Marshal.GetActiveObject("Outlook.Application") as Outlook.Application;
                        }
                        else
                        {

                            // If not, create a new instance of Outlook and sign in to the default profile.
                            application = new Outlook.Application();
                            Outlook.NameSpace nameSpace = application.GetNamespace("MAPI");
                            nameSpace.Logon("", "", Missing.Value, Missing.Value);
                            nameSpace = null;
                        }

                        // Return the Outlook Application object.
                        //return application;
                        Outlook.MailItem mailItem = (Outlook.MailItem)application.CreateItem(Outlook.OlItemType.olMailItem);
                        //if (mailItem.d)
                        // sets the subject of mail
                        mailItem.Subject = subj; // Subject;
                                                 // adds the attachment to the mail             
                                                 //mailItem.Attachments.Add("D:/Test/SampleAttachment.xlsx");
                                                 // sets the To recepients of mail
                        mailItem.To = sendto;//Email;
                        mailItem.CC = "supportsp@savion.huji.ac.il";
                        //mailItem.SentOnBehalfOfName = "supportsp@savion.huji.ac.il";
                        //mailItem = "supportsp@savion.huji.ac.il";
                        // sets the mail body
                        mailItem.HTMLBody = bodyLines; // Body;
                                                  // sets the mail importance
                        mailItem.Importance = Outlook.OlImportance.olImportanceNormal;
                        mailItem.Display(true);
                        //};

                        //System.Diagnostics.Process.Start("mailto:" + "example@example.com" + "?subject=This is a subject" + "&body=this is my body");
                        //System.Diagnostics.Process.Start(@"'C:\Program Files(x86)\Microsoft Office\root\Office16\OUTLOOK.EXE' /c ipm.note /m 'GRS - SOC52 - 2022 - EKMDdante@ekmd.huji.ac.il ? subject = Recommendations & body = Recommendations' /a 'C:\AdminDir\SP Powershell\sendDante\RecommendationsendDante.txt'");
                        //System.Diagnostics.Process.Start("OUTLOOK.EXE" , " /c ipm.note /m here@there.com");
                    }
                    catch(Exception ex)
                    {
                        if (ex.Message.Contains("because a dialog box is open."))
                        {
                            MessageBox.Show("Outlook message item still active.\nComplete the operation to open new item.");
                        }
                    }
                });
            }
            else
            {

                MessageBox.Show("Connect To Sharepoint First.");
            }
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Test_CSOM.Model
{
    public class GeneralRequest
    {
        private string _fullName;
        private string _fullDetails;
        public int Id { get; set; }
        public string FName { get; set; }
        public string LName { get; set; }
        public string FullName
        {
            get
            {
                
                return _fullName;
            }
            set { _fullName = value; }
        }
        public string FullDetails
        {
            get
            {

                return _fullDetails;
            }
            set { _fullDetails = value; }
        }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Url { get; set; }
        public string RequestDetails { get; set; }
        public string RequestSubject { get; set; }
        public string UserName { get; set; }
        public string Status { get; set; }

    }
}

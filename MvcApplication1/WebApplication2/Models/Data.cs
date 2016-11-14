using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication2.Models
{
    public class Data
    {
        public int[,] values;
        public int[,] solved;

        public Data()
        {
            solved = new int[9, 9];
            values = new int[9, 9];
        }
    }
}
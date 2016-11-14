using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication2.Controller;
using WebApplication2.Models;

namespace WebApplication2
{
    public partial class _Default : Page
    {
        private Data data;


        protected void Page_Load(object sender, EventArgs e)
        {
            data = new Data();

            for (int i = 0; i < 9; i++)
            {
                Table1.Rows.Add(new TableRow());
                for (int j = 0; j < 9; j++)
                {
                    Table1.Rows[i].Cells.Add(new TableCell());
                    Table1.Rows[i].Cells[j].Controls.Add(new TextBox());
                    

                    foreach (TextBox item in Table1.Rows[i].Cells[j].Controls)
                    {
                        item.Text = "0";
                        item.Width = 25;
                    }
                }
            }
        }

        protected void click_event(object sender, EventArgs e)
        {

            for (int i = 0; i < 9; i++)
            {
                for (int j = 0; j < 9; j++)
                {
                    foreach (TextBox item in Table1.Rows[i].Cells[j].Controls)
                        Int32.TryParse(item.Text, out data.values[i, j]);
                }

            }
            data.solved = Solver.Generate(data.values);
            FillGrid(data.solved);
            Label1.Text = "SOLVED!";
            Label1.Font.Size = 15;

        }


        private void FillGrid(int[,] values)
        {
            for (int i = 0; i < 9; i++)
            {
                for (int j = 0; j < 9; j++)
                {
                    foreach (TextBox item in Table1.Rows[i].Cells[j].Controls)
                    {
                        item.Text = values[i, j].ToString();
                        item.ReadOnly = true;
                    }

                }
            }
        }
    }
}
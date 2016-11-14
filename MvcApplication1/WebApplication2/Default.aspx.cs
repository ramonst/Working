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
            DrawBoard();
        }

        private void DrawBoard()
        {
            data = new Data();

            for (int i = 0; i < 9; i++)
            {
                Table1.Rows.Add(new TableRow());

                for (int j = 0; j < 9; j++)
                {
                    TextBox txtBox = new TextBox();
                    TableCell cell = new TableCell();

                    cell.Width = 80;
                    Table1.Rows[i].Cells.Add(cell);

                    if (CheckForColor(i, j))
                        Table1.Rows[i].Cells[j].BackColor = Color.CornflowerBlue;


                    Table1.Rows[i].Cells[j].Controls.Add(txtBox);
                    Table1.Rows[i].Cells[j].Style["padding"] = "5px";

                    foreach (TextBox item in Table1.Rows[i].Cells[j].Controls)
                    {
                        item.Text = "0";
                        item.Font.Size = 10;
                        item.Style["text-align"] = "center";
                        item.Width = 25;
                        item.TextChanged += item_TextChanged;
                        
                     
                    }
                }
            }
        }

        void item_TextChanged(object sender, EventArgs e)
        {
            TextBox txtBox = (TextBox)sender;
            int value = 0;
            Int32.TryParse(txtBox.Text, out value);
            if (value < 1 || value > 9)
                txtBox.Text = "0";
        }



        private bool CheckForColor(int a, int b)
        {
            if (a < 3 && b < 3)
                return true;
            else if (a < 3 && b > 5)
                return true;
            else if (a > 2 && a < 6 && b > 2 && b < 6)
                return true;
            else if (a > 5 && b < 3)
                return true;
            else if (a > 5 && b > 5)
                return true;


            return false;
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
                        item.Text = values[i, j].ToString();
                }
            }
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            Label1.Text = "";
            for (int i = 0; i < 9; i++)
            {
                for (int j = 0; j < 9; j++)
                {
                    foreach (TextBox item in Table1.Rows[i].Cells[j].Controls)
                        item.Text = "0";
                }
            }
            data = new Data();
        }
    }
}
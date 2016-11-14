using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication2.Controller
{
    public class Solver
    {
        struct Position
        {
            public int X;
            public int Y;

            public Position(int X, int Y)
            {
                this.X = X;
                this.Y = Y;
            }
        }

        public static int[,] Generate(int[,] values)
        {
            //stopwatch = new Stopwatch();
            //stopwatch.Start();
            Solve(values);
            //stopwatch.Stop();
            //timeElapsedSec = stopwatch.Elapsed.TotalMilliseconds;
            ////Console.WriteLine("Hello");
            //stopwatch.Reset();

            //Console.WriteLine(timeElapsedSec);
            return values;
        }

        //public static int[,] SafeGenerate(int numValues, int maxIter = 10000)
        //{
        //    while(true)
        //    {
        //        int[,] values = Generate(numValues, maxIter);
        //        int[,] copy = Copy(values);
        //        if (Solve(values))
        //            return copy;
        //    }
        //}

        public static int[,] Generate(int numValues, int maxIter = 10000)
        {
            int[,] values = new int[9, 9];

            Random r = new Random();

            int iterationCounter = 0;
            int counter = 0;
            while (true)
            {
                ++iterationCounter;
                if (iterationCounter >= maxIter)
                    break; //throw new Exception("Exceeded iteration limit");

                int candidate = r.Next(9) + 1;

                int x = r.Next(9);
                int y = r.Next(9);

                if (values[x, y] != 0)
                    continue;

                if (!Check(values, x, y, candidate))
                    continue;

                values[x, y] = candidate;
                ++counter;
                if (counter >= numValues)
                    break;
            }
            return values;
        }



        private static bool Solve(int[,] values)
        {

            List<Position> free_fields = new List<Position>();
            bool result = true;

            for (int x = 0; x < 9; x++)
            {
                for (int y = 0; y < 9; y++)
                {

                    if (values[x, y] == 0)
                    {
                        free_fields.Add(new Position(x, y));
                    }
                }
            }

            if (free_fields.Count > 0)
            {

                Random r = new Random();
                Position p = free_fields[r.Next(0, free_fields.Count - 1)];


                int[] free_values = new int[9];
                for (int j = 1; j <= 9; j++)
                {
                    free_values[j - 1] = j;
                }


                int v, index;
                for (int j = 0; j < free_values.Length; j++)
                {
                    v = free_values[j];
                    index = r.Next(0, free_values.Length - 1);
                    free_values[j] = free_values[index];
                    free_values[index] = v;
                }


                result = false;
                foreach (int value in free_values)
                {
                    if (Check(values, p.X, p.Y, value))
                    {

                        values[p.X, p.Y] = value;

                        if (!Solve(values))
                        {
                            values[p.X, p.Y] = 0;
                        }
                        else
                        {
                            result = true;

                            break;
                        }
                    }
                }
            }


            return result;
        }

        public static bool CheckRow(int[,] values, int pY, int candidate)
        {
            for (int x = 0; x < 9; x++)
            {
                if (values[x, pY] == candidate)
                    return false;
            }
            return true;
        }

        public static bool CheckColumn(int[,] values, int pX, int candidate)
        {
            for (int y = 0; y < 9; y++)
            {
                if (values[pX, y] == candidate)
                    return false;
            }
            return true;
        }

        public static bool CheckBlock(int[,] values, int pX, int pY, int candidate)
        {
            int startX = pX / 3;
            int startY = pY / 3;


            int endX = startX * 3 + 3;
            int endY = startY * 3 + 3;

            for (int x = startX * 3; x < endX; x++)
            {
                for (int y = startY * 3; y < endY; y++)
                {
                    if (values[x, y] == candidate)
                        return false;
                }
            }
            return true;
        }

        public static bool Check(int[,] values, int pX, int pY, int value)
        {
            return CheckRow(values, pY, value) && CheckColumn(values, pX, value) && CheckBlock(values, pX, pY, value);
        }

    }
}
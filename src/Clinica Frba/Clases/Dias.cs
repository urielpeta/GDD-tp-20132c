﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clinica_Frba.Clases
{
    public class Dias
    {
        public string Detalle { get; set; }
        public int Id { get; set; }

        public Dias(int id, string detalle)
        {
            Detalle = detalle;
            Id = id;
        }

        public Dias(int id)
        {
            Id = id;
            switch (id)
            {
                case 1:
                    Detalle= "Domingo";
                    break;
                case 2:
                    Detalle = "Lunes";
                    break;
                case 3:
                    Detalle = "Martes";
                    break;
                case 4:
                    Detalle = "Miercoles";
                    break;
                case 5:
                    Detalle = "Jueves";
                    break;
                case 6:
                    Detalle = "Viernes";
                    break;
                case 7:
                    Detalle = "Sábado";
                    break;
            }
        }

        public Dias(System.DayOfWeek day)
        {
            switch (day.ToString())
            {
                case "Sunday":
                    Id = 1;
                    Detalle = "Domingo";
                    break;
                case "Monday":
                    Id = 2;
                    Detalle = "Lunes";
                    break;
                case "Tuesday":
                    Id = 3;
                    Detalle = "Martes";
                    break;
                case "Wednesday":
                    Id = 4;
                    Detalle = "Miercoles";
                    break;
                case "Thursday":
                    Id = 5;
                    Detalle = "Jueves";
                    break;
                case "Friday":
                    Id = 6;
                    Detalle = "Viernes";
                    break;
                case "Saturday":
                    Id = 7;
                    Detalle = "Sábado";
                    break;
            }
        }
    }
}

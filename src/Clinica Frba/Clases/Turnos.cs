﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace Clinica_Frba.Clases
{
    public class Turnos
    {
        public static Boolean VerificarTurnoLibre(Turno turno)
        {
            List<SqlParameter> ListaParametros = new List<SqlParameter>();
            SqlParameter fecha = new SqlParameter("@fecha", System.Data.SqlDbType.DateTime);
            fecha.Value = turno.Fecha.Date;
            ListaParametros.Add(fecha);
            SqlParameter horario = new SqlParameter("@horario", System.Data.SqlDbType.Time);
            horario.Value = turno.Horario;
            ListaParametros.Add(horario);
            ListaParametros.Add(new SqlParameter("@profesional", turno.Codigo_Profesional));

            SqlParameter paramRet = new SqlParameter("@ret", System.Data.SqlDbType.Decimal);
            paramRet.Direction = System.Data.ParameterDirection.Output;
            ListaParametros.Add(paramRet);

            int ret = (int)Clases.BaseDeDatosSQL.ExecStoredProcedure("mario_killers.verificarTurno", ListaParametros);
            if (ret == 1) return true; else return false;
        }


        public static List<Turno> ObtenerTurnos(int persona)
        {
            List<Turno> listTurno = new List<Turno>();

            List<SqlParameter> ListaParametros = new List<SqlParameter>();
            ListaParametros.Add(new SqlParameter("@id", persona));

            SqlDataReader lector = Clases.BaseDeDatosSQL.ObtenerDataReader("SELECT * FROM mario_killers.TurnosPorPaciente WHERE paciente_id = @id", "T", ListaParametros);

            if (lector.HasRows)
            {
                while (lector.Read())
                {
                    Turno unTurno = new Turno();
                    unTurno.Id = (decimal)lector["id"];
                    unTurno.Codigo_Persona = (int)(decimal)lector["paciente_id"];
                    unTurno.Nombre_Persona = (String)lector["paciente"];
                    unTurno.Codigo_Profesional = (int)(decimal)lector["profesional_id"];
                    unTurno.Nombre_Profesional = (String)lector["profesional"];
                    unTurno.Fecha = (DateTime)lector["fecha"];
                    unTurno.Codigo_Especialidad = (decimal)lector["especialidad"];
                    listTurno.Add(unTurno);
                }
            }
            return listTurno;
        }

        public static void Cancelar(Turno turno, decimal tipoCanc, String motivo)
        {
            List<SqlParameter> ListaParametros = new List<SqlParameter>();
            ListaParametros.Add(new SqlParameter("@id", turno.Id));
            Clases.BaseDeDatosSQL.EscribirEnBase("UPDATE mario_killers.Turno SET activo = 0 WHERE id = @id", "T", ListaParametros);

            List<SqlParameter> ListaParametros2 = new List<SqlParameter>();            
            ListaParametros2.Add(new SqlParameter("@tipo", tipoCanc));
            ListaParametros2.Add(new SqlParameter("@motivo", motivo));
            ListaParametros2.Add(new SqlParameter("@persona", turno.Codigo_Persona));
            ListaParametros2.Add(new SqlParameter("@turno", turno.Id));

            Clases.BaseDeDatosSQL.EscribirEnBase("INSERT INTO mario_killers.Cancelacion (tipo, motivo, persona, turno) VALUES (@tipo, @motivo, @persona, @turno)", "T", ListaParametros2);
        }

        public static decimal AgregarTurno(Turno turno)
        {
            List<SqlParameter> ListaParametros = new List<SqlParameter>();

            ListaParametros.Add(new SqlParameter("@persona", turno.Codigo_Persona));
            ListaParametros.Add(new SqlParameter("@profesional", turno.Codigo_Profesional));
            ListaParametros.Add(new SqlParameter("@horario", turno.Fecha.ToString("yyyy-MM-dd HH:mm:ss.fff")));
            ListaParametros.Add(new SqlParameter("@especialidad", turno.Codigo_Especialidad));

            SqlParameter paramRet = new SqlParameter("@ret", System.Data.SqlDbType.Decimal);
            paramRet.Direction = System.Data.ParameterDirection.Output;
            ListaParametros.Add(paramRet);

            decimal retor = Clases.BaseDeDatosSQL.ExecStoredProcedure("mario_killers.agregarTurno", ListaParametros);

            return retor;
        }

        public static void AnularDia(int profesional, DateTime fecha, decimal tipo, String motivo)
        {
            List<SqlParameter> ListaParametros = new List<SqlParameter>();
            ListaParametros.Add(new SqlParameter("@profesional", profesional));
            //ListaParametros.Add(new SqlParameter("@horario", (String)fecha.ToString("yyyy-MM-dd")));
            SqlParameter facha = new SqlParameter("@horario", System.Data.SqlDbType.Date);
            facha.Value = fecha.Date;
            ListaParametros.Add(facha);

            SqlParameter paramRet = new SqlParameter("@ret", System.Data.SqlDbType.Decimal);
            paramRet.Direction = System.Data.ParameterDirection.Output;
            ListaParametros.Add(paramRet);
            Clases.BaseDeDatosSQL.ExecStoredProcedure("mario_killers.anularDia", ListaParametros);


            List<SqlParameter> ListaParametros2 = new List<SqlParameter>();
            ListaParametros2.Add(new SqlParameter("@profesional", profesional));            
            SqlParameter facha2 = new SqlParameter("@horario", System.Data.SqlDbType.Date);
            facha2.Value = fecha.Date;
            ListaParametros2.Add(facha2);

            SqlDataReader lector = Clases.BaseDeDatosSQL.ObtenerDataReader("SELECT id FROM mario_killers.Turno WHERE profesional = @profesional AND CONVERT(DATE,horario) = CONVERT(DATE,@horario)", "T", ListaParametros2);

            if (lector.HasRows)
            {
                while (lector.Read())
                {
                    decimal turno = (decimal)lector["id"];

                    List<SqlParameter> ListaParametros3 = new List<SqlParameter>();
                    ListaParametros3.Add(new SqlParameter("@tipo", tipo));
                    ListaParametros3.Add(new SqlParameter("@motivo", motivo));
                    ListaParametros3.Add(new SqlParameter("@persona", profesional));
                    ListaParametros3.Add(new SqlParameter("@turno", turno));

                    Clases.BaseDeDatosSQL.EscribirEnBase("INSERT INTO mario_killers.Cancelacion (tipo, motivo, persona, turno) VALUES (@tipo, @motivo, @persona, @turno)", "T", ListaParametros3);

                }
            } 
       }

        public static void AnularRango(int profesional, DateTime fechaInicio, DateTime fechaFin, decimal tipo, String motivo)
        {

            //Registro las cancleaciones
            List<SqlParameter> ListaParametros2 = new List<SqlParameter>();
            ListaParametros2.Add(new SqlParameter("@profesional", profesional));
            SqlParameter fechaIni = new SqlParameter("@horarioInicio", System.Data.SqlDbType.Date);
            fechaIni.Value = fechaInicio.Date;
            ListaParametros2.Add(fechaIni);
            SqlParameter fechaFinal = new SqlParameter("@horarioFin", System.Data.SqlDbType.Date);
            fechaFinal.Value = fechaFin.Date;
            ListaParametros2.Add(fechaFinal);

            SqlDataReader lector = Clases.BaseDeDatosSQL.ObtenerDataReader("SELECT id FROM mario_killers.Turno WHERE profesional = @profesional AND CONVERT(DATE,horario) BETWEEN CONVERT(DATE,@horarioInicio) AND CONVERT(DATE,@horarioFin) AND activo = 1", "T", ListaParametros2);

            if (lector.HasRows)
            {
                while (lector.Read())
                {
                    decimal turno = (decimal)lector["id"];

                    List<SqlParameter> ListaParametros3 = new List<SqlParameter>();
                    ListaParametros3.Add(new SqlParameter("@tipo", tipo));
                    ListaParametros3.Add(new SqlParameter("@motivo", motivo));
                    ListaParametros3.Add(new SqlParameter("@persona", profesional));
                    ListaParametros3.Add(new SqlParameter("@turno", turno));

                    Clases.BaseDeDatosSQL.EscribirEnBase("INSERT INTO mario_killers.Cancelacion (tipo, motivo, persona, turno) VALUES (@tipo, @motivo, @persona, @turno)", "T", ListaParametros3);

                }
            }

            List<SqlParameter> ListaParametros = new List<SqlParameter>();
            ListaParametros.Add(new SqlParameter("@profesional", profesional));
            SqlParameter facha = new SqlParameter("@fechaInicio", System.Data.SqlDbType.Date);
            facha.Value = fechaInicio.Date;
            ListaParametros.Add(facha);
            SqlParameter facha2 = new SqlParameter("@fechaFin", System.Data.SqlDbType.Date);
            facha2.Value = fechaFin.Date;
            ListaParametros.Add(facha2);

            SqlParameter paramRet = new SqlParameter("@ret", System.Data.SqlDbType.Decimal);
            paramRet.Direction = System.Data.ParameterDirection.Output;
            ListaParametros.Add(paramRet);
            Clases.BaseDeDatosSQL.ExecStoredProcedure("mario_killers.anularRango", ListaParametros);
        }            
    }
}

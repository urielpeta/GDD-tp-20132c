﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Clinica_Frba.Clases;
using System.Data.OleDb;

namespace Clinica_Frba.Abm_de_Afiliado
{
    public partial class lstSeleccionAfiliado : Form
    {
        public lstSeleccionAfiliado()
        {
            InitializeComponent();
        }

        //PARA CARGAR EN LA LISTA LOS PARAMETROS DE BUSQUEDA
        private List<OleDbParameter> ListaDeParametros = new List<OleDbParameter>();

        //CARGO EL COMBO CON TODOS LOS PLANES
        private void lstSeleccionAfiliado_Load(object sender, EventArgs e)
        {
            List<Plan> listaDePlaes = Planes.ObtenerPlanes();
            foreach (Plan unPlan in listaDePlaes)
            {
                cmbPlanes.ValueMember = "Codigo";
                cmbPlanes.DisplayMember = "Descripcion";
            }
        }

        private void cmdBuscar_Click(object sender, EventArgs e)
        {
            try 
            {
                
            }
            catch { MessageBox.Show("", "Error!", MessageBoxButtons.OK); }
        }

        private void cmdLimpiar_Click(object sender, EventArgs e)
        {
            txtApellido.Text = "";
            txtDni.Text = "";
            txtNombre.Text = "";
            txtNumAfiliado.Text = "";
        }
    }
}

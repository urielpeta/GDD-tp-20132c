﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Clinica_Frba.Abm_de_Afiliado;
using Clinica_Frba.Clases;

namespace Clinica_Frba.Abm_de_Afiliado
{
    public partial class frmAfiliadoModificacion : Clinica_Frba.NewFolder12.frmAfiliadoAlta
    {
        public frmAfiliadoModificacion()
        {
            InitializeComponent();
        }

        private void frmAfiliadoModificacion_Load(object sender, EventArgs e)
        {
            List<Plan> listaDePlanes = Planes.ObtenerPlanes();
            cmbPlanes.DataSource = listaDePlanes;
            cmbPlanes.ValueMember = "Codigo";
            cmbPlanes.DisplayMember = "Descripcion";

            List<TipoDoc> listaDeTipos = TiposDoc.ObtenerTiposDoc();
            cmbTipoDoc.DataSource = listaDeTipos;
            cmbTipoDoc.ValueMember = "Id";
            cmbTipoDoc.DisplayMember = "Descripcion";

            List<Estado> listaDeEstados = Estados.ObtenerEstados();
            cmbEstadoCivil.DataSource = listaDeEstados;
            cmbEstadoCivil.ValueMember = "Id";
            cmbEstadoCivil.DisplayMember = "Estado_Civil";

            List<Sexo> listaDeSexos = Sexo.ObtenerSexos();
            cmbSexo.DataSource = listaDeSexos;
            cmbSexo.ValueMember = "Id";
            cmbSexo.DisplayMember = "Id";

            // Set the Format type and the CustomFormat string.
            /*dtpFechaNacimiento.Format = DateTimePickerFormat.Custom;
            dtpFechaNacimiento.CustomFormat = "MMMM dd, yyyy";*/

            cargarCampos();

        }

        private void cmdAceptar_Click(object sender, EventArgs e)
        {
            try
            {
                Afiliado nuevoAfil = new Afiliado();
                nuevoAfil.Id = Afiliado.Id;
                nuevoAfil.Numero_Grupo = Afiliado.Numero_Grupo;
                nuevoAfil.Estado_Civil = (decimal)cmbEstadoCivil.SelectedValue;
                nuevoAfil.Direccion = (String)txtDir.Text;
                nuevoAfil.Cantidad_Hijos = (decimal)decimal.Parse(txtHijos.Text);
                nuevoAfil.Mail = (String)txtMail.Text;
                nuevoAfil.Plan_Medico = (decimal)cmbPlanes.SelectedValue;
                nuevoAfil.Sexo = (String)cmbSexo.SelectedValue;
                nuevoAfil.Telefono = (decimal)decimal.Parse(txtTel.Text);

                Afiliados.Modificar(nuevoAfil);

                MessageBox.Show("El Afiliado ha sido modificado exitosamente", "Aviso", MessageBoxButtons.OK);

            this.Hide();
            }
            catch { MessageBox.Show("Error en la actualizacion!", "Error!", MessageBoxButtons.OK); }
        }

        private void cargarCampos()
        {
            txtNombre.Text = Afiliado.Nombre;
            txtNombre.Enabled = false;
            txtApellido.Text = Afiliado.Apellido;
            txtApellido.Enabled = false;
            txtDni.Text = Afiliado.NumeroDocumento.ToString();
            txtDni.Enabled = false;

            label25.Hide();
            btnConyuge.Hide();
            btnHijo.Hide();
            label14.Hide();
            label24.Hide();
            label3.Hide();
            label17.Hide();
            label20.Hide();
            label11.Hide();
            label15.Hide();
            label16.Hide();
            label19.Hide();
            label18.Hide();
            label22.Hide();
            label13.Hide();

            cmdLimpiar.Hide();

            cmbTipoDoc.Enabled = false;
            //dtpFechaNacimiento.Value.Date =     VER TEMA DE TIPOS, SINO YA FUE
            dtpFechaNacimiento.Enabled = false;

            //cmbSexo.Text = ""+Afiliado.Sexo;
            cmbTipoDoc.Text = "" + Utiles.ObtenerTipoDoc(Afiliado.TipoDocumento);

            txtDir.Text = Afiliado.Direccion;
            txtMail.Text = Afiliado.Mail;
            txtHijos.Text = Afiliado.Cantidad_Hijos.ToString();
            txtTel.Text = Afiliado.Telefono.ToString();
            cmbSexo.Text = Afiliado.Sexo;
            cmbPlanes.Text = "" + Utiles.ObtenerPlan(Afiliado.Plan_Medico);
            cmbEstadoCivil.Text = "" + Utiles.ObtenerEstado(Afiliado.Estado_Civil);

            if (Afiliado.Numero_Familiar != 1)
            {
                cmbPlanes.Enabled = false;
            }
        }

    }
}

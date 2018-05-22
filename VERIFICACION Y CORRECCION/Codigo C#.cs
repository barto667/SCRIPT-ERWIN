 private void BuscarPlan()
        {
            if (cbCodAlmacen.SelectedValue != null)
            {
                DataTable dtProductoPrecio = (new CProductos()).TraerProductosXSerieyAlmacen(tbBuscar.Text, cbCodAlmacen.SelectedValue.ToString());
                if (dtProductoPrecio.Rows.Count == 0)
                    MessageBox.Show("No existe elementos con los parametros de busqueda, pruebe introduciendo una serie mas larga o en otro almacen si lo hubiera");
                else
                {
                    if (dtProductoPrecio.Rows.Count == 1)//Base
                    {
                        string _CodigoProducto = dtProductoPrecio.Rows[0]["Cod_Producto"].ToString();
                        string _NombreProducto = dtProductoPrecio.Rows[0]["Nom_Producto"].ToString();
                        string _Serie = dtProductoPrecio.Rows[0]["Serie"].ToString();
                        string _CodAlmacen = cbCodAlmacen.SelectedValue.ToString();
                        int _IdProducto = int.Parse(dtProductoPrecio.Rows[0]["Id_Producto"].ToString());
                        string _CodUnidadMedida = dtProductoPrecio.Rows[0]["Cod_UnidadMedida"].ToString();
                        string _CodTipoOperatividad = dtProductoPrecio.Rows[0]["Cod_TipoOperatividad"].ToString();
                        if (ExisteProducto(_CodigoProducto) == false)
                        {
                            IU_SeleccionPlan _SeleccionPlan = new IU_SeleccionPlan(_IdProducto, _CodAlmacen);
                            if (_SeleccionPlan.ShowDialog() == DialogResult.OK)
                            {
                                string _CodPrecio = _SeleccionPlan.tv_SeleccionPlan.SelectedNode!=null? _SeleccionPlan.tv_SeleccionPlan.SelectedNode.Tag.ToString():"001";
                                string _NomPlan = _SeleccionPlan.tv_SeleccionPlan.SelectedNode != null ? _SeleccionPlan.tv_SeleccionPlan.SelectedNode.Text: "GENERAL";
                                DataTable dt_PrecioProducto = (new CProducto_precio()).RecuperarDetalleXCodPrecioyCodAlmacen(_CodigoProducto, cbCodAlmacen.SelectedValue.ToString(), _CodPrecio);
                                if (dt_PrecioProducto.Rows.Count > 0 && RecuperarPrecio(dt_PrecioProducto) != 0)
                                {

                                    dgv_Productos.Rows.Add();
                                    string _precio = RecuperarPrecio(dt_PrecioProducto).ToString();
                                    int fila = dgv_Productos.Rows.Count - 1;
                                    dgv_Productos.Rows[fila].Cells["Cod_Producto"].Value = _CodigoProducto;
                                    dgv_Productos.Rows[fila].Cells["Nom_Producto"].Value = _NombreProducto;
                                    dgv_Productos.Rows[fila].Cells["Precio"].Value = _precio;
                                    dgv_Productos.Rows[fila].Cells["Serie"].Value = _Serie;
                                    dgv_Productos.Rows[fila].Cells["Plan"].Value = _NomPlan;
                                    dgv_Productos.Rows[fila].Cells["Id_producto"].Value = _IdProducto;
                                    dgv_Productos.Rows[fila].Cells["Cod_Plan"].Value = _CodPrecio;
                                    dgv_Productos.Rows[fila].Cells["Cod_UnidadMedida"].Value = _CodUnidadMedida;
                                    dgv_Productos.Rows[fila].Cells["Cod_TipoOperatividad"].Value = _CodTipoOperatividad;
                                    CalcularPreciosTotales();
                                }
                                else
                                {
                                    if (RecuperarPrecio(dt_PrecioProducto) == 0)
                                    {
                                        dgv_Productos.Rows.Add();
                                        string _precio = "1";
                                        int fila = dgv_Productos.Rows.Count - 1;
                                        dgv_Productos.Rows[fila].Cells["Cod_Producto"].Value = _CodigoProducto;
                                        dgv_Productos.Rows[fila].Cells["Nom_Producto"].Value = _NombreProducto;
                                        dgv_Productos.Rows[fila].Cells["Precio"].Value = _precio;
                                        dgv_Productos.Rows[fila].Cells["Serie"].Value = _Serie;
                                        dgv_Productos.Rows[fila].Cells["Plan"].Value = _NomPlan;
                                        dgv_Productos.Rows[fila].Cells["Id_producto"].Value = _IdProducto;
                                        dgv_Productos.Rows[fila].Cells["Cod_Plan"].Value = _CodPrecio;
                                        dgv_Productos.Rows[fila].Cells["Cod_UnidadMedida"].Value = _CodUnidadMedida;
                                        dgv_Productos.Rows[fila].Cells["Cod_TipoOperatividad"].Value = _CodTipoOperatividad;
                                        CalcularPreciosTotales();
                                        tbBuscar.Text = "";
                                        tbBuscar.Focus();
                                    }
                                    else
                                    {
                                        MessageBox.Show("No existe un precio para dicho producto");
                                        //tbBuscar.Focus();
                                        tbBuscar.SelectionStart = 0;
                                        tbBuscar.SelectionLength = tbBuscar.Text.Length;
                                    }
                                    

                                }
                            }
                        }
                        else
                        {
                            MessageBox.Show("El producto ya esta en la lista");
                            //tbBuscar.Focus();
                            tbBuscar.SelectionStart = 0;
                            tbBuscar.SelectionLength = tbBuscar.Text.Length;
                        }
                    }
                    else //Seleccionar un producto de una lista
                    {
                        IU_SeleccionarProductos iSeleccionProducto = new IU_SeleccionarProductos(cbCodAlmacen.SelectedValue.ToString());
                        iSeleccionProducto.tbBuscar.Text = tbBuscar.Text;
                        iSeleccionProducto.Buscar();
                        if (iSeleccionProducto.ShowDialog() == DialogResult.OK)//Seleccionado solo uno
                        {
                            string _CodigoProducto = iSeleccionProducto.dgv_SeleccionarProductos.SelectedRows[0].Cells["Cod_Producto"].ToString();
                            string _NombreProducto = iSeleccionProducto.dgv_SeleccionarProductos.SelectedRows[0].Cells["Nom_Producto"].ToString();
                            string _Serie = iSeleccionProducto.dgv_SeleccionarProductos.SelectedRows[0].Cells["Serie"].ToString();
                            string _CodAlmacen = cbCodAlmacen.SelectedValue.ToString();
                            string _CodUnidadMedida = iSeleccionProducto.dgv_SeleccionarProductos.SelectedRows[0].Cells["Cod_UnidadMedida"].ToString();
                            string _CodTipoOperatividad = iSeleccionProducto.dgv_SeleccionarProductos.SelectedRows[0].Cells["Cod_TipoOperatividad"].ToString();
                            if (ExisteProducto(_CodigoProducto) == false)
                            {
                                IU_SeleccionPlan _SeleccionPlan = new IU_SeleccionPlan(int.Parse(iSeleccionProducto.dgv_SeleccionarProductos.SelectedRows[0].Cells["Id_Producto"].ToString()), _CodAlmacen);
                                if (_SeleccionPlan.ShowDialog() == DialogResult.OK)
                                {
                                    string _CodPrecio = _SeleccionPlan.tv_SeleccionPlan.SelectedNode.Tag.ToString();
                                    string _NomPlan = _SeleccionPlan.tv_SeleccionPlan.SelectedNode.Text;
                                    DataTable dt_PrecioProducto = (new CProducto_precio()).RecuperarDetalleXCodPrecioyCodAlmacen(_CodigoProducto, cbCodAlmacen.SelectedValue.ToString(), _CodPrecio);
                                    if (dt_PrecioProducto.Rows.Count > 0 && RecuperarPrecio(dt_PrecioProducto) != 0)
                                    {

                                        dgv_Productos.Rows.Add();
                                        string _precio = RecuperarPrecio(dt_PrecioProducto).ToString();
                                        int fila = dgv_Productos.Rows.Count - 2;
                                        dgv_Productos.Rows[fila].Cells["Cod_Producto"].Value = _CodigoProducto;
                                        dgv_Productos.Rows[fila].Cells["Nom_Producto"].Value = _NombreProducto;
                                        dgv_Productos.Rows[fila].Cells["Precio"].Value = _precio;
                                        dgv_Productos.Rows[fila].Cells["Serie"].Value = _Serie;
                                        dgv_Productos.Rows[fila].Cells["Plan"].Value = _NomPlan;
                                        dgv_Productos.Rows[fila].Cells["Cod_Plan"].Value = _CodPrecio;
                                        dgv_Productos.Rows[fila].Cells["Cod_UnidadMedida"].Value = _CodUnidadMedida;
                                        dgv_Productos.Rows[fila].Cells["Cod_TipoOperatividad"].Value = _CodTipoOperatividad;
                                        CalcularPreciosTotales();
                                        tbBuscar.Text = "";

                                    }
                                    else
                                    {
                                        MessageBox.Show("No existe un precio para dicho producto");
                                        tbBuscar.SelectionStart = 0;
                                        tbBuscar.SelectionLength = tbBuscar.Text.Length;
                                    }
                                }
                            }
                            else
                            {
                                MessageBox.Show("El producto ya esta en la lista");
                                tbBuscar.SelectionStart = 0;
                                tbBuscar.SelectionLength = tbBuscar.Text.Length;
                            }
                        }
                    }
                    tbBuscar.Focus();
                }
            }
            else
                KryptonMessageBox.Show("No Existe almacen Relacionado con esta Caja.", Principal.aTitulo, MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
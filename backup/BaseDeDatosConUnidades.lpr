program BaseDeDatosConUnidades;

uses ucomando, sysutils, unit1;













(*============================================================================*)
(****************************** BLOQUE PRINCIPAL ******************************)
(*============================================================================*)
begin

  registroPersona.Documento:='';
  registroPersona.Nombre:='';
  registroPersona.Apellido:='';
  registroPersona.Edad:=0;
  registroPersona.Peso:=0;
  registroPersona.Id:=0;



  {se asignan las constantes de tipo string a variables ya que no funcionan usando
  directamente las constantes dentro del case ELIMINAR}
  valorEliminarD:=PARAMETRO_ELIMINAR_DOC;
  valorEliminarT:=PARAMETRO_ELIMINAR_TODO;


  {-Asignamos y creamos el archivo o lo abrimos si ya está creado-}
  AssignFile (archivoDataBase, BD_NOMBRE_ORIGINAL);

  if FileExists (BD_NOMBRE_ORIGINAL) then begin
    reset (ArchivoDataBase);
  end else begin
    rewrite (archivoDataBase)
  end;
  {----------------------------------------------------------------------------}

  {Ponemos repeat hasta que la instrucción del menú principal sea salir}
  repeat

  cantidadRegActivos:=0;
  cantidadRegEliminados:=0;


    {PROMPT + Lectura comando + lectura datos}
    entradaPrompt();
    registroPersonaAux.documento:=objCom.listaParametros.argumentos[1].datoString;
    registroPersonaAux.Nombre:=objCom.listaParametros.argumentos[2].datoString;
    registroPersonaAux.Apellido:=objCom.listaParametros.argumentos[3].datoString;
    registroPersonaAux.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
    registroPersonaAux.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;




    case sysCom of  {>> INICIO CASE PRINCIPAL}


      NUEVO:begin {>> INICIO CASE "NUEVO"}

        {Comprueba el nº de parámetros. Se asocia la función a la variable booleana pruebaParametros.
        Si esto es false entonces lanza mensaje de error.
        Con el continue sale del bucle}
        prueba5Parametros:=NumParametrosCorrectos(objCom);
        if (prueba5Parametros=false) then begin
          writeln ('ERROR: Cantidad de parametros incorrecta: [DOCUMENTO, NOMBRE, APELLIDO, EDAD, PESO]');
          writeln;
          continue;
        end;

        {Comprueba que edad es un nº. Se asocia la función a la variable booleana pruebaEdad.
        Si esto es false entonces lanza mensaje de error.
        Con el continue sale del bucle.}
        pruebaEdad:=EdadEsNumero(objCom.listaParametros.argumentos[4].datoNumerico);
        if (pruebaEdad=false) then begin
          writeln ('El parametro EDAD debe ser numerico');
          writeln;
          continue;
        end;

        {Comprueba que peso es un nº. Se asocia la función a la variable booleana pruebaPeso.
        Si esto es false entonces lanza mensaje de error.
        Con el continue sale del bucle.}
        pruebaPeso:=PesoEsNumero(objCom.listaParametros.argumentos[5].datoNumerico);
        if (pruebaPeso=false) then begin
          writeln ('El parametro PESO debe ser numerico');
          writeln;
          continue;
        end;

        {Comprueba que el documento introducido no esté ya guardado en BD.
        Se asocia la función a la variable booleana pruebaDocumento.
        Si esto es false lanza mensaje de error. Con el continue sale del bucle.}
        pruebaDocumento:=YaExisteDocumento(registroPersonaAux);
        if ((pruebaDocumento=true) and (registroEliminado(registroPersona)=false)) then begin
          registroPersonaAux:=validDocumento(registroPersona); //////////////////////////////////////////////DUDA///////////////////////////////////
          if (pruebaDocumento=true) then begin
            writeln ('Ya EXISTE este numero de docuento >> [',registroPersonaAux.Documento,' ', registroPersonaAux.Nombre,' ',registroPersonaAux.Apellido,']');
            writeln;
            continue;
          end;
        end;

        {Si todas las validaciones se cumplen entonces llama a la función NuevoRegistro que la que permite guardar como tal}
        if (prueba5parametros=true) and (pruebaEdad=true) and (pruebaPeso) and (YaExisteDocumentoYNoEliminado(registroPersonaAux)=false) then begin
          NuevoRegistro(registroPersona.Documento, registroPersona.Nombre, registroPersona.Apellido, registroPersona.Id, registroPersona.edad, registroPersona.Peso,registroPersona.Eliminado);
          continue;
        end;

        ////////////////////////////////DUDA////////////////////////////////////////
        if (prueba5Parametros=true) and (pruebaEdad=true) and (PruebaPeso=true) and (pruebaDocumento=false) and (registroEliminado(registroPersona)) then begin
          modificarRegistroEliminado (objCom.listaParametros.argumentos[1].datoString, registroPersona, archivoDataBase);
        end;

        writeln;

      end;
{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FIN CASE "NUEVO"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}



      {Recibe 0 parámetros (para mostrar todos los registros) o 1 parámetro (documento, para
      mostrar un documento en concreto.
      Validaciones: que reciba 0 o un parámetro // que ingrese un documento que no exista o fue eliminado}

      BUSCAR:begin

        {Mientras que la cantidad de parámetros recibidos sean mayor que 1,mostrará error
        Debe recibir 0 o 1 parámetro}
        while (ObjCom.listaParametros.cantidad>1) do begin
          writeln ('La cantidad de parametros es incorrecta: [] o [DOCUMENTO]');
          writeln;
          EntradaPrompt();
          registroPersonaAux.documento:=objCom.listaParametros.argumentos[1].datoString;
          registroPersonaAux.Nombre:=objCom.listaParametros.argumentos[2].datoString;
          registroPersonaAux.Apellido:=objCom.listaParametros.argumentos[3].datoString;
          registroPersonaAux.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
          registroPersonaAux.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
          continue;
        end;

        {Si la cantidad de parámetros recibidos es 0, llama a la función buscarTodo}
        if (objCom.listaParametros.cantidad=0) then begin
          buscarTodo();
        end;

        writeln;

        if (objCom.listaParametros.cantidad=1) then begin
          buscarRegistro (objCom.listaParametros.argumentos[1].datoString, registroPersona, archivodataBase);
          writeln;
        end;

      end;
{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FIN CASE "BUSCAR"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}


      MODIFICAR: begin

        reset (archivoDataBase);

        {Comprueba el nº de parámetros. Se asocia la función a la variable booleana pruebaParametros.
        Si esto es false entonces lanza mensaje de error.
        Con el continue sale del bucle}
        prueba5Parametros:=NumParametrosCorrectos(objCom);
        if (prueba5Parametros=false) then begin
          writeln ('ERROR: Cantidad de parametros incorrecta: [DOCUMENTO, NOMBRE, APELLIDO, EDAD, PESO]');
          writeln;
          continue;
        end;

                {Comprueba que edad es un nº. Se asocia la función a la variable booleana pruebaEdad.
        Si esto es false entonces lanza mensaje de error.
        Con el continue sale del bucle.}
        pruebaEdad:=EdadEsNumero(objCom.listaParametros.argumentos[4].datoNumerico);
        if (pruebaEdad=false) then begin
          writeln ('El parametro EDAD debe ser numerico');
          writeln;
          continue;
        end;

        {Comprueba que peso es un nº. Se asocia la función a la variable booleana pruebaPeso.
        Si esto es false entonces lanza mensaje de error.
        Con el continue sale del bucle.}
        pruebaPeso:=PesoEsNumero(objCom.listaParametros.argumentos[5].datoNumerico);
        if (pruebaPeso=false) then begin
          writeln ('El parametro PESO debe ser numerico');
          writeln;
          continue;
        end;

        {Verificamos que el registro que vayamos a modificar exista en la BD}
        if not YaExisteDocumento(registroPersonaAux) then begin
          writeln ('El documento a modificar NO EXISTE');
          writeln;
          continue;
        end;

        {Verifica si el documento que vamos a modificar está activo(false) o inactivo(true)}
        if YaExisteDocumentoYNoEliminado(registroPersonaAux)=false then begin
          writeln ('El documento a modificar esta INACTIVO');
          writeln;
          continue;
        end;

        {Si pasa todas las validaciones anteriores, entra en la función de ModificarRegistro}
        modificarRegistro(objCom.listaParametros.argumentos[1].datoString, registroPersonaAux,archivoDataBase);
        writeln;

      end;
{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FIN CASE "MODIFICAR"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}

       {ELIMINAR: ingresar comando "-T" o -"D documento".
       -Si ingresa "-T" --> se borra todo el archivo (sólo parametro -T)
       -Si se ingresa "D documento se "oculta" un registro en concreto,
       no se podrá buscar ni modificar. Si no se ingresan los 2 parametros vuelca error. Si todo es correcto, mensaje ok}
       ELIMINAR:begin
         reset(archivoDataBase);

         {Comparamos los strings para verificar si coincide con la orden -T o -D y lo asignamos a una variable string}
         compareEliminarD:=compareStr (valorEliminarD, objCom.listaParametros.argumentos[1].datoString)=0;  {>> True si coinciden}
         compareEliminarT:=compareStr (valorEliminarT,objCom.listaParametros.argumentos[1].datoString)=0;   {>> True si coinciden}

         {Validamos que los parametros recibidos estén entre 1 y 2}
         if (ObjCom.listaParametros.cantidad=0) or (ObjCom.listaParametros.cantidad>2) then begin
           writeln ('ERROR: Cantidad de parametros incorrecta: [-T] o [-D + Documento]');
           writeln;
           continue;
         end;

         {Verifica que los parametros recibidos sean -D o -T, y no otros}
         if not (compareEliminarT) then begin
           if not (compareEliminarD) then begin
             writeln ('ERROR: El argumento no es correcto o faltan datos');
             writeln;
             continue;
           end;
         end;

         {Si es -D le indicamos que tiene que llevar asociado un nº de documento,
         es decir, tiene que llevar otro parámetro más (2)}
         if (compareEliminarD) then begin
           if (objCom.listaParametros.cantidad<>2) then begin
             writeln ('ERROR:  Cantidad de parametros incorrecta: [-D + Documento]');
             writeln;
             continue;
           end;
         end;

         {Si es -D y el documento a eliminar ya existe y esta eliminado mostramos mensaje de error}
         if (compareEliminarD) and (YaexisteDocumentoParaEliminar(registroPersona)=false) then begin
           writeln ('ERROR: No hay un registro con documento ',objCom.listaParametros.argumentos[2].datoString,' para eliminar.');
           writeln;
           continue;
         end;

         {Si el string es -T, llamamos a la función eliminarTodo}
         if (compareEliminarT) then begin
          eliminarTodo();
          writeln;
          continue;
         end;


         {Validación Eliminar -D: recibe un documento y además ese documento existe
         Llamamos a la función que pasa el eliminado de False a true y mostramos mensaje de confirmación.}
         if ((objCom.listaParametros.cantidad>0) and (ObjCom.listaParametros.cantidad<=2)) and (compareEliminarD) and (YaExisteDocumentoParaEliminar(registroPersona)) then begin
          PasarDeFalseAtrue (objCom.listaParametros.argumentos[2].datoString, archivoDataBase);
          writeln('ELIMINACION CORRECTA');
          writeln;
         end;
       end;
{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FIN CASE "ELIMINAR"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}

       {Lo que hace es un resumen de los registros totales, los activos y los eliminados.
       No recibe ningún parametro, se valida esto a traves del if (<>0)}

       ESTADOSIS:begin

       if ObjCom.listaParametros.cantidad<>0 then begin
        writeln ('La cantidad de parametros es incorrecta []');
        writeln;
        continue;
       end;

       {Si la cantidad de registros totales (FileSize) es 0, pone también los registros activos
       y los eliminados a 0.
       Por el contrario si la cantidad de registstros totales es diferente a 0, llama a las funciones de
       contar eliminados y contar Activos. }
       if FileSize(archivoDataBase)=0 then begin
           cantidadRegEliminados:=0;
           cantidadRegActivos:=0;
       end else if FileSize(archivoDataBase)<>0 then begin
           cantidadRegEliminados:=contarRegEliminados(archivoDataBase);
           cantidadRegActivos:=contarRegActivos(archivoDataBase);
       end;



          {Muestra el resumen de los registros totales en pantalla.}
          writeln ('Registros Totales: ',FileSize(archivoDataBase),' / Cantidad de registros activos: ',contarRegActivos(archivoDataBase),
                  ' / Cantidad de registros eliminados: ',contarRegEliminados(archivoDataBase));
          writeln;

         ;


     end;
{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FIN CASE "ESTADOSIS"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}


      {Lo que hace realmente es crear un archivo para copiar los registros que están como
      eliminados.false y quedan fuera (por tanto eliminados definitivamente) los registros que
      estan marcados como eliminados.true.
      No controla los parámetros recibidos.
      Crea un archivo temporal nuevo.
      Se copian al archivo temporal los registros que no estén eliminados (en false)
      Se borra el archivo original.
      Se renombra el nuevo archivo con el nombre que tenía el anterior}
      OPTIMIZAR:begin

        if (optimizacion(archivoDataBase)=true) then begin
         writeln ('Optimimación exitosa');
         writeln;
         continue;
        end else begin
          writeln ('No se ha podido optimizar la base de datos');
          writeln;
          continue;
        end;

      end;
{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FIN CASE "OPTIMIZAR"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}


        {Else es el comando por defecto: si no introduce cualqiera de los cases anteriores
        muestra un error}
        else
        writeln ('Comando NO VALIDO');
        writeln;



  end; {>>FIN CASE PRINCIPAL}

  until sysCom=SALIR ;{>>Fin repeat}

  readln;
end.{PRINCIPAL}


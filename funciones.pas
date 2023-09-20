unit funciones;



interface
  uses
  Classes, SysUtils, UComando;


  const
        (*Lista de comandos en String*)
        COMANDO_NUEVO_TEXTO= 'NUEVO';
        COMANDO_MODIFICAR_TEXTO= 'MODIFICAR';
        COMANDO_ELIMINAR_TEXTO= 'ELIMINAR';
        COMANDO_BUSCAR_TEXTO= 'BUSCAR';
        COMANDO_OPTIMIZAR_TEXTO= 'OPTIMIZAR';
        COMANDO_ESTADOSIS_TEXTO= 'ESTADOSIS';
        COMANDO_SALIR_TEXTO= 'SALIR';
        PARAMETRO_ELIMINAR_DOC= '-D';
        PARAMETRO_ELIMINAR_TODO= '-T';

        (*Formatos para imprimir datos de salida como una tabla*)
        FORMAT_ID= '%6s';
        FORMAT_DOCUMENTO= '%11s';
        FORMAT_NOMBRE_APELLIDO= '%21s';
        FORMAT_EDAD_PESO= '%6s';
        COLUMNA_ID= 'ID';
        COLUMNA_DOCUMENTO= 'DOCUMENTO';
        COLUMNA_NOMBRE= 'NOMBRE';
        COLUMNA_APELLIDO= 'APELLIDO';
        COLUMNA_EDAD= 'EDAD';
        COLUMNA_PESO= 'PESO';

        (*Simplemente el prompt de entrada en la consola*)
        PROMPT= '>> ';

        (*Nombre de archivo de la base de datos.*)
        BD_NOMBRE_ORIGINAL= 'BD Tomy';
        (*Nombre de archivo temporal de la base de datos*)
        BD_NOMBRE_TEMPORAL= 'tempDataBase_ka.tmpka';

  type
    {Identifica a los comandos admitidos por el sistema.
     * NUEVO: Permitirá crear nuevos registros.
     * MODIFICAR: Permitirá modificar registros existentes.
     * ELIMINAR: Permitirá eliminar registros existentes.
     * BUSCAR: Permitirá buscar y mostrar registros exitentes.
     * ESTADOSIS: Muestra información de la base de datos.
     * OPTIMIZAR: Limpiará la base de datos de registros eliminados.
     * SALIR: Cierra el programa.
     * INDEF: Comando indefinido. Se utiliza para indicar errores.}
    TComandosSistema= (NUEVO,MODIFICAR,ELIMINAR,BUSCAR,ESTADOSIS,OPTIMIZAR,SALIR,INDEF);

    {Representa el registro de una persona en el sistema.}
    TRegistroPersona= packed record
       Id: int64;
       Nombre, Apellido: String[20];
       Documento: String[10];
       Edad, Peso: byte;
       Eliminado: boolean;
    end;

    {El archivo en el que se guardarán los datos.}
    TBaseDeDatos= file of TRegistroPersona;


  {--------------------------------VARIABLES-------------------------------------}
  var entradaEstandar, documentoAux, valorEliminarD, valorEliminarT: String;
      sysCom: TComandosSistema;
      objCom: TComando;
      archivoDataBase, archivoTempBase: TBaseDeDatos;
      registroPersona, registroPersonaAux: TRegistroPersona;
      i, cantidadRegActivos, cantidadRegEliminados: integer;
      Prueba5Parametros, pruebaEdad, pruebaPeso, pruebaDocumento, pruebaEliminado,
        ElDocExiste, pruebaDoc, compareEliminarT, compareEliminarD: boolean;





    {Recibe un comando c de tipo TComando y retorna su equivalente en
    TComandoSistema. Esta operación simplemente verifica que el nombre
    del comando c sea igual a alguna de las constantes COMANDO definidas
    en este archivo. Concretamente si:

    * El nombre de c es igual a COMANDO_NUEVO_TEXTO retorna TComandosSistema.NUEVO
    * El nombre de c es igual a COMANDO_MODIFICAR_TEXTO retorna TComandosSistema.MODIFICAR
    * El nombre de c es igual a COMANDO_ELIMINAR_TEXTO retorna TComandosSistema.ELIMINAR
    * El nombre de c es igual a COMANDO_BUSCAR_TEXTO retorna TComandosSistema.BUSCAR
    * El nombre de c es igual a COMANDO_ESTADOSIS_TEXTO retorna TComandosSistema.ESTADOSIS
    * El nombre de c es igual a COMANDO_OPTIMIZAR_TEXTO retorna TComandosSistema.OPTIMIZAR
    * El nombre de c es igual a COMANDO_SALIR_TEXTO retorna TComandosSistema.SALIR

    En cualquier otro caso retorna TComandosSistema.INDEF.}
    function comandoSistema(const c: TComando): TComandosSistema;





    {Retorna una línea de texto formada por 78 guiones}
    function stringSeparadorHorizontal(): String;





    {Retorna una línea de texto que forma el encabezado de la salida al imprimir
    los registros.}
    function stringEncabezado(): String;





    {Retorna una línea de texto formada por los datos del registro reg para que
    queden vistos en formato de columnas}
    function stringFilaRegistro(const reg: TRegistroPersona): String;





    {Muestra el prompt y separa el comando de la entrada estandar}
    procedure EntradaPrompt ();





    {Comprueba que la cantidad de parámetros introducidos sean justo 5}
    function NumParametrosCorrectos (var parametroEntrada:TComando):boolean;





    {Comprueba que el parámetro recibido "EDAD" es de tipo numérico}
    function EdadEsNumero (edadPersona:byte):boolean;





    {Comprueba que el parámetro recibido "PESO" es de tipo numérico}
    function PesoEsNumero (edadPersona:byte):boolean;





    {Recibe un registtro de tipo TPersona que sera la persona que vayamos a comprobar
    con los que ya existen en la BD
    Si el documento comparado es igual (es decir, existe) entonces asignamos la variable
    booleana como true para devolverla fuera de la función.
    Si no existe el documento introducido dentro de la BD, devuelve False}
    function YaExisteDocumento (personaAcomprobar:TRegistroPersona):boolean;





    {Abre el archivo. Lee el fichero y la persona a comprobar. Si llega a un registro
    que tiene el parámetro Eliminado como true, la función devuelve un true
    En caso contrario, si la persona que comprobamos tiene el Eliminado en false,
    devuelve un false}
    function registroEliminado (var personaAcomprobar:TRegistroPersona):boolean;




    {Abre el archivo. Lee el fichero y la persona a comprobar. Al llegar a un registro
    compara el documento introducido con los de la BD y también comprueba que el parámetro
    Eliminado se encuentre en false. Si se cumplen ambas condiciones devuelve un true}
    function YaExisteDocumentoYNoEliminado (var personaAcomprobar:TRegistroPersona):boolean;



    {-----------------FUNCIÓN DESTINADA AL COMANDO ELIMINAR -D----------------------
    Abre el archivo y lee las personas que están en el documento.
    En este caso realiza una comparación con el 2º parámetro introducido, ya que el primero
    sería el -D, seguido del documento de la persona.
    Si coincide el documento, y además el atributo de Eliminado está en false, la función
    lanza un True.}
    function YaExisteDocumentoParaEliminar (personaAcomprobar:TRegistroPersona):boolean;





    {-----------------FUNCIÓN DESTINADA AL COMANDO ELIMINAR -D----------------------
    Abre el archivo y lee las personas que están en el documento.
    En este caso realiza una comparación con el 2º parámetro introducido, ya que el primero
    sería el -D, seguido del documento de la persona. Si los documentos coinciden lanza
    devuelve el resultado al tipo TRegistroPersona}
    function validDocumentoEliminar(personaAcomprobar:TRegistroPersona):TRegistroPersona;






    {Esta función recibe un registro de Tipo TRegistroPersona y devuelve uno igual.
    Lee el archivo hasta el final, comparando el documento introducido (con el comando
    MODIFICAR) con los que hay en la BD. Si coincide (es decir, si existe) devuelve
    el registro de la persona que ha coincidido.
    En caso contrario, no devuelve nada.}
    function validDocumento (personaAcomprobar:TRegistroPersona):TRegistroPersona;





    {Función utilizada para comprobar si en el comando NUEVO se introduce un número
    de documento que ya exista en la BD. Si ya existe en la BD la función devuelve un
    true, en caso contrario un FALSE}
    function EsDocumentoRepetido (documentoPersona:string; personaAcomprobar:TRegistroPersona):boolean;





    {FUNCIÓN VÁLIDA PARA ELIMINAR -D
    Compreba primero si existe la persona a eliminar. Si no eiste lanza un false.
    Recibe un documento (aunque no se está usando, lo coge del registro que lee en la
    base de datos) y pasa la propiedad de ese registro de Eliminado.False a
    Eliminado.True}
    function PasarDeFalseAtrue (documentopersona: string; var baseDato:TBaseDeDatos):boolean;





    {Recibe todos los parámetros del tipo TRegistroPersona y devuelve un registro del mismo tipo.
    A registroPersona se le asignan los parámetros introducidos por el usuario, se pone +1
    en Id para que vaya sumando uno y se pone por defecto el valor de Eliminado en false.
    Si cumple todas las validaciones del case se posiciona en la última posición libre
    del archivo y escribe lo que hayamos pasado.
    Finalmente, cierra el archivo.}
    function NuevoRegistro (documentoPersona, nombrePersona, apellidoPersona:string;
                           idPersona, edadPersona, pesoPersona:byte; eliminadoPersona:boolean):TRegistroPersona;




    {Función para case MODIFICAR.
    Recibe el documento introducido y todos los parámetros de la persona a modificar.
    Recibe por referencia la BD y devuelve True o False.
    Variables: registroNuevo para guardar los nuevos datos y registroValidado para otener
    los datos que nos devuelve la función ValidDocumento.
    Nos posicionamos dentro del archivo en el ID del registro que queremos modificar
    (-1 porque las posiciones en el archivo empiezan en 0.
    registroNuevo.Id:=registroValidado.Id; - para dejar el mismo ID del registro que queremos modificar.
    El resto es pasar los datos recogidos por la entrada estandar a la variable registroNuevo.
    Escribimos el registroNuevo en el archivo y mostramos mensaje de confirmación al usuario.}
    function modificarRegistro (documentoLeido:string; personaAmodificar:TRegistroPersona;
                               var baseDatos:TBaseDeDatos):boolean;






    {Esta función se usa para modificar un registro que ha sido marcado como eliminado
    anteriormente. Es decir, si he "eliminado" el documento 2, y ahora quiero agregar un
    reg nuevo con ese mismo documento esta func mantiene el nº de documento con otros datos
    diferentes.
    Abre el fichero, comprueba el documento de la persona y lo pasa a registroValidado.
    Se posiciona en el fichero y pasa todos los atributos de la persona a RegistroValidado, dejando
    el Eliminado de nuevo en False (ya que cuenta como un registro nuevo).
    Se escribe en la base de datos el nuevo registro.}
    function modificarRegistroEliminado (documentoLeido:string; personaAmodificar:TRegistroPersona;
                                         var baseDatos:TBaseDeDatos):boolean;





    {Esta función muestra en pantalla los registros que estén como activos (eliminados en false).
    Lee el archivo persona por persona. Si el atributo eliminado no esta en true entonces lo
    escribe.
    Con el segundo if nos ayuda a mostrar el resumen que aparece bajo la tabla mostrando
    el total de registros encontrados}
    procedure buscarTodo();






    {Busca un registro en concreto mediante el documento. Se busca el documento en la BD
    y si se coincide el de la BD con el que ha introducido el usuario la variable controlDocumento
    sería un true.
    Con el if se hacen las validaciones (tiene que estar el eliminado en false y existe el documento
    escribe los encabados de la tabla y el registro de la persona que hemos buscado.
    Si no cumple las validaciones lanza un mensaje de error.}
    function buscarRegistro(documento: String; var reg: TRegistroPersona; var archivo: TBaseDeDatos): boolean;




    {Abre el archivo y lo lee hasta el final.
    Se posiciona con el Id de la persona y va pasando el Eliminado a true.
    Vuelve a posicionarse en el archivo y lo escribe. Si todo está correcto devuelve
    true en la función y cierra el archivo.}
    function eliminarTodo():TRegistroPersona;




    {Pone el contador a 0, abre la BD y lee registro a regisro.
    Si la persona eliminada se encuentra en False (es decir, no está eliminada y está
    activa) entonces suma uno al contador.
    Devuelve el resultado (es decir, las veces que ha contado) fuera de la función}
    function contarRegActivos (var baseDatos:TBaseDeDatos):byte;





    {Pone el contador a 0, abre la BD y lee registro a regisro.
    Si la persona eliminada se encuentra en True (es decir, está eliminada y está
    inactiva) entonces suma uno al contador.
    Devuelve el resultado (es decir, las veces que ha contado) fuera de la función}
    function contarRegEliminados (var baseDatos:TBaseDeDatos):byte;






    {Con el assignFile crea el archivo temporal y se posiciona en la posición 0 del archivo original.
    Lee el fichero orginal y lee las personas que no están eliminadas (en false) y las escribe
    en el fichero temporal.
    Cuando termina cierra los 2 ficheros}
    function optimizacion (var baseDatos:TBaseDeDatos):boolean;












implementation



function comandoSistema(const c: TComando): TComandosSistema;

begin
      if CompareText(nombreComando(c),COMANDO_NUEVO_TEXTO)=0 then
         result:= TComandosSistema.NUEVO
      else if CompareText(nombreComando(c),COMANDO_MODIFICAR_TEXTO)=0 then
         result:= TComandosSistema.MODIFICAR
      else if CompareText(nombreComando(c),COMANDO_ELIMINAR_TEXTO)=0 then
         result:= TComandosSistema.ELIMINAR
      else if CompareText(nombreComando(c),COMANDO_BUSCAR_TEXTO)=0 then
         result:= TComandosSistema.BUSCAR
      else if CompareText(nombreComando(c),COMANDO_ESTADOSIS_TEXTO)=0 then
         result:= TComandosSistema.ESTADOSIS
      else if CompareText(nombreComando(c),COMANDO_OPTIMIZAR_TEXTO)=0 then
         result:= TComandosSistema.OPTIMIZAR
      else if CompareText(nombreComando(c),COMANDO_SALIR_TEXTO)=0 then
         result:= TComandosSistema.SALIR
      else
         result:= TComandosSistema.INDEF;
end;



function stringSeparadorHorizontal(): String;

var i: byte;

begin
      result:= '';
      for i:=1 to 78 do
          result+= '-';
  end;



function stringEncabezado(): String;

begin
  result:= Format(FORMAT_ID,[COLUMNA_ID])+'|'+Format(FORMAT_DOCUMENTO,[COLUMNA_DOCUMENTO])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_NOMBRE])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_APELLIDO])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_EDAD])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_PESO]);
end;



function stringFilaRegistro(const reg: TRegistroPersona): String;

begin
  result:= Format(FORMAT_ID,[IntToStr(reg.Id)])+'|'+
           Format(FORMAT_DOCUMENTO,[reg.Documento])+'|'+
           Format(FORMAT_NOMBRE_APELLIDO,[reg.Nombre])+'|'+
           Format(FORMAT_NOMBRE_APELLIDO,[reg.Apellido])+'|'+
           Format(FORMAT_EDAD_PESO,[Inttostr(reg.Edad)])+'|'+
           Format(FORMAT_EDAD_PESO,[Inttostr(reg.Peso)]);
end;



procedure EntradaPrompt ();

begin
  write (PROMPT);
  readln (entradaEstandar);
  objCom:=crearComando(entradaEstandar);
  sysCom:=comandoSistema(objCom);
end;



function NumParametrosCorrectos (var parametroEntrada:TComando):boolean;

begin
  if (parametroEntrada.listaParametros.cantidad <> 5) then begin
    result:=false;
  end else begin
    result:=true
  end;
end;



function EdadEsNumero (edadPersona:byte):boolean;

begin
  if not (esParametroNumerico (objCom.listaParametros.argumentos[4])) then begin
    result:=false
  end else begin
      result:=true
  end;
end;



function PesoEsNumero (edadPersona:byte):boolean;

begin
  if not (esParametroNumerico (objCom.listaParametros.argumentos[5])) then begin
    result:=false
  end else begin
      result:=true
  end;
end;



function YaExisteDocumento (personaAcomprobar:TRegistroPersona):boolean;

var controlParametros:boolean;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);

    controlParametros:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[1].datoString)=0;
    if controlParametros=true then begin
      result:=true;
      exit;
    end;
  end;

  result:=false;

end;



function registroEliminado (var personaAcomprobar:TRegistroPersona):boolean;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);

    if (personaAcomprobar.Eliminado=true) then begin
      result:=true;
      exit;
    end;
  end;

  result:=false;

end;



function YaExisteDocumentoYNoEliminado (var personaAcomprobar:TRegistroPersona):boolean;

var coincideDocumento:boolean;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);

    coincideDocumento:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[1].datoString)=0;

    if (personaAcomprobar.Eliminado=false) and (coincideDocumento=true) then begin
      result:=true;
      exit;
    end;
  end;

  result:=false;

end;



function YaExisteDocumentoParaEliminar (personaAcomprobar:TRegistroPersona):boolean;

var coincideDocumento:boolean;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);

    coincideDocumento:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[2].datoString)=0;

    if coincideDocumento=true then begin
      if personaAcomprobar.Eliminado=false then begin
        result:=true;
        exit;
      end;
    end;
  end;

  result:=true;

end;



function validDocumentoEliminar(personaAcomprobar:TRegistroPersona):TRegistroPersona;

var coincideDocumento:boolean;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);

    coincideDocumento:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[2].datoString)=0;

    if coincideDocumento=true then begin
      result:=personaAcomprobar;
      exit;
    end;
  end;
end;




function validDocumento (personaAcomprobar:TRegistroPersona):TRegistroPersona;

var coincideDocumento:boolean;
    personaRespuesta: TRegistroPersona;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);

    coincideDocumento:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[1].datoString)=0;

    if coincideDocumento=true then begin
      result:=personaAcomprobar;
      exit;
    end;
  end;

  result:=personaRespuesta;

end;



function EsDocumentoRepetido (documentoPersona:string; personaAcomprobar:TRegistroPersona):boolean;

begin
    reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaAcomprobar);
    if (compareStr (personaAcomprobar.Documento, ObjCom.listaParametros.argumentos[1].datoString)=0) then begin
      result:=true;
      exit;
    end;
  end;

  result:=false;

  CloseFile (archivoDataBase);

end;



function PasarDeFalseAtrue (documentopersona: string; var baseDato:TBaseDeDatos):boolean;

var personaAEliminar: TRegistroPersona;

begin
  if not YaExisteDocumentoParaEliminar(registroPersona) then begin
    result:=false;
    exit;
  end;

  reset (archivoDataBase);
  seek (archivoDataBase, (personaAeliminar.Id)-1);
  read (archivoDataBase,personaAeliminar);
  personaAEliminar.Eliminado:=true;
  seek (archivoDataBase, (personaAeliminar.Id)-1);
  write (archivoDataBase,personaAeliminar);
end;



function NuevoRegistro (documentoPersona, nombrePersona, apellidoPersona:string;
                       idPersona, edadPersona, pesoPersona:byte; eliminadoPersona:boolean):TRegistroPersona;

begin
  registroPersona.Documento:=objCom.listaParametros.argumentos[1].datoString;
  registroPersona.Nombre:=objCom.listaParametros.argumentos[2].datoString;
  registroPersona.Apellido:=objCom.listaParametros.argumentos[3].datoString;
  registroPersona.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
  registroPersona.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
  registroPersona.Id:=registroPersonaAux.Id+1;
  registroPersona.Eliminado:=false;

  reset (archivoDataBase);
  seek (archivoDataBase, FileSize(archivoDataBase));
  write (archivoDataBase, registroPersona);
  writeln ('Registro agregado correctamente :)');
  writeln;

  CloseFile (archivoDataBase);
end;



function modificarRegistro (documentoLeido:string; personaAmodificar:TRegistroPersona;
                           var baseDatos:TBaseDeDatos):boolean;

var registroNuevo, registroValidado: TRegistroPersona;

begin
  reset (archivoDataBase);

  {Se llama a la función validDocumento para obtener la persona con la que coincida el
  documento ingresado por el usuario.Cuando coincide el documento esta función devolvía
  todos los datos y todo esto lo asignamos a la var registroValidado. Con este paso
  evitamos que los atributos que no se vayan a modificar se pierdan.}
  registroValidado:=validDocumento (registroPersona);

  seek (baseDatos, (registroValidado.Id)-1);
  registroNuevo.Id:=registroValidado.Id;
  registroNuevo.Documento:=objCom.listaParametros.argumentos[1].datoString;
  registroNuevo.Nombre:=objCom.listaParametros.argumentos[2].datoString;
  registroNuevo.Apellido:=objCom.listaParametros.argumentos[3].datoString;
  registroNuevo.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
  registroNuevo.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
  registroNuevo.Eliminado:=false;

  write (baseDatos, registroNuevo);

  writeln ('Registro modificado correctamente');

  CloseFile (archivoDataBase);
end;



function modificarRegistroEliminado (documentoLeido:string; personaAmodificar:TRegistroPersona;
                                     var baseDatos:TBaseDeDatos):boolean;

var nuevoRegistro, registroValidado:TRegistroPersona;

begin
  reset (archivoDataBase);

  registroValidado:=validDocumento (registroPersona);

  seek (baseDatos, (registroValidado.Id)-1);
  nuevoRegistro.Id:=registroValidado.Id;
  nuevoRegistro.Documento:=objCom.listaParametros.argumentos[1].datoString;
  nuevoRegistro.Nombre:=objCom.listaParametros.argumentos[2].datoString;
  nuevoRegistro.Apellido:=objCom.listaParametros.argumentos[3].datoString;
  nuevoRegistro.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
  nuevoRegistro.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
  nuevoRegistro.Eliminado:=false;

  write (baseDatos, nuevoRegistro);

  writeln ('Registro modificado correctamente :)');

  CloseFile (archivoDataBase);
end;



procedure buscarTodo();

var it, contadorRegistros: byte;

begin
  reset (archivoDataBase);
  contadorRegistros:=0;
  writeln (stringEncabezado()); // Encabezado de la tabla de datos.
  writeln (stringSeparadorHorizontal());

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, registroPersona);

      if not registroPersona.Eliminado=true then begin
        writeln (stringFilaRegistro(registroPersona));
      end;

      {para el mensaje que resume el nº de registros encontrados}
      if registroPersona.Eliminado=false then begin
        contadorRegistros:=contadorRegistros+1;
      end;
  end;

  writeln;

  if FileSize(archivoDataBase)=0 then begin
    writeln ('No hay registros encontrados');
  end;

  writeln ('Registros encontrados: ',contadorRegistros);
end;



function buscarRegistro(documento: String; var reg: TRegistroPersona; var archivo: TBaseDeDatos): boolean;

var controlDocumento:boolean;

begin

  reset (archivoDataBase);

  while not eof (archivo) do begin
    read (archivo, reg);

    controlDocumento:=compareStr(reg.Documento, documento)=0;

    if (reg.Eliminado=false) and (controlDocumento=true) then begin
      writeln (stringEncabezado()); {>>Encabezado de la tabla de datos}
      writeln (stringSeparadorHorizontal());
      writeln (stringFilaRegistro(registroPersona));
    end else if (reg.Eliminado=true) and (controlDocumento=true) then begin
      writeln ('No existe un registro con DOCUMENTO ',reg.Documento);
    end;
  end;

end;


function eliminarTodo():TRegistroPersona;

var personaEliminada: TRegistroPersona;

begin
  reset (archivoDataBase);

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaEliminada);

    reset (archivoDataBase);
    seek (archivoDataBase, (personaEliminada.Id) -1);
    read (archivoDataBase, personaEliminada);
    personaEliminada.Eliminado:=true;
    seek (archivoDataBase, (personaEliminada.Id) -1);
    write (archivoDataBase, personaEliminada);

    result:=personaEliminada;
  end;

  CloseFile (archivoDataBase);
end;


function contarRegActivos (var baseDatos:TBaseDeDatos):byte;

var it,contador:byte; personaLeida:TRegistroPersona;

begin
  contador:=0;
  reset (baseDatos);

  while not eof (baseDatos) do begin
    read (baseDatos, personaLeida);
      if (personaLeida.Eliminado=false) then begin
        contador:=contador+1;
      end;
  end;

  result:=contador;
end;


function contarRegEliminados (var baseDatos:TBaseDeDatos):byte;

var it,contador:byte; personaLeida:TRegistroPersona;

begin
  contador:=0;
  reset (baseDatos);

  while not eof (baseDatos) do begin
    read (baseDatos, personaLeida);
      if personaLeida.Eliminado=true then begin
        contador:=contador+1;
      end;
  end;

  result:=contador;
end;


function optimizacion (var baseDatos:TBaseDeDatos):boolean;

var archivoTemporal:TBaseDeDatos;
    it:byte;
    personaLeida: TRegistroPersona;

begin
  AssignFile (archivoTemporal,BD_NOMBRE_TEMPORAL);
  rewrite (archivoTemporal);
  seek (baseDatos,0); {>>se posiciona en el archivo original}

  reset (baseDatos);
  while not eof (baseDatos) do begin
    read (baseDatos,personaLeida);
    if personaLeida.Eliminado=false then begin
      write (archivoTemporal, personaLeida);
    end;
  end;

  Close (baseDatos);
  Close (archivoTemporal);


  {Si no puede borrar el archivo original lanza un false y con el AssignFile lo
  vuelve a crear y con el DeleteFile borra el temporal.
  Por el contrario, si se puede borrar el original, hace un cambio de nombre, y
  una vez hecho el cambio de nombre hace el AssignFile y lo abre como si fuese el original
  (que ya fue borrado)}
  if not DeleteFile (BD_NOMBRE_ORIGINAL) then begin
    result:=false;
    AssignFile (baseDatos, BD_NOMBRE_ORIGINAL);
    reset (baseDatos);
    DeleteFile (BD_NOMBRE_TEMPORAL);
  end else begin
    RenameFile (BD_NOMBRE_TEMPORAL, BD_NOMBRE_ORIGINAL);
    AssignFile (baseDatos, BD_NOMBRE_ORIGINAL); {>>>>>>>>>PTE VERIFICAR QUE HACE}
    reset (baseDatos);
  end;

  result:=true;
end;

end.


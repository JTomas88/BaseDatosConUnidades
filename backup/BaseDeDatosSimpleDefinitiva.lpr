program BaseDeDatosSimpleDefinitiva;

uses ucomando, sysutils;

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




{--------------------------------FORDWARS-------------------------------------}
//function registroEliminado(var persona:TRegistroPersona): boolean; forward;
function modificarRegistro (documentoLeido:string; personaAmodificar:TRegistroPersona; var baseDatos: TBaseDeDatos):boolean ; forward;







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




{Retorna una línea de texto formada por 78 guiones}
function stringSeparadorHorizontal(): String;

var i: byte;

begin
      result:= '';
      for i:=1 to 78 do
          result+= '-';
  end;




{Retorna una línea de texto que forma el encabezado de la salida al imprimir
los registros.}
function stringEncabezado(): String;

begin
  result:= Format(FORMAT_ID,[COLUMNA_ID])+'|'+Format(FORMAT_DOCUMENTO,[COLUMNA_DOCUMENTO])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_NOMBRE])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_APELLIDO])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_EDAD])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_PESO]);
end;




{Retorna una línea de texto formada por los datos del registro reg para que
queden vistos en formato de columnas}
function stringFilaRegistro(const reg: TRegistroPersona): String;

begin
  result:= Format(FORMAT_ID,[IntToStr(reg.Id)])+'|'+
           Format(FORMAT_DOCUMENTO,[reg.Documento])+'|'+
           Format(FORMAT_NOMBRE_APELLIDO,[reg.Nombre])+'|'+
           Format(FORMAT_NOMBRE_APELLIDO,[reg.Apellido])+'|'+
           Format(FORMAT_EDAD_PESO,[Inttostr(reg.Edad)])+'|'+
           Format(FORMAT_EDAD_PESO,[Inttostr(reg.Peso)]);
end;




{Muestra el prompt y separa el comando de la entrada estandar}
procedure EntradaPrompt ();

begin
  write (PROMPT);
  readln (entradaEstandar);
  objCom:=crearComando(entradaEstandar);
  sysCom:=comandoSistema(objCom);
end;




{Comprueba que la cantidad de parámetros introducidos sean justo 5}
function NumParametrosCorrectos (var parametroEntrada:TComando):boolean;

begin
  if (parametroEntrada.listaParametros.cantidad <> 5) then begin
    result:=false;
  end else begin
    result:=true
  end;
end;




{Comprueba que el parámetro recibido "EDAD" es de tipo numérico}
function EdadEsNumero (edadPersona:byte):boolean;

begin
  if not (esParametroNumerico (objCom.listaParametros.argumentos[4])) then begin
    result:=false
  end else begin
      result:=true
  end;
end;




{Comprueba que el parámetro recibido "PESO" es de tipo numérico}
function PesoEsNumero (edadPersona:byte):boolean;

begin
  if not (esParametroNumerico (objCom.listaParametros.argumentos[5])) then begin
    result:=false
  end else begin
      result:=true
  end;
end;




{Recibe un registtro de tipo TPersona que sera la persona que vayamos a comprobar
con los que ya existen en la BD
Si el documento comparado es igual (es decir, existe) entonces asignamos la variable
booleana como true para devolverla fuera de la función.
Si no existe el documento introducido dentro de la BD, devuelve False}
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




{Abre el archivo. Lee el fichero y la persona a comprobar. Si llega a un registro
que tiene el parámetro Eliminado como true, la función devuelve un true
En caso contrario, si la persona que comprobamos tiene el Eliminado en false,
devuelve un false}
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



{Abre el archivo. Lee el fichero y la persona a comprobar. Al llegar a un registro
compara el documento introducido con los de la BD y también comprueba que el parámetro
Eliminado se encuentre en false. Si se cumplen ambas condiciones devuelve un true}
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


{-----------------FUNCIÓN DESTINADA AL COMANDO ELIMINAR -D----------------------
Abre el archivo y lee las personas que están en el documento.
En este caso realiza una comparación con el 2º parámetro introducido, ya que el primero
sería el -D, seguido del documento de la persona.
Si coincide el documento, y además el atributo de Eliminado está en false, la función
lanza un True.}
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




{-----------------FUNCIÓN DESTINADA AL COMANDO ELIMINAR -D----------------------
Abre el archivo y lee las personas que están en el documento.
En este caso realiza una comparación con el 2º parámetro introducido, ya que el primero
sería el -D, seguido del documento de la persona. Si los documentos coinciden lanza
devuelve el resultado al tipo TRegistroPersona}
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






{Esta función recibe un registro de Tipo TRegistroPersona y devuelve uno igual.
Lee el archivo hasta el final, comparando el documento introducido (con el comando
MODIFICAR) con los que hay en la BD. Si coincide (es decir, si existe) devuelve
el registro de la persona que ha coincidido.
En caso contrario, no devuelve nada.}
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




{Función utilizada para comprobar si en el comando NUEVO se introduce un número
de documento que ya exista en la BD. Si ya existe en la BD la función devuelve un
true, en caso contrario un FALSE}
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




{FUNCIÓN VÁLIDA PARA ELIMINAR -D
Compreba primero si existe la persona a eliminar. Si no eiste lanza un false.
Recibe un documento (aunque no se está usando, lo coge del registro que lee en la
base de datos) y pasa la propiedad de ese registro de Eliminado.False a
Eliminado.True}
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
  seek (archivoDataBase, (personaAeliminar.Id)-1); ////////PROBAR QUE SUCEDE SI LO QUITO
  write (archivoDataBase,personaAeliminar);
end;




{Recibe todos los parámetros del tipo TRegistroPersona y devuelve un registro del mismo tipo.
A registroPersona se le asignan los parámetros introducidos por el usuario, se pone +1
en Id para que vaya sumando uno y se pone por defecto el valor de Eliminado en false.
Si cumple todas las validaciones del case se posiciona en la última posición libre
del archivo y escribe lo que hayamos pasado.
Finalmente, cierra el archivo.}
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




{Esta función muestra en pantalla los registros que estén como activos (eliminados en false).
Lee el archivo persona por persona. Si el atributo eliminado no esta en true entonces lo
escribe.
Con el segundo if nos ayuda a mostrar el resumen que aparece bajo la tabla mostrando
el total de registros encontrados}
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





{Busca un registro en concreto mediante el documento. Se busca el documento en la BD
y si se coincide el de la BD con el que ha introducido el usuario la variable controlDocumento
sería un true.
Con el if se hacen las validaciones (tiene que estar el eliminado en false y existe el documento
escribe los encabados de la tabla y el registro de la persona que hemos buscado.
Si no cumple las validaciones lanza un mensaje de error.}
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



{Abre el archivo y lo lee hasta el final.
Se posiciona con el Id de la persona y va pasando el Eliminado a true.
Vuelve a posicionarse en el archivo y lo escribe. Si todo está correcto devuelve
true en la función y cierra el archivo.}
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



{Pone el contador a 0, abre la BD y lee registro a regisro.
Si la persona eliminada se encuentra en False (es decir, no está eliminada y está
activa) entonces suma uno al contador.
Devuelve el resultado (es decir, las veces que ha contado) fuera de la función}
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




{Pone el contador a 0, abre la BD y lee registro a regisro.
Si la persona eliminada se encuentra en True (es decir, está eliminada y está
inactiva) entonces suma uno al contador.
Devuelve el resultado (es decir, las veces que ha contado) fuera de la función}
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





{Con el assignFile crea el archivo temporal y se posiciona en la posición 0 del archivo original.
Lee el fichero orginal y lee las personas que no están eliminadas (en false) y las escribe
en el fichero temporal.
Cuando termina cierra los 2 ficheros}
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


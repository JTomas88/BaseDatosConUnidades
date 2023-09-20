program BaseDeDatosSimple;

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
      BASEDEDATOS_NOMBRE_REAL= 'data.dat';
      (*Nombre de archivo temporal de la base de datos*)
      BASEDEDATOS_NOMBRE_TEMPORAL= 'tempDataBase_ka.tmpka';

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
var entradaEstandar, documentoAux: String;
    sysCom: TComandosSistema;
    objCom: TComando;
    archivoDataBase, archivoTempBase: TBaseDeDatos;
    registroPersona: TRegistroPersona;
    i, cantidadRegActivos, cantidadRegEliminados: integer;
    pruebaParametros, pruebaEdad, pruebaPeso, pruebaDocumento, pruebaEliminado,
      ElDocExiste, pruebaDoc, compareEliminarT, compareEliminarD: boolean;




{--------------------------------FORDWARS-------------------------------------}
function comprobarRegEliminados(var persona:TRegistroPersona): boolean; forward;
function modificarRegistro (documentoLeido:string; personaAmodificar:TRegistroPersona;
         var baseDatos: TBaseDeDatos):boolean ; forward;


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

  {Busca en el arhivo, un registro con el documento indicado y lo asigna a reg
  retornando TRUE. Si no existe en el archivo un registro con el documento indicado
  entonces retorna FALSE.}
  function buscarRegistro(documento: String; var reg: TRegistroPersona; var archivo: TBaseDeDatos): boolean;
  begin

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

(*============================================================================*)
(****************************** BLOQUE PRINCIPAL ******************************)
(*============================================================================*)
begin

  registroPersona.Documento:='';
  registroPersona.Nombre:='';
  registroPersona.Apellido:='';
  registroPersona.Edad:=0;
  registroPersona.Peso:=0;
  registtroPersona.Id:=0;


  {-Asignamos y creamos el archivo o lo abrimos si ya está creado-}
  AssignFile (archivoDataBase, BASEDATOS_NOMBRE_REAL);

  if FileExists (BASEDATOS_NOMBRE_REAL) then begin
    reset (ArchivoDataBase);
  end else begin
    rewrite (archivoDataBase)
  end;
  {----------------------------------------------------------------------------}

  {Ponemos repear hasta que la instrucción del menú principal sea salir}
  repeat





  until ;

  readln;
end.{PRINCIPAL}


UNIT TAD_IMAGEN;

INTERFACE

TYPE
	// Carácter que representa un pixel 
	tPixel = word;
	
	// Almacena las coordenadas que indican la posición de los píxeles en la lista
	tCoordenadas = record
				x : longint;
				y : longint;
			end;

	// Lista enlazada de PIXELES
	tListaPixel = ^tNodosPixel;

	tNodosPixel = record
				pixel : tPixel;
				sigp  : tListaPixel;
				cord  : tCoordenadas;
			end;
	
	// Lista enlazada de FILAS DE PIXELES
	tImagen = ^tNodosFilas;

	tNodosFilas = record
				nodo  : tListaPixel;
				clave : longint;
				sign  : tImagen;
			end;

	
	
	// Fichero que almacena la imagen 
	tFicheroImagen = text;

PROCEDURE calcError(error:integer);
FUNCTION strToInt(tamImg: string): longint;
PROCEDURE CrearListaFilas(numFilas: longint; var ptrImagen : tImagen);
PROCEDURE CrearUnaListaPixeles(linea: longint; numPixeles: longint; var nodo: tListaPixel; pixel: tPixel);
PROCEDURE CrearListasPixeles(linea: longint;  numPixeles: longint; ptrImagen : tImagen; pixel: tPixel);
PROCEDURE VerListaFilas(ptrImagen : tImagen; var pixBlanco:longint; var pixNegro: longint);
PROCEDURE LeerFicheroImagen(var ficheroImagen: tFicheroImagen; nombreFichero: string; var ptrImagen: tImagen; var tamanioImagen:longint);
PROCEDURE verbose(ptrImagen : tImagen; ficheroFinal: string; tamImg:longint);
//PROCEDURE pedirImagen(var imagen:tImagen; var tamanio:longint);

IMPLEMENTATION

PROCEDURE calcError(error:integer);

Begin

	case error of
			{Errores del Dos}
			2 : writeln('Archivo no encontrado');
			3 : writeln('Path no encontrado');
			4 : writeln('Demasiados archivos abiertos');
			5 : writeln('Acceso denegado');
			6 : writeln('Variable de manipulacion de archivo invalida');
			12 : writeln('Modo de acceso al archivo invalido');
			15 : writeln('Numero de disco invalido');
			16 : writeln('No se puede borrar el actual directorio');
			17 : writeln('No puede renombrar al otro lado de los volumenes');
			{Errores de entrada y salida}
			100 : writeln('Error cuando se intentaba leer desde el disco');
			101 : writeln('Error cuando se intentaba escribir en el disco');
			102 : writeln('Archivo no asignado o adjuntado');
			103 : writeln('Archivo no abierto');
			104 : writeln('Archivo no abierto para entrada');
			105 : writeln('Archivo no abierto para salida de datos');
			106 : writeln('Numero invalido');
			{Errores fatales}
			150 : writeln('Disco esta protegido para escritura');
			151 : writeln('Dispositivo desconocido');
			152 : writeln('Disco no listo');
			153 : writeln('Comando desconocido');
			154 : writeln('Chequeo de CRC fallado');
			155 : writeln('Disco especificado invalido');
			156 : writeln('Fallo al buscar en el disco');
			157 : writeln('Tipo invalido');
			158 : writeln('Sector no encontrado');
			159 : writeln('Impresora sin papel');
			160 : writeln('Error cuando se intentaba escribir en el dispositivo');
			161 : writeln('Error cuando se intentaba leer desde el dispositivo');
			162 : writeln('Fallo del Hardware');
		end;
End;

{ En esta función recibimos como parámetro un string que convertiremos en un longint,
es decir, el programa recibe por ejemplo una cadena que es '100' y nos devuelve
un entero largo 100 }

FUNCTION strToInt(tamImg: string): longint;

Begin
	val(tamImg,strToInt);
end;

{ Este procedure es el que , a partir del tamaño de la imagen, creará el puntero a la primera fila
y enlazará las filas que haya en la imagen.

Recibe como parámetro numFilas (longint) y ptrImagen(tImagen), el primero por valor y el segundo
por variable, ya que necesita modificarse para que apunte a la primera fila. }

PROCEDURE CrearListaFilas(numFilas: longint; var ptrImagen: tImagen);
var	
	i: longint;
	filas: tImagen; 
	filasAux: tImagen;
Begin
	i:=1;
	new(filas); // Creamos un nodo filas
	ptrImagen := filas; // Hacemos que ptrImagen apunte al primer nodo
	filas^.nodo := nil; // De momento no hay lista de pixeles, con lo que apuntará a nil
	filas^.clave:= i; // El valor de la clave es el número de la fila que es
	filas^.sign := nil; // Y el siguiente nodo de momento es nil
	while (i < numFilas) do // Creamos un bucle que crea todas las demas filas, de la 2 hasta la n.
		begin
			i := i + 1; // Incrementamos el número de fila en el que se encuentra
			new(filasAux); // Creamos nodo auxiliar
			filasAux^.clave:= i; // Ponemos el número de fila 
			filasAux^.nodo := nil; // Como sigue sin existir lista de pixeles apuntamos a nil
			filasAux^.sign := nil; // El siguiente nodo es nil
			filas^.sign := filasAux; // Y aquí ya enlazamos el puntero anterior con el nuevo.
			filas := filas^.sign; // Y ponemos que filas sea filas.sign para que el bucle siga su curso
		end;	
End;

{ Este procedure, a partir de la línea en la que nos encontramos, el tamaño de la imagen, el nodo
de tipo tListaPixel y el pixel que le pasan, creará la lista de píxeles

Recibe como parámetro linea (longint), numPixeles (longint), nodo (tListaPixel) y pixel (tPixel)
todo ello por valor, salvo nodo, que llegará por variable }

PROCEDURE CrearUnaListaPixeles(linea: longint; numPixeles: longint; var nodo: tListaPixel; pixel: tPixel);
var	
	i: longint;
	listaPixel: tListaPixel;
	listaPixelAux: tListaPixel;

Begin
	i := 1; // La variable i nos dará la coordenada x de nuestros nodos.
	listaPixelAux := nodo; // Inicializa tPixelAux que será con el que trabajaremos siempre
				// para no pisar el puntero a nodo primero.
	if (nodo=nil) // Si el nodo es nil, está vacío, creamos el primer pixel de la lista.
		then begin
				new(listaPixel);
				nodo := listaPixel;				
				listaPixel^.pixel:= pixel;
				listaPixel^.sigp := nil;
				listaPixel^.cord.y := i;
				listaPixel^.cord.x := linea;
			end
	else begin
		i := i + 1;
		while(listaPixelAux^.sigp <> nil) do
			begin
					listaPixelAux := listaPixelAux^.sigp;
					i := i + 1;
			end;
			new(listaPixel);	
			listaPixel^.pixel:= pixel;
			listaPixel^.sigp := nil;
			listaPixel^.cord.y := i;
			listaPixel^.cord.x := linea;
			listaPixelAux^.sigp := listaPixel;	
		end;

End;


{ Con este procedure calculamos en qué fila estamos para pasarsela luego a CrearUnaListaPixeles

Recibe linea (longint), numPixeles(longint), ptrImagen (tImagen) y pixel ( tPixel), todo por valor }

PROCEDURE CrearListasPixeles(linea: longint;  numPixeles: longint; ptrImagen : tImagen; pixel: tPixel);
Var Aux : tImagen;
Begin
	Aux := ptrImagen;
	while((Aux <> nil) and (linea > Aux^.clave)) do
		begin
			Aux := Aux^.sign;
		end;
	CrearUnaListaPixeles(linea ,numPixeles, Aux^.nodo, pixel); 
end;

{ Este procedure recibe como parámetros ptrImagen de tipo tImagen (por valor) y por variable recibe 
pixBlanco y pixNegro de tipo longint, son contadores de píxeles blancos y negros que posee la imagen.
El procedimiento recorre la imagen en memoria y cuenta los píxeles blancos y negros que hay. }

PROCEDURE VerListaFilas(ptrImagen : tImagen; var pixBlanco:longint; var pixNegro: longint);
Var Aux : tImagen;
    AuxPixel : tListaPixel;
Begin
	Aux := ptrImagen;
	while(Aux <> nil) do
		begin
			AuxPixel := Aux^.nodo;
			while(AuxPixel <> nil) do
				begin
					if (AuxPixel^.pixel=0)
						then pixBlanco := pixBlanco + 1
					else if (AuxPixel^.pixel=1)
						then pixNegro := pixNegro + 1;
					AuxPixel := AuxPixel^.sigp;
				end;
			Aux := Aux^.sign;
		end;


end;

{ El procedure leerFicheroImagen recibe como parámetros ficheroImagen de tipo tImagen(por variable),
nombreFichero de tipo string(por valor), ptrImagen de tipo tImagen (por variable) y tamanioImagen
de tipo longint (por variable). Este procedure principal recibe un fichero de texto y crea la
imagen a partir de él. }

PROCEDURE LeerFicheroImagen(var ficheroImagen: tFicheroImagen; nombreFichero: string; var ptrImagen : tImagen; var tamanioImagen:longint);
var 
	charPixel: char;
	tamanioImg  : string;
	cuentaLineas: word;
	//tamanioImagen: longint;
Begin

	cuentaLineas:= 0;
	if (nombreFichero <> '')
		then assign(ficheroImagen, nombreFichero)
	else ficheroImagen := Input;
	{$I-}reset(ficheroImagen);{$I+}
	if (ioresult<>0) then calcError(ioresult)
	else begin
	while not eof (ficheroImagen) do
	begin
		while not eoln (ficheroImagen) do
		begin
			if (cuentaLineas = 0) 
				then begin
					// Leer primera línea completa ...
					readln (ficheroImagen, tamanioImg);
					// Comprobamos si es potencia de 2 ...
					tamanioImagen := strToInt(tamanioImg);
					CrearListaFilas(tamanioImagen, ptrImagen);
					cuentaLineas:= cuentaLineas + 1;
				     end
				else begin
					// Leer líneas, carácter a carácter ...
					read (ficheroImagen, charPixel);
					CrearListasPixeles(cuentaLineas,tamanioImagen,ptrImagen,strToInt(charPixel));
					// Añadir píxel a lista de píxeles ...

				    end;
		end;
		cuentaLineas:= cuentaLineas + 1;
		readln(ficheroImagen);
	end;
	
	close(ficheroImagen);
	end;
end;

{ Procedure verbose, recibe como parámetros ptrImagen de tipo tImagen(por valor), comprimir de tipo 
boolean (por valor), ficheroFinal de tipo string (por valor) y tamImg de tipo longint (por valor).
El procedure cálcula las estadísticas después de leer la imagen y generar el árbol, calcula el 
número de píxeles blancos y negros que hay y el ratio de la imagen. }

PROCEDURE verbose(ptrImagen : tImagen; ficheroFinal: string; tamImg:longint);
var
	blanco, negro:longint;
	f: file of byte;
	tamByte:longint;
	ratio:real;
Begin	
	blanco := 0;
	negro := 0;

	writeln('La dimension de la imagen es ',tamImg,' x ',tamImg);
	tamImg := tamImg * tamImg;
	verListaFilas(ptrImagen,blanco,negro);
	writeln('Hay ',blanco,' pixeles blancos');
	writeln('Hay ',negro,' pixeles negros');
	assign(f,ficheroFinal);
	reset(f);
	tamByte := Filesize(f);
	ratio := tamImg/(tamByte-2);
	writeln('El ratio de la imagen es ', ratio:0:2);

End;


END.
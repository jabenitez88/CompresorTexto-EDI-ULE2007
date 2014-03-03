UNIT TAD_QUADTREE;

INTERFACE

USES tad_imagen, tad_binario, tad_cola;

FUNCTION damePixel(imagen: tImagen; x : longint; y : longint): tPixel;
PROCEDURE ponPixel(var imagen: tImagen; x : longint; y : longint; pixel:tPixel);
FUNCTION valorCuadrante (imagen : tImagen; x0 : longint; y0: longint; xF: longint; yF: longint):byte ;
PROCEDURE generarArbol(imagen : tImagen; var raiz : TQuadTree; x0 : longint; y0: longint; xF: longint; yF: longint);
PROCEDURE guardarArbol( raiz : tQuadTree; tamImg: longint; ficheroFinal: string);
PROCEDURE nuevoArbol(var raiz:tQuadTree ; pixel: tQPixelArbol);
PROCEDURE leerFichByte(nomFichByte: string; var raiz:tQuadTree; var tamanio:longint);
PROCEDURE generarImagen(var imagen : tImagen; raiz : TQuadTree; x0 : longint; y0: longint; xF: longint; yF: longint; var contador:longint);
PROCEDURE guardarImagen(imagen : tImagen; tamImg: longint; ficheroFinal: string);

IMPLEMENTATION

{ La función damePixel recibe como parámetros imagen de tipo tImagen, y las coordenadas x e y de tipo
longint, y devuelve un tPixel. Todo lo que recibe es por valor. La función lo que hace es devolver
qué pixel hay en el nodo que posee de coordenadas [x,y] es decir, si ponemos damePixel(imagen,1,2)
nos devolverá el valor del pixel que se encuentra en la imagen en la posición 1,2.}

FUNCTION damePixel(imagen: tImagen; x : longint; y : longint): tPixel;
Var Aux : tImagen;
    AuxPixel: tListaPixel;
Begin
	Aux := imagen;
	AuxPixel := Aux^.nodo;
	while((aux <> nil) AND (x > AuxPixel^.cord.x)) do
		begin
			aux := aux^.sign;
			AuxPixel := Aux^.nodo;
		end;
	while((aux^.nodo <> nil) AND (y > AuxPixel^.cord.y)) do
				begin
					AuxPixel := AuxPixel^.sigp;
				end;
	damePixel := AuxPixel^.pixel; 

end;

PROCEDURE ponPixel(var imagen: tImagen; x : longint; y : longint; pixel:tPixel);
Var Aux : tImagen;
    AuxPixel: tListaPixel;
Begin
	Aux := imagen;
	AuxPixel := Aux^.nodo;
	while((aux <> nil) AND (x > AuxPixel^.cord.x)) do
		begin
			aux := aux^.sign;
			AuxPixel := Aux^.nodo;
		end;

	while((aux^.nodo <> nil) AND (y > AuxPixel^.cord.y)) do
				begin
					AuxPixel := AuxPixel^.sigp;
				end;

	AuxPixel^.pixel := pixel;

end;

{ La función valorCuadrante recibe como parámetros imagen de tipo tImagen, y las coordenadas x0,y0,xF
e yF todo ello por parámetro y devuelve un byte. La función recibe las coordenadas iniciales, por ejemplo
1,1 y las finales, 8,8 del archivo imagen y calcula si los pixeles que hay entre esos 2 intervalos son 
todo ceros, todo unos (blancos, negros ) o son diferentes }

FUNCTION valorCuadrante (imagen : tImagen; x0 : longint; y0: longint; xF: longint; yF: longint):byte ;
Var i : longint;
    j : longint;
    pixelInic : tPixel;
    pixelAlea : tPixel;
    valorCuad : byte;

Begin
	i := x0;
	j := y0;
	pixelInic := damePixel(imagen,x0,y0);
	pixelAlea := damePixel(imagen,i,j);
	valorCuad := 0;

	while ((pixelAlea = pixelInic) AND (i <= xF)) do
		begin
			while ((pixelAlea = pixelInic) AND (j <= yF)) do
					begin	
						pixelAlea := damePixel(imagen,i,j);
						if ((pixelAlea = pixelInic) AND (pixelAlea = 0))
							then valorCuad := 48
						else if ((pixelAlea = pixelInic) AND (pixelAlea = 1))
							then valorCuad := 49
						else valorCuad := 0;
						//writeln(valorCuadrante);

						j := j +1;
					end;
			j := y0;
			i := i + 1;
		end;
	valorCuadrante := valorCuad;
		
				
End;

{ Recibe como parámetros cuad de tipo word, las coordenadas x0,y0,xF,yF de tipo longint y las
nuevas coordenadas que va a crear sx0,sy0,sxF y syF también de tipo longint, estas últimas por 
variable y lo demás por valor. El procedure se encarga de calcular las nuevas coordenadas de los
subcuadrantes. }

PROCEDURE calcularCoordenadas(cuad:word; x0, y0, xF, yF:longint;var sx0, sy0, sxF, syF:longint);
var n:longint;
begin
	n:=(xF-x0) div 2;
	case cuad of
		1: begin
			sx0:=x0;
			sy0:=y0;
			sxF:=x0+n;
			syF:=y0+n;
		end;
		2: begin
			sx0:=x0;
			sy0:=y0+n+1;
			sxF:=x0+n;
			syF:=yF;	
		end;
		3: begin
			sx0:=x0+n+1;
			sy0:=y0;
			sxF:=xF;
			syF:=y0+n;				
		end;
		4: begin
			sx0:=x0+n+1;
			sy0:=y0+n+1;
			sxF:=xF;
			syF:=yF;
		end;
	end;
end;

{ Procedure generarArbol recibe imagen de tipo tImagen (por valor), la raiz de tipo tQuadTree (por
variable) y las coordenadas x0,y0,xF e yF (por valor). Es uno de los procedures principales, se apoya
en otros anteriores como valorCuadrante y calcularCoordenadas y en definitiva es el proceso que comprime
las imágenes de forma recursiva.}

PROCEDURE generarArbol(imagen : tImagen; var raiz : TQuadTree; x0 : longint; y0: longint; xF: longint; yF: longint);
Var	
	valorHoja: tQPixelArbol;
	sx0, sy0, sxF, syF: longint;
Begin
	sx0:=0;
	sy0:=0;
	sxF:=0;
	syF:=0;

	valorHoja := valorCuadrante(imagen,x0,y0,xF,yF);
	
	if (raiz = nil)
		then begin
			new(raiz);
			raiz^.hoja:= valorHoja;
			raiz^.hijo1 := nil;
			raiz^.hijo2 := nil;
			raiz^.hijo3 := nil;
			raiz^.hijo4 := nil;
			end;
	
	if (raiz^.hoja = 0)
		then begin
			calcularCoordenadas(1,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarArbol(imagen,raiz^.hijo1,sx0,sy0,sxF,syF);

			calcularCoordenadas(2,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarArbol(imagen,raiz^.hijo2,sx0,sy0,sxF,syF);

			calcularCoordenadas(3,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarArbol(imagen,raiz^.hijo3,sx0,sy0,sxF,syF);

			calcularCoordenadas(4,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarArbol(imagen,raiz^.hijo4,sx0,sy0,sxF,syF);

			end;	
		
End;

{ Este procedure, guardarArbol, recibe como parámetros raiz de tipo tQuadTree (por valor),
tamImg de tipo longint(por valor, el tamaño de la imagen), y fichFinal de tipo string
(por valor), que es el nombre del fichero byte que se va a crear. Recorre el arbol
que hemos generado anteriormente y lo guarda en un fichero de tipo byte utilizando
la unidad tad_cola, aumentando la eficiencia del programa.}

PROCEDURE guardarArbol( raiz : tQuadTree; tamImg: longint; ficheroFinal: string);

var C:tCola;
    f: file of Byte;
    tamImgBin : string;
    byteUnoS, byteDosS: string;
    byteUno, byteDos: byte;
  
begin
	
	// Pasamos el tamanio de la imagen a binario y lo dividimos en 2 bytes
	tamImgBin := decToBin(tamImg,16);
	byteUnoS := copy(tamImgBin,1,8);
	byteDosS := copy(tamImgBin,9,16);
	byteUno := binToDec(byteUnoS,8);
	byteDos := binToDec(byteDosS,8);

	assign(f,ficheroFinal);
	{$I-}rewrite(f);{$I+}
	if (ioresult<>0) then calcError(ioresult)
	else begin

	ColaVacia(C);
	write(f, byteUno);
	write(f, byteDos);

	if (raiz <> nil)
		then begin Poner(C, raiz);
			while not EsVacia(C) do
				begin
					quitar(C, raiz);
					write(f, raiz^.hoja);				
			if (raiz^.hoja = 0) 
						then begin
							poner(C, raiz^.hijo1);
							poner(C, raiz^.hijo2);
							poner(C, raiz^.hijo3);
							poner(C, raiz^.hijo4);
							end;//end del if raiz hoja
				end;// end del while!!!
			end;// end del primer if raiz <> nil
	close(f);
	end;
end;

PROCEDURE nuevoArbol(var raiz:tQuadTree; pixel: tQPixelArbol);

begin
	new(raiz);
	raiz^.hoja := pixel;
	raiz^.hijo1 := nil;
	raiz^.hijo2 := nil;
	raiz^.hijo3 := nil;
	raiz^.hijo4 := nil;
end;

PROCEDURE leerFichByte(nomFichByte: string; var raiz:tQuadTree; var tamanio:longint);

VAR
	pixel, pixel1 : tQPixelArbol;
	aux : tQuadTree;
	fichByte: file of byte;
	tamanioS, pixelS, pixel1S: string;
	cuentaBytes, i: longint;
	c : tCola;
Begin
	aux := nil;
	cuentaBytes := 0;

	ColaVacia(C);
	assign(fichByte,nomFichByte);
	{$I-}reset(fichByte);{$I+}
	if (ioresult<>0) then calcError(ioresult)
	else begin

	while not eof (fichByte) do
		begin
			if (cuentaBytes=0)
				then begin
					read(fichByte,pixel);
					read(fichByte,pixel1);
					pixelS := decToBin(pixel,8);
					pixel1S:= decToBin(pixel1,8);
					tamanioS := pixelS + pixel1S;
					tamanio := binToDec(tamanioS,16);
					read(fichByte,pixel);
					nuevoArbol(raiz, pixel);
					aux := raiz;
					poner(c, aux);
					cuentaBytes := 1;
					end
			else	begin
					while not EsVacia(C) do
					begin
						quitar(c,aux);
						for i:=1 to 4 do
							begin
								read(fichByte,pixel);
								case i of
									1:begin
										nuevoArbol(aux^.hijo1,pixel);
										if(aux^.hijo1^.hoja = 0) then poner(c,aux^.hijo1);
										
									end;
									2:begin
										nuevoArbol(aux^.hijo2,pixel);
										if(aux^.hijo2^.hoja = 0) then poner(c,aux^.hijo2);
										
									end;
									3:begin
										nuevoArbol(aux^.hijo3,pixel);
										if(aux^.hijo3^.hoja = 0) then poner(c,aux^.hijo3);
										
									end;
									4:begin
										nuevoArbol(aux^.hijo4,pixel);
										if(aux^.hijo4^.hoja = 0) then poner(c,aux^.hijo4);
										
									end;
								end;//end del case
							end;//end del for
							if Not (EsVacia(c))
								then aux := primero(c)
							else aux := nil;
							
						end;//end del while
			
				end;//end del else
		end;
	close(fichByte);
	end;

End;

PROCEDURE generarImagen(var imagen : tImagen; raiz : TQuadTree; x0 : longint; y0: longint; xF: longint; yF: longint; var contador:longint);
var
	i,j :longint;
	aleat : tPixel;
	sx0, sy0, sxF, syF: longint;
Begin
	sx0:=0;
	sy0:=0;
	sxF:=0;
	syF:=0;

	if (contador=0)
		then begin
			aleat := 0;
			crearListaFilas(xF,Imagen);
			for i:=1 to xF do
				begin
				for j:=1 to yF do
					begin
					crearListasPixeles(i,yF,Imagen,aleat);
					end;
				end;
			contador := 1;
			end;
	if ((raiz^.hoja = 49) and (contador<>0))
		then begin
			aleat := 1;
			for i:=x0 to xF do
				begin
				for j:=y0 to yF do
					begin
					ponPixel(imagen,i,j,aleat);
					end;
				end;
			end
				
	else if(raiz^.hoja = 0)
		then begin
			calcularCoordenadas(1,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarImagen(imagen,raiz^.hijo1,sx0,sy0,sxF,syF,contador);

			calcularCoordenadas(2,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarImagen(imagen,raiz^.hijo2,sx0,sy0,sxF,syF,contador);

			calcularCoordenadas(3,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarImagen(imagen,raiz^.hijo3,sx0,sy0,sxF,syF,contador);

			calcularCoordenadas(4,x0,y0,xF,yF,sx0,sy0,sxF,syF);
			generarImagen(imagen,raiz^.hijo4,sx0,sy0,sxF,syF,contador);
		end;

end;

PROCEDURE guardarImagen(imagen : tImagen; tamImg: longint; ficheroFinal: string);

var  f: text;
     x, y :longint;
     pixelB: byte;
  
begin
	assign(f,ficheroFinal);
	{$I-}rewrite(f);{$I+}
	if (ioresult<>0) then calcError(ioresult)
	else begin
	writeln(f,tamImg);
			
	for x:=1 to tamImg do
		begin
		for y:=1 to tamImg do
			begin
			pixelB:= damePixel(imagen,x,y);
			write(f,pixelB);
			end;
		writeln(f);
		end;			
	close(f);
	end;
		
end;

END.

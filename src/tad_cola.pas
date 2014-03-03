UNIT TAD_COLA;

INTERFACE

TYPE
	tQPixelArbol = byte;

	tQuadTree = ^tNodoArbol;

	tNodoArbol = record
				hoja   : tQPixelArbol;	// Tambien se le puede llamar "raiz" ...
				hijo1 : tQuadTree;
				hijo2 : tQuadTree;
				hijo3 : tQuadTree;
				hijo4 : tQuadTree;
			end;

	PNodoCola=^TnodoCola;
	TCola=record
		cab, fin:PnodoCola;
		end;
	TnodoCola=record
		Info:tQuadTree;
		Sig:PNodoCola;
		End;

PROCEDURE ColaVacia(var C:tCola);
FUNCTION EsVacia(C:tCola):boolean;
FUNCTION Primero(C:tCola):tQuadTree;
PROCEDURE Poner(var C:tCola; arbol:tQuadTree);
PROCEDURE Quitar(var C:tCola; var arbol:tQuadTree);
PROCEDURE Suprimir(var C:tCola);

IMPLEMENTATION

PROCEDURE ColaVacia(var C:tCola);
Begin
	C.cab:=nil;
	C.fin:=nil;
End;

FUNCTION EsVacia(C:tCola):boolean;
Begin
	EsVacia:= C.cab=nil;
End;

FUNCTION Primero(C:tCola):tQuadTree;
Begin
if Not EsVacia(C)
	then Primero:=C.cab^.Info;
end;

PROCEDURE Poner(var C:tCola; arbol:tQuadTree);
var aux:PNodoCola;
Begin
	new(aux);
	aux^.Info:=arbol;
	aux^.Sig:=nil;

	If EsVacia(C)
		then
		begin
			C.Cab:=aux;
			C.fin:=aux;
		end
		else
		begin
			C.fin^.sig:=aux;
			C.fin:=aux;
		end;
End;

PROCEDURE Suprimir(var C:tCola);
var aux:PNodoCola;
begin
if not EsVacia(C) then
	begin 
		aux:=C.cab;
		C.cab:=C.Cab^.sig;
		If c.cab=nil then c.fin:=nil;
		dispose(aux);
	end;
end;

PROCEDURE Quitar (var C:tCola; var arbol:tQuadTree);

begin
	If not esvacia(c) then
		begin
			arbol:=Primero(c);
			Suprimir(c);
			end;
end;

END.
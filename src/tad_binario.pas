UNIT TAD_BINARIO;

INTERFACE

FUNCTION decToBin (cociente:longint; n:longint):string;
FUNCTION calcPotencia(exp:byte):longint;
FUNCTION binToDec(num:string; n:longint):longint;

IMPLEMENTATION

FUNCTION decToBin (cociente:longint; n:longint):string;

VAR numBin,resto:String;
	tamanio, cerosF, i:byte;
Begin
	numBin:='';

	while(cociente>=2) do 
		begin
			str(cociente mod 2,resto);
			numBin := resto + numBin;	
			cociente := cociente div 2;
		end;
  
	// Se añade el cociente al numero binario.
	str(cociente, resto);
	numBin:= resto + numBin;

	// Lo convertimos a nbits
	tamanio := length(numBin);
	if (tamanio<n) then begin
			cerosF:=(n-tamanio);
	for i:=1 to cerosF do numBin := '0' + numBin;
	end;

    decToBin := numBin;
    end;


FUNCTION calcPotencia(exp:byte):longint;
var valor:longint;
	i:byte;
begin
	valor:=1;
	for i:=1 to exp do valor*=2;
	calcPotencia:=valor;	
end;

FUNCTION binToDec(num:string; n:longint):longint;

var posicion, i:byte;
	valor:longint;
begin
	valor:=0;
	for i:=n downto 1 do 
	begin
		posicion:=n-i;		
		if (num[i]='1') 
			then valor:= valor + calcPotencia(posicion);
	end;
	binToDec := valor;
end;


END.

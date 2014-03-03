PROGRAM ppzip_test2;

USES GetOpts,tad_imagen, tad_quadtree, tad_cola, tad_binario;

VAR

	c: char;
	optionindex : Longint;
	theopts : array[1..3] of TOption;
	hay_output, hay_verbose, hay_c, hay_e, hay_f, hay_entrar: boolean;
	fichero_output,fichero_f:string;
	// Añadido
	ficheroImagen: tFicheroImagen;
	Imagen : tImagen;
	quadTree, nquadTree :tQuadTree;
	i,j : longint;

BEGIN
	i:=0;
	j := 0;
	quadTree := nil;
	hay_output:=false;
	hay_verbose:=false;
	hay_c:=false;
	hay_e:=false;
	hay_f:=false;
	hay_entrar:=true;
	fichero_output:='';
	fichero_f:='';


	with theopts[1] do
	begin
		name := 'output';
		has_arg := Required_Argument;
		flag := nil;
		value := #0;
	end;
	with theopts[2] do
	begin
		name := 'verbose';
		has_arg := No_Argument;
		flag := nil;
		value := #1;
	end;
	with theopts[3] do begin
		name:='';
		has_arg:=No_Argument;
		flag:=nil;
	end;

	repeat
		c:= getlongopts('cef:', @theopts[1],optionindex);
		case c of
			#0: begin
					hay_output := true;
					fichero_output := optarg;
				end;
			#1: begin
					hay_verbose := true;
				end;
			'c' : begin
					hay_c := true;
				end;
			'e' : begin
					hay_e := true;
				end;
			'f' : begin
					hay_f := true;
					fichero_f := optarg;
				end;
			'?', ':' : begin
					writeln('Error con la opcion: ',optopt);
					hay_entrar := false;
				end;
			end;
	until c=endofoptions;

	if hay_entrar 
		then begin
			// Comprueba en caso de que no haya puesto el usuario ni -c ni -e
			// o los 2  la vez... en tal caso da error, y sino ya comprime o descomprime..
			if ( ((not hay_c) AND (not hay_e)) OR ((hay_c) AND (hay_e)) )
				then writeln('Error: Debe especificar si quiere comprimir [-c] o descomprimir [-e]')
				
			else begin
					
					if (hay_c) and (fichero_f<>'--output') and (fichero_f<>'--verbose') 
						then begin 
							if not(hay_output) 
									then begin
										fichero_output := 'Imagencomp.dat';
										//pedirImagen(imagen,i);
										end;
							LeerFicheroImagen(ficheroImagen, fichero_f, Imagen,i);
							generarArbol(imagen,quadTree,1,1,i,i);
							guardarArbol(quadTree,i,fichero_output);
							if (hay_verbose) 
								then verbose(Imagen,fichero_output,i);
						end // end del else de if(hay_c) and(fichero...

					 else if ((hay_e) AND (hay_f) AND (fichero_f<>'') AND (fichero_f<>'--output') AND (fichero_f<>'--verbose')) 
						then begin
							// Corresponde al --output con -e
							if not(hay_output) 
									then fichero_output := 'Imagencomp.txt';
							leerFichByte(fichero_f, nquadTree,i);
							generarImagen(Imagen,nquadTree,1,1,i,i,j);		
							guardarImagen(Imagen,i,fichero_output);
							if (hay_verbose) then verbose(Imagen,fichero_f,i);

							end // end del else if...
					// Poner un error comun y pista!
					else writeln('Error. Con la opcion -e debe espeficicar -f');

				end;//end del else del if principal (if not(hay_c) and not...
	 end;//end del if hay entrar
end.

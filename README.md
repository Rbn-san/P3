PAV - P3: detección de pitch
============================

Esta práctica se distribuye a través del repositorio GitHub [Práctica 3](https://github.com/albino-pav/P3).
Siga las instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para realizar un `fork` de la
misma y distribuir copias locales (*clones*) del mismo a los distintos integrantes del grupo de prácticas.

Recuerde realizar el *pull request* al repositorio original una vez completada la práctica.

Ejercicios básicos
------------------

- Complete el código de los ficheros necesarios para realizar la detección de pitch usando el programa
  `get_pitch`.

   * Complete el cálculo de la autocorrelación e inserte a continuación el código correspondiente.
   
		   void PitchAnalyzer::autocorrelation(const vector<float> &x, vector<float> &r) const {

			  /// \TODO Compute the autocorrelation r[l]
			  /// \DONE Autocorrelación implementada.

			  //int N = x.size();
			   
				for (unsigned int l = 0; l < r.size(); ++l) {
				  r[l] = 0;
				  for(unsigned int i = 0; i < (x.size()-1)-l; ++i){
					r[l] = x[i]*x[i+l] + r[l];
				  }
				  r[l] = r[l] / x.size();
					
				}

				if (r[0] == 0.0F) //to avoid log() and divide zero 
				   r[0] = 1e-10; 
			}

   * Inserte una gŕafica donde, en un *subplot*, se vea con claridad la señal temporal de un segmento de
     unos 30 ms de un fonema sonoro y su periodo de pitch; y, en otro *subplot*, se vea con claridad la
	 autocorrelación de la señal y la posición del primer máximo secundario.

	 NOTA: es más que probable que tenga que usar Python, Octave/MATLAB u otro programa semejante para
	 hacerlo. Se valorará la utilización de la librería matplotlib de Python.
	 
	 ![matlab autocorrelacio](/material/matlab_autocor_valors.PNG)

   * Determine el mejor candidato para el periodo de pitch localizando el primer máximo secundario de la
     autocorrelación. Inserte a continuación el código correspondiente.
	 
	 Primero tenemos hacer un enventanado. Para ello, programamos la ventana de Hamming de la siguiente 
	 forma:
	 
			void PitchAnalyzer::set_window(Window win_type) {
				if (frameLen == 0)
				  return;

				window.resize(frameLen);

				float a0 = 0.53836;
				float a1 = 0.46164;

				switch (win_type) {
				case HAMMING:
				/// \TODO Implement the Hamming window
				/// \DONE Ventana de Hamming implementada. 
				/// Hemos consultado internet para referencias y ejemplos. 

				  for (unsigned int n = 0; n < frameLen; ++n){
					window[n] = a0 - a1*cos((2*M_PI*n)/(frameLen-1));
				  }

				  break;
				case RECT:
				default:
				  window.assign(frameLen, 1);
				}
			}
	 
	 Finalmente calculamos la autocorrelación y procedemos con la programación para encontrar el primer
	 máximo secundario: 	 

			vector<float> r(npitch_max);

			//Compute correlation
			autocorrelation(x, r);

			vector<float>::const_iterator iR = r.begin(), iRMax = iR;

			/// \TODO 
			/// Find the lag of the maximum value of the autocorrelation away from the origin.<br>
			/// Choices to set the minimum value of the lag are:
			///    - The first negative value of the autocorrelation.
			///    - The lag corresponding to the maximum value of the pitch.
			///	   .
			/// In either case, the lag should not exceed that of the minimum value of the pitch.

			/// \DONE Recorremos la autocorrelación desde el periodo mínimo de pitch 
			/// (y por tanto, pasado el origen donde hay el 1r máximo) hasta el máximo periodo posible 
			/// y guardamos el valor del máximo encontrado (2ndo máximo).  

			iR = iR + npitch_min;
			iRMax = iR;

			while(iR <= r.end()){ 
			  if(*iRMax < *iR)
				iRMax = iR;    
			  iR++;  
			}

			unsigned int lag = iRMax - r.begin();
		  
			float pot = 10 * log10(r[0]);

   * Implemente la regla de decisión sonoro o sordo e inserte el código correspondiente.
   
			bool PitchAnalyzer::unvoiced(float pot, float r1norm, float rmaxnorm) const {
			
				if(pot < -50 || r1norm < 0.65F || rmaxnorm < 0.25F){
				  return true;   //Unvoiced
				}else {
				  return false;  //Voiced
				}
				
				/// \TODO Implement a rule to decide whether the sound is voiced or not.
				/// * You can use the standard features (pot, r1norm, rmaxnorm),
				///   or compute and use other ones.
				/// \DONE Falta optimizar los valores. 
			}

- Una vez completados los puntos anteriores, dispondrá de una primera versión del detector de pitch. El 
  resto del trabajo consiste, básicamente, en obtener las mejores prestaciones posibles con él.

  * Utilice el programa `wavesurfer` para analizar las condiciones apropiadas para determinar si un
    segmento es sonoro o sordo. 
	
	  - Inserte una gráfica con la detección de pitch incorporada a `wavesurfer` y, junto a ella, los 
	    principales candidatos para determinar la sonoridad de la voz: el nivel de potencia de la señal
		(r[0]), la autocorrelación normalizada de uno (r1norm = r[1] / r[0]) y el valor de la
		autocorrelación en su máximo secundario (rmaxnorm = r[lag] / r[0]).

		Puede considerar, también, la conveniencia de usar la tasa de cruces por cero.

	    Recuerde configurar los paneles de datos para que el desplazamiento de ventana sea el adecuado, que
		en esta práctica es de 15 ms.
		
		![grafica detec. pitch wavesurfer](/material/ws_pitch.PNG)
		
		Nivel de potencia de la señal: r[0] = 3.752  
		Autocorrelación normalizada de uno: r1norm = r[1] / r[0] = 3.631 / 3.752 = 0.968  
		Autocorrelación en su máximo secundario: rmaxnorm = r[lag] / r[0] = 2.385 / 3.752 = 0.636   

      - Use el detector de pitch implementado en el programa `wavesurfer` en una señal de prueba y compare
	    su resultado con el obtenido por la mejor versión de su propio sistema.  Inserte una gráfica
		ilustrativa del resultado de ambos detectores.
	
		![comparacio detectors pitch](/material/comp_pitch_1.PNG)
		1r panel: detección de pitch de nuestro sistema.  
		2ndo panel: detección de pitch de `wavesurfer`.   
		3r panel: señal analizada.
  
  * Optimice los parámetros de su sistema de detección de pitch e inserte una tabla con las tasas de error
    y el *score* TOTAL proporcionados por `pitch_evaluate` en la evaluación de la base de datos 
	`pitch_db/train`..

	Tras optimizar los valores, hemos conseguido minimizar las tasas de error hasta los siguientes resultados:

	| Sonoro por sordo (VU)    |  5.00 % |
	|--------------------------|---------|
	| Sordo por sonor (UV)     |  8.35 % |
	| Errores groseros (G)     |  2.63 % |
	| MSE de los errores finos |  2.23 % |
	| TOTAL                    | 90.73 % |

	Se puede comprobar con la siguiente captura del proporcionada por `pitch_evaluate`:
	![pitch_evaluate summary](/material/summary9073.PNG)

   * Inserte una gráfica en la que se vea con claridad el resultado de su detector de pitch junto al del
     detector de Wavesurfer. Aunque puede usarse Wavesurfer para obtener la representación, se valorará
	 el uso de alternativas de mayor calidad (particularmente Python).
   
     ![comparació detectors pitch final](/material/comp_pitch_2.PNG)
	 1r panel: detección de pitch de nuestro sistema.  
	 2ndo panel: detección de pitch de `wavesurfer`.   
	 3r panel: señal analizada.

Ejercicios de ampliación
------------------------

- Usando la librería `docopt_cpp`, modifique el fichero `get_pitch.cpp` para incorporar los parámetros del
  detector a los argumentos de la línea de comandos.
  
  Esta técnica le resultará especialmente útil para optimizar los parámetros del detector. Recuerde que
  una parte importante de la evaluación recaerá en el resultado obtenido en la detección de pitch en la
  base de datos.

  * Inserte un *pantallazo* en el que se vea el mensaje de ayuda del programa y un ejemplo de utilización
    con los argumentos añadidos.

- Implemente las técnicas que considere oportunas para optimizar las prestaciones del sistema de detección
  de pitch.

  Entre las posibles mejoras, puede escoger una o más de las siguientes:

  * Técnicas de preprocesado: filtrado paso bajo, *center clipping*, etc.
  * Técnicas de postprocesado: filtro de mediana, *dynamic time warping*, etc.
  * Métodos alternativos a la autocorrelación: procesado cepstral, *average magnitude difference function*
    (AMDF), etc.
  * Optimización **demostrable** de los parámetros que gobiernan el detector, en concreto, de los que
    gobiernan la decisión sonoro/sordo.
  * Cualquier otra técnica que se le pueda ocurrir o encuentre en la literatura.

  Encontrará más información acerca de estas técnicas en las [Transparencias del Curso](https://atenea.upc.edu/pluginfile.php/2908770/mod_resource/content/3/2b_PS%20Techniques.pdf)
  y en [Spoken Language Processing](https://discovery.upc.edu/iii/encore/record/C__Rb1233593?lang=cat).
  También encontrará más información en los anexos del enunciado de esta práctica.

  Incluya, a continuación, una explicación de las técnicas incorporadas al detector. Se valorará la
  inclusión de gráficas, tablas, código o cualquier otra cosa que ayude a comprender el trabajo realizado.

  También se valorará la realización de un estudio de los parámetros involucrados. Por ejemplo, si se opta
  por implementar el filtro de mediana, se valorará el análisis de los resultados obtenidos en función de
  la longitud del filtro.
   

Evaluación *ciega* del detector
-------------------------------

Antes de realizar el *pull request* debe asegurarse de que su repositorio contiene los ficheros necesarios
para compilar los programas correctamente ejecutando `make release`.

Con los ejecutables construidos de esta manera, los profesores de la asignatura procederán a evaluar el
detector con la parte de test de la base de datos (desconocida para los alumnos). Una parte importante de
la nota de la práctica recaerá en el resultado de esta evaluación.

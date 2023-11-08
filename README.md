# Código Picket Fence (PF)
Autores: M. en C. Alvaro Daniel Cruz Cortes (FM, Médica Sur) y  M. en C. Luis Guitierrez Malgarejo (FM, Instituto Nacional de Pediatría)
         
Información del repositorio: Este repositorio tiene como finalidad albergar los códigos que surjan durante el concurso de la SMFM de PF.

Consiste en un par de códigos para evaluar cuantitativamente la prueba de Picket-Fance propuesta por el TG-142 de la AAPM. Se pueden evaluar imágenes de dosimetría portal DICOM y dosimetría con película radiográfica.  El código obtiene las desviaciones de las posiciones de las hojas respecto al eje central de cada franja. 

# Documentación
Los códigos fueron realizados con lenguaje MATLAB. Utilice la versión MATLAB R2022b en adelante para correr los programas correspondientes. 

# Archivos de entrada
Para el programa "PF_Portal", es necesario ingresar archivos DICOM de imagenes de dosimetría portal. En las siguientes líneas ingrese el nombre del archivo. No olvide agregar la terminación ".dcm". 

   
     %% Abrimos la imagen
     im = dicomread("PF_Varian.dcm"); %Aquí leemos la imagen DICOM 
     info=dicominfo('PF_Varian.dcm'); %En caso que se use, extraer datos del DICOM para generar un PDF
     I = dicomread(info); 
     %imshow(im)

Posteriormente, corra el programa con "RUN".


Para el programa "PF_Peli", es necesario ingresar imagenes JPG. Las condiciones de irradiación que recomendamos es: al menos 500 UM por cada franja, 600 UM/min, haz de 6X, una geometría de SSD=100 cm, colocando placas de 5cm por debajo y 1.5cm por encima de la película. Colocar 4 marcas de referencia en la película  Escanear la imagen en un archivo .jpg, 300 dpi, 48 bits de profunidad, En las siguientes líneas ingrese el nombre del archivo. No olvide agregar la terminación ".dcm". 

   
     %% Abrimos la imagen
     im = dicomread("PF_Varian.dcm"); %Aquí leemos la imagen DICOM 
     info=dicominfo('PF_Varian.dcm'); %En caso que se use, extraer datos del DICOM para generar un PDF
     I = dicomread(info); 
     %imshow(im)

Posteriormente, corra el programa con "RUN".



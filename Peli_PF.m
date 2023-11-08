close all %Para eliminar todas las ventanas que abrimos 
clear all %Para cerrar todas las variables 
clc %Para limpiar la ventana de comandos 
%% Apertura de la imagen y ajuste de constraste
im=rgb2gray(imread('bk_300006.jpg'));
imc=imread('bk_300006.jpg');
%% En esta parte, aumentamos el número de filas o columnas si es necesario
I=size(im);
if mod(I(1),2)==0
    I(1)=I(1)-1;
    im=im(1:I(1),:);
else
    im=im;
end

if mod(I(2),2)==0
    I(2)=I(2)-1;
    im=im(:,1:I(2));
else
    im=im;
end
%% Aqui aplicamos una rotacion si la imagen esta mal orientada, debe estar como en el portal
% A partir del tamaño de la matriz, verificamos si esta rotada si no para
% realizar el cambio
[filas, columnas] = size(im);
if filas > columnas
    im = imrotate(im, -90);
else
    im = im;
end

%% Punto para rotar
%img2=imresize(img2,[5079,1123]);
imshow(im);
title({'Seleccione c/marca: 1° IZQ, 2° DER ','Haga Zoom, teclee cualquier letra y seleccione '});
zoom on;
pause() % you can zoom with your mouse and when your image is okay, you press any key
zoom off; % to escape the zoom mode
X=ginput(1);
zoom out; % go to the original size of your image
%imshow(im,[61,76]);
zoom on;
pause() % you can zoom with your mouse and when your image is okay, you press any key
zoom off; % to escape the zoom mode
Y=ginput(1);
zoom out; % go to the original size of your image
close
%% Lineas de referencia para conocer el centro de la imagen
lh=size(im);
lh=round(lh(1)/2);
lv=size(im);
lv=round(lv(2)/2);
%% Vector resultante
vr=Y-X;
%% Vector base
vb=[1,0];
%% Angulo entre los vectores
%cosOfAngle = max(min(dot(vr,vb)/(norm(vb)*norm(vr)),1),-1);
%max(min(dot(u,v)/(norm(u)*norm(v)),1),-1)
%angleInDegrees = real(acosd(cosOfAngle));
pp=dot(vr,vb);
norma=norm(vr)*norm(vb);
cos=pp/norma;
angleInDegrees = acosd(cos);
%% Comprobación de angulo
if vr(2)<0
    angleInDegrees=angleInDegrees*-1;
else
    angleInDegrees=angleInDegrees*1;
end
%% Rotar imagen
imr=imrotate(im,angleInDegrees,'nearest','crop');
%% Traslado de la imagen en x
imshow(imr);
title({'Seleccione la marca: ARRIBA ','Haga Zoom, teclee cualquier letra y seleccione '})
hold on
yline(lh)
xline(lv)
zoom on;
pause() % you can zoom with your mouse and when your image is okay, you press any key
zoom off; % to escape the zoom mode
Z=ginput(1);
zoom out; % go to the original size of your image
tamx=size(im); %[filas, columnas, canal]
tamx= tamx(2)/2; %numero de columnas
%a1= round(Z(1));
dif= tamx-Z(1);
q = [dif,0];
imrt=imtranslate(imr,q);
close
%% Traslado en y de la imagen 
imshow(imrt)
title({'Seleccione la marca: IZQ ','Haga Zoom, teclee cualquier letra y seleccione '})
hold on
yline(lh)
xline(lv)
zoom on;
pause() % you can zoom with your mouse and when your image is okay, you press any key
zoom off; % to escape the zoom mode
W=ginput(1);
zoom out; % go to the original size of your image
tamy=size(im); %[filas, columnas, canal]
tamy= tamy(1)/2; %numero de columnas
dif2= tamy-W(2);
q2 = [0,dif2];
imrt2=imtranslate(imrt,q2);
close
%% Parametros de la imagen

tpix=1/(72/(2.54*10)); %obtiene la medida de cada pixel en mm
%%
imshow(imrt2)
hold on
title({'Seleccione una ROI fuera del campo','Luego, clic derecho y seleccione "Crop Image"'})
[J] = imcrop(imrt2);
 %vbg=100; 
vbg=round(mean2(J));
imrt35=uint8(vbg)-imrt2;
imshow(imrt35)
close
%% Conversión del tipo de imagen
imrt35=cast(imrt35,'double');
imrt35=im;
imrt35=histeq(imrt35);
%% Parametros de la imagen. Tamaño de pixel, columnas, filas
tamx=size(im); %[filas, columnas, canal]. En caso de una imagen DICOM, no tiene canal. 
tamx= tamx(2)/2; %numero de columnas
tmx=tamx*2; %para el numero de columnas de la matriz
lv=size(im); %longitud vertical en pixeles
lv=lv(1)/2;  %mitad de la longitud vertical
lh=size(im); %longitud horizontal en pixeles
lh=lh(2)/2; %mitad de la longitud horizontal
tmy=lv*2; % para el número de renglones 
%% Vectores de distancia (Tamaño de imagen)
mitad=floor(tamx);
zz=tpix:tpix:tpix*tmx; %Creamos un vector donde cada elemento de pixel en mm en pasos de tpix
zzt= zz-zz(1,mitad); %Los elementos de ese vector se nombran de -mitad, ..., 0, .... mitad  OJO ESTE LO USAREMOS DESPUES
ww=tpix:tpix:tpix*lv*2; %analogamente para l
lh3= ceil(lh/3);
%% Crear perfiles para identificar las franjas de mayor transmisión
pf1=imrt35(:,lh3); %(filas,columnas)
pf2=imrt35(:,ceil(lh-lh3)); %Tomamos 3 perfiles, uno central y dos laterales, 30 pixeles a los laterales de los bordes del lado horizontal
pf3=imrt35(:,ceil(lh/2));
pff=smoothdata(((pf1+pf2+pf3)),'gaussian',50); %Agregamos un filtro de 20 gaussiano para eliminar el ruido, haciendo un promedio de los 3 perfiles
plot(ww,pff,'k') %Esta linea es para visualizar el perfil obtenido
%% Localización de los bordes entre hojas vecinas continuas en cada franja
pfft=-pff; %perfil de prueba
[zpkst,zlocst]=[findpeaks(pfft,ww/tpix)]; %[zpks se refiere a las alturas de los picos, zlocs las posiciones en el vector zz]
zpksmean= -200; % para elegir los picos que sean más altos que un umbral (en este caso el promedio)
[zpks,zlocs]=[findpeaks(-pff,ww/tpix, 'MinPeakHeight',zpksmean)]; %nuevamente que encuentre los picos pero a una altura más allá de zpksmean
figure();
plot(ww/tpix,-pff,'k') %para encontrar las posiciones y picos
hold on;
fance_pos=ceil(zlocs); %Definimos esta variable para usarla despues
fance_pm= ceil((zlocs(2)-zlocs(1))/2); %punto medio entre cada franja
plot(zlocs, zpks,'o')
zlocs= ceil(zlocs);
% findpeaks(pff,ww/tpix, 'MinPeakHeight',zpksmean)
figure();
imshow(im)
%imcontrast()
hold on 
%xline(leaf_pos, 'y')
yline(fance_pos, 'r' )
%% Perfiles sobre las franjas
i=0; %contador para el if 
zmatr3= zeros(length(zlocs),tmx); %creamos una matriz donde guadaremos todos los valores de las franjas encontradas, de dimensiones (longitud(zlocs), tmx)
zmatr2s= zeros(length(zlocs),tmx); %otra matriz para suavizar
c=0;
for i=1:1:length(zlocs) %va a leer desde el primer perfil hasta la long de zlocss
    pos=zlocs(i);  %guadar la posición de la i-franja
    c=c+1;
    zmatr3(c,:)=imrt35(pos,:); %rellena los valores en la franja c todos los valores de posicion y valor de pixel
    zmatr2s(c,:)= imrt35(pos-fance_pm,:); %analogo pero se realiza un suavizado 
    %zmatr2s(c,:)= smoothdata((100*imrt35(pos,:)),"gaussian",13); %analogo pero se realiza un suavizado 
    %ESTA ULTIMA LINEA PARA QUE ERA?
end 
%zmatr3, tiene los valores de las columnas en las filas que estan los
%picosims
%de las franjas. 
%Al final obtendremos una matriz donde estan guardadas los valores de pix
%en cada uno de los perfiles (franjas)
%zmatr3=zmatr2s;
zmatr2s=smoothdata(zmatr2s,"gaussian",100);
zmatr2s=smoothdata(zmatr3,"gaussian",100);
plot(zz,zmatr2s,'k'); %para encontrar las posiciones y picos
hold on;
plot(zz,zmatr3,'r'); %para encontrar las posiciones y picos
%% Promedio de la cada uno de los renglones y obtener un perfil final
zmatrizsum=(sum(zmatr3)+sum(zmatr2s));
zmatrizprom= mean2(zmatrizsum);
%zmatrizsum1=smoothdata((zmatrizsum-zmatrizprom),"gaussian",5);
zmatrizsum1=smoothdata(((zmatrizsum-zmatrizprom)/zmatrizprom),"gaussian",1);
zmatrizabs=abs(zmatrizsum1);
zmatrizsum1= zmatrizsum1+zmatrizabs;
%zmatrizsum2=smoothdata((zmatrizsum)/zmatrizprom*100,"movmean",100);
%zmatrizsum=zmatrizsum1+zmatrizsum2; 
%zmatrizprom= mean(zmatrizsum);
zdmin= 10; %es la distancia minima para encontrar el siguiente pico, porque es el grosor de la hoja mas chica =5mm
plot(zz,zmatrizsum1,'k'); %para encontrar las posiciones y picos
[xpkst,xlocst,w,p]=[findpeaks(zmatrizsum1,zz/tpix)]; %nuevamente que encuentre los picos 
zaltur=mean(p);
%alturprom= median(w);
[xpks,xlocs]=[findpeaks(zmatrizsum1,zz/tpix, 'MinPeakDistance',zdmin, "MinPeakHeight",0)]; %nuevamente que encuentre los picos 
findpeaks(zmatrizsum1,zz/tpix,'MinPeakDistance',zdmin, "MinPeakHeight",0);
text(xlocs+.02,xpks,num2str((1:numel(xpks))'))
%findpeaks(zmatrizsum,zz/tpix,'MaxPeakWidth', alturprom)
%% Obtengamos los picos verdaderos y encontrar la mitad de las hojas
% Define la diferencia mínima requerida
delta = 0.04; %Este valor es mi referencia para elegir picos con altura delta
picos_true = []; % Aqui vamos a guardar los picos y sus posiciones que entraran al for
pos_true = [];
for i = 1:numel(xpks) %Va a leer todos los elementos de xpks encontrados anteriormente
    pico = xpks(i);
    posicion = xlocs(i);
    % Calcula la diferencia entre el pico y elementos a 3 posiciones a la izquierda y derecha
    if posicion > 3 && posicion < numel(zmatrizsum1) - 3
        dif_izq = pico - zmatrizsum1(posicion - 3);
        dif_der = pico - zmatrizsum1(posicion + 3);
        % Verifica si ambas diferencias son mayores o iguales a 0.4
        if abs(dif_izq) >= delta && abs(dif_der) >= delta
            % Guarda el pico y su posición original
            picos_true = [picos_true, pico];
            pos_true = [pos_true, zz(posicion)/tpix];
        end
    end
end
figure();
plot(zz/tpix,zmatrizsum1,'k'); %para encontrar las posiciones y picos
hold on;
plot(pos_true,picos_true,'o'); %para verificar que son los correctos
%% Aquí vamos a tomar los perfiles horizontales a la mitad de las hojas
leaf_pos = zeros(1, numel(pos_true) - 1); %Creamos un vector de para que guarde las posiciones, desde 1 hasta n-dim
for i = 1:numel(pos_true) - 1
    % Calcula el punto medio entre los elementos consecutivos
    pm = (pos_true(i) + pos_true(i + 1)) / 2;
    leaf_pos(i) = pm;
end
%A continuación, agregaremos la 1era y ultima hoja tomando en cuenta la
%distancia de 2da y 3era hoja 
delta2= leaf_pos(2)-leaf_pos(1);
leaf1= leaf_pos(1)-delta2;
leafn= leaf_pos(numel(leaf_pos))+delta2;
leaf_pos= [leaf1, leaf_pos, leafn];
figure;
imshow(im)
%imcontrast()
hold on 
xline(leaf_pos, 'y')
yline(fance_pos, 'r' )
[X, Y] = meshgrid(leaf_pos, fance_pos);
scatter(X(:), Y(:), 20, 'b', 'filled');
%xline(pos_true, 'r')
%xline(xlocs, 'w')
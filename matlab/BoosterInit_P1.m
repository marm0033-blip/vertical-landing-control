%% BoosterInit_P1.m
% Script de inicializacion para la Practica 1
% Modelado dinamico y simulacion en lazo abierto de un cohete

%% Limpieza inicial
clear; close all; clc;

%% Definicion teorica del modelo

% Vector de estados:
% x = [xCG; yCG; psi; ub; vb; rb]

% Vector de entradas incrementales:
% u = [alpha; dFT]

%% Parametros fisicos del cohete

m = 5e5;        % Masa del cohete [kg]
g = 10;         % Gravedad [m/s^2]
Theta = 2e8;    % Momento de inercia [kg*m^2]
LT = 35;        % Distancia entre motor y centro de gravedad [m]
FT0 = m*g;      % Empuje de equilibrio [N]
%Fw = fuerza lateral del viento [N]

%% Modelo linealizado en espacio de estados

A = [0 0 0 0 -1 0;
     0 0 0 1  0 0;
     0 0 0 0  0 1;
     0 0 0 0  0 0;
     0 0 10 0 0 0;
     0 0 0 0  0 0];

B = [0       0       0;
     0       0       0;
     0       0       0;
     0   2e-6       0;
     10      0     1/m;
    -0.875   0       0];

C = eye(6);

D = zeros(6,3);


%% Seleccion del caso de simulacion

caso = input ('Introduce el caso de simulacion que deseas ejecutar (1-7):');

switch caso

    case 1
        % CASO 1: sin empuje real
        % FT = 0  ->  dFT = FT - FT0 = -FT0
        x0 = [0; 200; 0; 0; 0; 0];
        alpha0 = 0;
        dFT_test = -FT0;
        Fw_test = 0;
        nombre_caso = 'Caso 1: sin empuje real';


    case 2
        % CASO 2: empuje igual al peso
        % FT = FT0  ->  dFT = 0

        x0 = [0; 200; 0; 0; 0; 0];
        alpha0 = 0;
        dFT_test = 0;
        Fw_test = 0;
        nombre_caso = 'Caso 2: empuje igual al peso';



     case 3
        % CASO C: empuje mayor que el peso
        x0 = [0; 200; 0; 0; 0; 0];
        alpha0 = 0;
        dFT_test = 0.2*FT0;
        Fw_test = 0;
        nombre_caso = 'Caso C: empuje mayor que el peso';

    case 4
        % CASO D: empuje menor que el peso
        x0 = [0; 200; 0; 0; 0; 0];
        alpha0 = 0;
        dFT_test = -0.2*FT0;
        Fw_test = 0;
        nombre_caso = 'Caso D: empuje menor que el peso';

    case 5
        % CASO E: perturbacion angular inicial
        x0 = [0; 200; 30*pi/180; 0; 0; 0];
        alpha0 = 0;
        dFT_test = 0;
        Fw_test = 0;
        nombre_caso = 'Caso E: perturbacion angular inicial';

    case 6
        % CASO 6: descenso con viento lateral
        % Empuje menor que el peso y perturbacion lateral por viento

        x0 = [0; 200; 0; 0; 0; 0];

        alpha0 = 0;
        dFT_test = -0.2*FT0;   % Empuje real = 0.8*FT0
        Fw_test = 2.5e5;       % Fuerza lateral del viento [N]
        nombre_caso = 'Caso 6: descenso con viento lateral';

    case 7
        % CASO 7: descenso con viento lateral y perturbacion angular inicial
        % Empuje menor que el peso, viento lateral e inclinacion inicial
        x0 = [0; 200; 20*pi/180; 0; 0; 5*pi/180];
        alpha0 = 0;
        dFT_test = -0.2*FT0;   % Empuje real = 0.8*FT0
        Fw_test = 2.5e5;       % Fuerza lateral del viento [N]
        nombre_caso = 'Caso 7: descenso con viento lateral y perturbacion angular inicial';


    otherwise
        error('El caso seleccionado no existe. Usa caso = 1, 2, 3, 4, 5, 6 o 7.');

end

%% Vector de entrada

u0 = [alpha0; dFT_test; Fw_test];

%% Sistema continuo

sysc = ss(A,B,C,D);

%% Mostrar informacion del caso seleccionado

disp('---------------------------------------------')
disp(nombre_caso)
disp('Condicion inicial x0:')
disp(x0)
disp('Entrada alpha0:')
disp(alpha0)
disp('Entrada dFT_test:')
disp(dFT_test)
disp('---------------------------------------------')
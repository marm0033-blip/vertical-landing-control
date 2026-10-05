%% BoosterInit_P2.m
% Practica 2
% Discretizacion y analisis estructural del modelo del cohete

%% Limpieza inicial
clear; close all; clc;
format long e

%% Parametros fisicos del cohete

m = 5e5;        % Masa del cohete [kg]
g = 10;         % Gravedad [m/s^2]
Theta = 2e8;    % Momento de inercia [kg*m^2]
LT = 35;        % Distancia motor-centro de gravedad [m]
FT0 = m*g;      % Empuje de equilibrio [N]

%% Modelo continuo linealizado

A = [0 0 0 0 -1 0;
     0 0 0 1  0 0;
     0 0 0 0  0 1;
     0 0 0 0  0 0;
     0 0 10 0 0 0;
     0 0 0 0  0 0];

B = [0       0;
     0       0;
     0       0;
     0   2e-6;
     10      0;
    -0.875   0];

C = eye(6);

D = zeros(6,2);

%% Sistema continuo

sysc = ss(A,B,C,D);

%% Discretizacion del sistema

Ts = 0.1;              % Tiempo de muestreo [s]

sysd = c2d(sysc, Ts);  % Sistema discreto

Phi = sysd.A;          % Matriz dinamica discreta
H = sysd.B;            % Matriz de entrada discreta
Cd = sysd.C;           % Matriz de salida discreta
Dd = sysd.D;           % Matriz directa discreta

%% Mostrar matrices discretas

disp('---------------------------------------------')
disp('Matriz Phi del sistema discreto:')
disp(Phi)

disp('Matriz H del sistema discreto:')
disp(H)
disp('---------------------------------------------')

%% Analisis de estabilidad

% Polos del sistema continuo
polos_c = eig(A);

% Polos del sistema discreto
polos_d = eig(Phi);

disp('Polos del sistema continuo:')
disp(polos_c)

disp('Polos del sistema discreto:')
disp(polos_d)

disp('Modulo de los polos discretos:')
disp(abs(polos_d))

%% Representacion grafica de los polos continuos

figure;
plot(real(polos_c), imag(polos_c), 'x', 'MarkerSize', 10, 'LineWidth', 2);
grid on;
xlabel('Parte real');
ylabel('Parte imaginaria');
title('Polos del sistema continuo');

%% Representacion grafica de los polos discretos

figure;
plot(real(polos_d), imag(polos_d), 'x', 'MarkerSize', 10, 'LineWidth', 2);
hold on;

theta = linspace(0, 2*pi, 300);
plot(cos(theta), sin(theta), '--');

grid on;
axis equal;
xlabel('Parte real');
ylabel('Parte imaginaria');
title('Polos del sistema discreto y circulo unidad');
legend('Polos discretos','Circulo unidad');

%% Analisis de controlabilidad con ambos actuadores

Co = ctrb(Phi, H);
    
rango_Co = rank(Co);

disp('---------------------------------------------')
disp('Rango de la matriz de controlabilidad con ambos actuadores:')
disp(rango_Co)

if rango_Co == 6
    disp('El sistema es completamente controlable con ambos actuadores.')
else
    disp('El sistema NO es completamente controlable con ambos actuadores.')
end

%% Controlabilidad usando solo alpha

H_alpha = H(:,1);

Co_alpha = ctrb(Phi, H_alpha);

rango_alpha = rank(Co_alpha);

disp('Rango de controlabilidad usando solo alpha:')
disp(rango_alpha)

if rango_alpha == 6
    disp('Con alpha se puede controlar todo el sistema.')
else
    disp('Con alpha solo se controla una parte del sistema.')
end


%% Controlabilidad usando solo dFT

H_dFT = H(:,2);

Co_dFT = ctrb(Phi, H_dFT);

rango_dFT = rank(Co_dFT);

disp('Rango de controlabilidad usando solo dFT:')
disp(rango_dFT)

if rango_dFT == 6
    disp('Con dFT se puede controlar todo el sistema.')
else
    disp('Con dFT solo se controla una parte del sistema.')
end

disp('---------------------------------------------')

%% Separacion en subsistemas lateral y vertical

% Estados:
% 1 -> xCG
% 2 -> yCG
% 3 -> psi
% 4 -> ub
% 5 -> vb
% 6 -> rb

%% Subsistema lateral-actitud

idx_lat = [1 3 5 6];

Phi_lat = Phi(idx_lat, idx_lat);
H_lat = H(idx_lat, 1);   % Entrada alpha

Co_lat = ctrb(Phi_lat, H_lat);
rango_lat = rank(Co_lat);

disp('Controlabilidad del subsistema lateral-actitud:')
disp(rango_lat)

if rango_lat == length(idx_lat)
    disp('El subsistema lateral-actitud es controlable mediante alpha.')
else
    disp('El subsistema lateral-actitud NO es completamente controlable mediante alpha.')
end


%% Subsistema vertical

idx_ver = [2 4];

Phi_ver = Phi(idx_ver, idx_ver);
H_ver = H(idx_ver, 2);   % Entrada dFT

Co_ver = ctrb(Phi_ver, H_ver);
rango_ver = rank(Co_ver);

disp('Controlabilidad del subsistema vertical:')
disp(rango_ver)

if rango_ver == length(idx_ver)
    disp('El subsistema vertical es controlable mediante dFT.')
else
    disp('El subsistema vertical NO es completamente controlable mediante dFT.')
end

disp('---------------------------------------------')

%% Analisis de observabilidad con todos los estados medidos

Ob = obsv(Phi, Cd);

rango_Ob = rank(Ob);

disp('Analisis de observabilidad con todos los estados medidos:')
disp('Rango de la matriz de observabilidad:')
disp(rango_Ob)

if rango_Ob == 6
    disp('El sistema es completamente observable midiendo todos los estados.')
else
    disp('El sistema NO es completamente observable.')
end

disp('---------------------------------------------')

%% Observabilidad midiendo solo posicion y angulo

% Se consideran como salidas medidas:
% xCG, yCG y psi

C_pos = [1 0 0 0 0 0;
         0 1 0 0 0 0;
         0 0 1 0 0 0];

Ob_pos = obsv(Phi, C_pos);

rango_Ob_pos = rank(Ob_pos);

disp('Observabilidad midiendo solo xCG, yCG y psi:')
disp('Rango de la matriz de observabilidad parcial:')
disp(rango_Ob_pos)

if rango_Ob_pos == 6
    disp('El sistema sigue siendo observable midiendo solo posiciones y angulo.')
else
    disp('El sistema NO es completamente observable con estas medidas.')
end

disp('---------------------------------------------')

%% Influencia del tiempo de muestreo

Ts_values = [0.01 0.05 0.1 0.2 0.5 1];

disp('Influencia del tiempo de muestreo sobre los polos discretos:')

for i = 1:length(Ts_values)

    Ts_i = Ts_values(i);

    sysd_i = c2d(sysc, Ts_i);

    Phi_i = sysd_i.A;

    polos_i = eig(Phi_i);

    disp('---------------------------------------------')
    disp(['Tiempo de muestreo Ts = ', num2str(Ts_i), ' s'])
    disp('Polos discretos:')
    disp(polos_i)
    disp('Modulo de los polos:')
    disp(abs(polos_i))

end

disp('---------------------------------------------')

%% Sensibilidad parametrica frente a la masa

% Se estudia el efecto de variar la masa del cohete
% respecto al valor nominal.

m_values = [0.8*m, m, 1.2*m];

disp('Sensibilidad parametrica frente a la masa:')

for i = 1:length(m_values)

    m_i = m_values(i);

    % Recalculo del efecto de dFT sobre la dinamica vertical
    B_i = [0       0;
           0       0;
           0       0;
           0   1/m_i;
           10      0;
          -0.875   0];

    sysc_i = ss(A, B_i, C, D);
    sysd_i = c2d(sysc_i, Ts);

    Phi_i = sysd_i.A;
    H_i = sysd_i.B;

    polos_i = eig(Phi_i);
    Co_i = ctrb(Phi_i, H_i);
    rango_Co_i = rank(Co_i);

    disp('---------------------------------------------')
    disp(['Masa considerada m = ', num2str(m_i), ' kg'])

    disp('Columna de H asociada a dFT:')
    disp(H_i(:,2))

    disp('Polos discretos:')
    disp(polos_i)

    disp('Rango de controlabilidad:')
    disp(rango_Co_i)

end

disp('---------------------------------------------')

%% Sensibilidad parametrica frente al momento de inercia

% Se estudia el efecto de variar el momento de inercia del cohete
% respecto al valor nominal.

Theta_values = [0.8*Theta, Theta, 1.2*Theta];

disp('Sensibilidad parametrica frente al momento de inercia:')

for i = 1:length(Theta_values)

    Theta_i = Theta_values(i);

    % Recalculo del efecto de alpha sobre la dinamica angular
    % Termino nominal: -(FT0*LT)/Theta = -0.875

    coef_alpha_rb = -(FT0*LT)/Theta_i;

    B_i = [0       0;
           0       0;
           0       0;
           0   1/m;
           10      0;
           coef_alpha_rb   0];

    sysc_i = ss(A, B_i, C, D);
    sysd_i = c2d(sysc_i, Ts);

    Phi_i = sysd_i.A;
    H_i = sysd_i.B;

    polos_i = eig(Phi_i);
    Co_i = ctrb(Phi_i, H_i);
    rango_Co_i = rank(Co_i);

    disp('---------------------------------------------')
    disp(['Momento de inercia Theta = ', num2str(Theta_i), ' kg*m^2'])

    disp('Coeficiente de alpha sobre rb:')
    disp(coef_alpha_rb)

    disp('Columna de H asociada a alpha:')
    disp(H_i(:,1))

    disp('Polos discretos:')
    disp(polos_i)

    disp('Rango de controlabilidad:')
    disp(rango_Co_i)

end

disp('---------------------------------------------')

%% Sensibilidad parametrica frente al brazo de empuje LT

% Se estudia el efecto de variar la distancia entre el motor
% y el centro de gravedad del cohete.

LT_values = [0.8*LT, LT, 1.2*LT];

disp('Sensibilidad parametrica frente al brazo de empuje LT:')

for i = 1:length(LT_values)

    LT_i = LT_values(i);

    % Recalculo del efecto de alpha sobre la dinamica angular
    % Termino nominal: -(FT0*LT)/Theta = -0.875

    coef_alpha_rb = -(FT0*LT_i)/Theta;

    B_i = [0       0;
           0       0;
           0       0;
           0   1/m;
           10      0;
           coef_alpha_rb   0];

    sysc_i = ss(A, B_i, C, D);
    sysd_i = c2d(sysc_i, Ts);

    Phi_i = sysd_i.A;
    H_i = sysd_i.B;

    polos_i = eig(Phi_i);
    Co_i = ctrb(Phi_i, H_i);
    rango_Co_i = rank(Co_i);

    disp('---------------------------------------------')
    disp(['Brazo de empuje LT = ', num2str(LT_i), ' m'])

    disp('Coeficiente de alpha sobre rb:')
    disp(coef_alpha_rb)

    disp('Columna de H asociada a alpha:')
    disp(H_i(:,1))

    disp('Polos discretos:')
    disp(polos_i)

    disp('Rango de controlabilidad:')
    disp(rango_Co_i)

end

disp('---------------------------------------------')

%% Fallo parcial de actuadores

disp('Analisis de fallo parcial de actuadores:')

%% Caso 1: alpha funciona al 50 %

H_alpha_50 = H;
H_alpha_50(:,1) = 0.5*H(:,1);

Co_alpha_50 = ctrb(Phi, H_alpha_50);
rango_alpha_50 = rank(Co_alpha_50);

disp('---------------------------------------------')
disp('Fallo parcial: alpha al 50%')
disp('Rango de controlabilidad:')
disp(rango_alpha_50)

if rango_alpha_50 == 6
    disp('El sistema sigue siendo completamente controlable con alpha al 50%.')
else
    disp('El sistema pierde controlabilidad con alpha al 50%.')
end


%% Caso 2: dFT funciona al 50 %

H_dFT_50 = H;
H_dFT_50(:,2) = 0.5*H(:,2);

Co_dFT_50 = ctrb(Phi, H_dFT_50);
rango_dFT_50 = rank(Co_dFT_50);

disp('---------------------------------------------')
disp('Fallo parcial: dFT al 50%')
disp('Rango de controlabilidad:')
disp(rango_dFT_50)

if rango_dFT_50 == 6
    disp('El sistema sigue siendo completamente controlable con dFT al 50%.')
else
    disp('El sistema pierde controlabilidad con dFT al 50%.')
end


%% Caso 3: ambos actuadores funcionan al 50 %

H_ambos_50 = 0.5*H;

Co_ambos_50 = ctrb(Phi, H_ambos_50);
rango_ambos_50 = rank(Co_ambos_50);

disp('---------------------------------------------')
disp('Fallo parcial: ambos actuadores al 50%')
disp('Rango de controlabilidad:')
disp(rango_ambos_50)

if rango_ambos_50 == 6
    disp('El sistema sigue siendo completamente controlable con ambos actuadores al 50%.')
else
    disp('El sistema pierde controlabilidad con ambos actuadores al 50%.')
end

disp('---------------------------------------------')

x0 = [0; 200; 10*pi/180; 0; 0; 0];
alpha0 = 0;
dFT_test = 0;
u0 = [alpha0; dFT_test];
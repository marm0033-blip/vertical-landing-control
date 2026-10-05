%% AnimacionCohete_P1.m
% Animacion simple del cohete como una figura con cuerpo y punta

clc; close all;

%% Extraer datos de Simulink

states_out = out.states_out;

t = states_out.time;

xCG = states_out.signals.values(:,1);
yCG = states_out.signals.values(:,2);
psi = states_out.signals.values(:,3);

%% Dimensiones visuales del cohete

L = 70;   % longitud total del cohete [m]
W = 9;    % anchura del cohete [m]

% Forma simplificada del cohete en coordenadas locales
% El centro del cohete coincide aproximadamente con el centro de gravedad
rocket_local = [-W/2   W/2   W/2    0   -W/2;
                -L/2  -L/2   L/4   L/2   L/4];

%% Crear figura

figure;
hold on;
grid on;
axis equal;

xlabel('Posicion horizontal xCG [m]');
ylabel('Altura yCG [m]');
title('Animacion del aterrizaje del cohete');

% Dibujar suelo
plot([-500 500], [0 0], 'k', 'LineWidth', 3);
text(min(xCG)-80, 5, 'Suelo');

% Limites de los ejes
xlim([min(xCG)-100, max(xCG)+100]);
ylim([-20, max(yCG)+100]);

% Crear el cohete inicialmente
cohete = patch(0, 0, [0.85 0.85 0.85], ...
               'EdgeColor', 'k', ...
               'LineWidth', 2);

% Punto del centro de gravedad
cg = plot(xCG(1), yCG(1), 'ro', 'MarkerFaceColor', 'r');

% Trayectoria del centro de gravedad
trayectoria = plot(xCG(1), yCG(1), 'b--');

%% Animacion

indices = unique([1:5:length(t), length(t)]);

for k = indices

    % Matriz de rotacion
    R = [cos(psi(k)) -sin(psi(k));
         sin(psi(k))  cos(psi(k))];

    % Rotar cohete
    rocket_rotado = R * rocket_local;

    % Trasladar al centro de gravedad
    rocket_global = rocket_rotado + [xCG(k); yCG(k)];

    % Actualizar dibujo del cohete
    set(cohete, 'XData', rocket_global(1,:), ...
                'YData', rocket_global(2,:));

    % Actualizar centro de gravedad
    set(cg, 'XData', xCG(k), ...
            'YData', yCG(k));

    % Actualizar trayectoria
    set(trayectoria, 'XData', xCG(1:k), ...
                    'YData', yCG(1:k));

    % Mostrar tiempo
    title(['Animacion del aterrizaje del cohete - t = ', num2str(t(k), '%.2f'), ' s']);

    drawnow;
    pause(0.3);
end
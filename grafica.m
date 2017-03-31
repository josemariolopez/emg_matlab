function [] = grafica( sec )
% a = arduino('COM3','UNO');

% puedo verificar cual COM está disponible y verificar si es el Arduino
% Uno?
% tengo problemas aún dibujando líneas
a = serial('COM7','BaudRate',115200);
time = tic;
i = 1;
t = zeros(sec);
v = zeros(sec);
h = animatedline;
grid on;
clearpoints(h);
drawnow;
fopen(a);
while(toc(time)<=sec)
    t(i) = toc(time);
    
    b = fscanf(a,'%d'); % comprobar que arduino solo tiene println(EMG)
    v(i) = b;
    addpoints(h,t(i),v(i));
    drawnow
    i = i + 1;
   
%     max v(i) es el máximo del voltaje, no tengo que sacar el max de la
%     animated line
   
    pause(0.1)
end
fclose(a);


end


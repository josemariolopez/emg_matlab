function varargout = interfaz(varargin)
% INTERFAZ MATLAB code for interfaz.fig
%      INTERFAZ, by itself, creates a new INTERFAZ or raises the existing
%      singleton*.
%
%      H = INTERFAZ returns the handle to a new INTERFAZ or the handle to
%      the existing singleton*.
%
%      INTERFAZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFAZ.M with the given input arguments.
%
%      INTERFAZ('Property','Value',...) creates a new INTERFAZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interfaz_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interfaz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interfaz

% Last Modified by GUIDE v2.5 01-Apr-2017 18:20:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interfaz_OpeningFcn, ...
                   'gui_OutputFcn',  @interfaz_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before interfaz is made visible.
function interfaz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interfaz (see VARARGIN)

% Choose default command line output for interfaz
handles.output = hObject;

% --------------------------------------------------------------------
% Instrucciones de paso de datos entre GUIs y config de arduino

global flag threshold control;
threshold = 0;
flag=true;
control=0;
arduino = serial('COM7','BaudRate',115200);
guidata(hObject, handles);
setappdata(0,'mainGui',gcf);
setappdata(gcf,'arduino',arduino);
setappdata(gcf,'fhUpdateThreshold',@updateThreshold);

% Variable global de porcentaje de interfaz
% Hacer un archivo .config para guardar los valores default de mvc
% global mvc_percentage
% mvc_percentaje = handles.mvc_percentage;



% UIWAIT makes interfaz wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% Variable mvcThreshold para activar/desactivar movimiento

% --- Outputs from this function are returned to the command line.
function varargout = interfaz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnIniciar.
function btnIniciar_Callback(hObject, eventdata, handles)
% hObject    handle to btnIniciar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnDetener.
function btnDetener_Callback(hObject, eventdata, handles)
% hObject    handle to btnDetener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in btnEjecutar.
function btnEjecutar_Callback(hObject, eventdata, handles)
% hObject    handle to btnEjecutar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% axGrafica = handles.axGrafica;
im1 = imread('D:\Documentos\MAyR\TFM\img1.png');

global threshold control;
%   configuración de ejes 
axes(handles.axImage);
title('Lecturas de señales EMG');
xtitle('Tiempo (ms)');
ytitle('Intensidad de EMG');

imshow(im1);
h = animatedline('Parent',handles.axGrafica);
line_upper_threshold = animatedline('Parent',handles.axGrafica);
timeEjecutar = tic;
i=1;

% while toc(timeEjecutar)<4
%     x(i) = i+10;
%     y(i) = cos(i);
%     addpoints(h,x(i),y(i));
%     drawnow
%     i=i+1;
% end

fopen(arduino);

while flag
    t1(i) = toc(timeSync1);
%   podría ver si hay bytes available y luego leer
    y1(i) = fscanf(arduino,'%d');
    addpoints(line_upper_threshold,t1(i),threshold);
    addpoints(h,t1(i),y1(i));
    if y1(i)>threshold
        control=1; %llamar a una función que decida que movimiento hacer
    end;
    drawnow
    i=i+1;
end
fclose(arduino);

% --------------------------------------------------------------------

function rbtOpenClose_Callback(hObject, eventdata, handles)
% hObject    handle to rbtOpenClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtOpenClose
% global typeOfMovement;
value = get(hObject,'Value');

% --- Executes on button press in rbtPronationSupination.
function rbtPronationSupination_Callback(hObject, eventdata, handles)
% hObject    handle to rbtPronationSupination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtPronationSupination

% --- Executes on button press in rbtFlexionExtension.
function rbtFlexionExtension_Callback(hObject, eventdata, handles)
% hObject    handle to rbtFlexionExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtFlexionExtension

% --- Executes on button press in btnSincro.
function btnSincro_Callback(hObject, eventdata, handles)
% hObject    handle to btnSincro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data = guidata(sincronizar)
sincronizar;
axes(handles.axImage);
% treshold = getappdata(sincronizar,'tresh');
% line(0,treshold);



% A = pasa del threshold.
% si A, ver si cambia de color los puntos de addpoint ->
% global color.
% si si A, mostrar cambio en AxImage para verificar el cambio
% tareas = preparar los gif de los movimientos de la mano
% en sincronizar, agregar el tiempo que debe durar la simulación. un text?
% AGREGAR -> se puede tener un slide bar para trasladar por la gráfica?


% --------------------------------------------------------------------
function mnConfig_Callback(hObject, eventdata, handles)
% hObject    handle to mnConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MVC_Callback(hObject, eventdata, handles)
% hObject    handle to MVC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% from this to the end: user functions

function updateThreshold
% Recibe el umbral desde la ventana de sincronizar y dibuja los umbrales en
% la ventana principal. Cuando la lectura de EMG pasa del umbral, se activa
% a 1 la acción correspondiente.
global threshold;

mainGui = getappdata(0, 'mainGui');
mvc = getappdata(mainGui,'mvc');
threshold = mvc*(1-0.2); % 0.2 se debe cambiar por mvc_percentage, global, de .config

%move to btnEjecutar
axesInterfaz = findobj(mainGui,'type','axes','Tag','axGrafica');
axes(axesInterfaz);
line([0 300],[threshold threshold],'color','g');

function control(flag)
% La función control recibe un valor flag que determina si el valor EMG
% leído supera el valor mayor del umbral de MVC, o está por debajo del
% umbral menor.

    


% --- Executes when selected object is changed in btgMovements.
function btgMovements_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in btgMovements 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tagOfSelectedRbt = get(hObject,'Tag');
msgbox(tagOfSelectedRbt);


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

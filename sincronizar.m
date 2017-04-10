function varargout = sincronizar(varargin)
% SINCRONIZAR MATLAB code for sincronizar.fig
%      SINCRONIZAR, by itself, creates a new SINCRONIZAR or raises the existing
%      singleton*.
%
%      H = SINCRONIZAR returns the handle to a new SINCRONIZAR or the handle to
%      the existing singleton*.
%
%      SINCRONIZAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINCRONIZAR.M with the given input arguments.
%
%      SINCRONIZAR('Property','Value',...) creates a new SINCRONIZAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sincronizar_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sincronizar_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sincronizar

% Last Modified by GUIDE v2.5 09-Apr-2017 21:25:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sincronizar_OpeningFcn, ...
                   'gui_OutputFcn',  @sincronizar_OutputFcn, ...
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


% --- Executes just before sincronizar is made visible.
function sincronizar_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sincronizar (see VARARGIN)

% Choose default command line output for sincronizar
handles.output = hObject;


%   configuración de ejes 
axes(handles.axSync);
% p: mover para que cargue con la interfaz
title('Lecturas de intensidad de MVC');
xlabel('Tiempo (ms)');
ylabel('Intensidad de EMG');

% Update handles structure
guidata(hObject, handles);
%i0
global mvcKeepReading arrayUserPrompts syncCaptureMode rawMvcValues ...
    mvcBaseLine mvcReadValue mainGui arduino flagFirstReading lineRawMvcValues;
arrayUserPrompts = [{'Coloque su brazo sin realizar ninguna contracción'}, ...
                    {'Haga tres contracciones, dejando unos instantes entre ellas'}];
mvcKeepReading = true;
syncCaptureMode = 1;
rawMvcValues = 0;
mvcBaseLine = 0;
mvcReadValue = 0;
flagFirstReading = false;

set(handles.txtUserPrompt,'String',arrayUserPrompts(1));
%   lectura de variables de entorno de aplicación
mainGui = getappdata(0, 'mainGui');
arduino = getappdata(mainGui, 'arduino');

lineRawMvcValues = animatedline('Parent',handles.axSync,'Color','r');

pause on;

% UIWAIT makes sincronizar wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sincronizar_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mvcKeepReading  arduino rawMvcValues flagFirstReading lineRawMvcValues;
mvcKeepReading = true;
rawMvcValues = 0;

% lineRawMvcValues = animatedline('Parent',handles.axSync,'Color','r');

if flagFirstReading
%     axes(handles.axSync);
    clearpoints(lineRawMvcValues);
%     delete(lineRawMvcValues);
end

grid on;
timeSync1 = tic;
i=1;
fopen(arduino);

% while toc(timeSync1)<100
while mvcKeepReading
   %   podría ver si hay bytes available y luego leer
   
%    mvcReadValue(i) = fscanf(arduino,'%d');
%     mvcTimeCapture(i) = toc(timeSync1);
%     addpoints(h1,mvcTimeCapture(i),mvcReadValue(i));
    
%04-09 para evitar redimensionar el array en tiempo de ejecución, luego
%usar getpoints de la animatedline
    mvcReadValue = fscanf(arduino,'%d')
    mvcTimeCapture = toc(timeSync1);
    addpoints(lineRawMvcValues,mvcTimeCapture,mvcReadValue);
    drawnow
    i=i+1;
%     pause(0.09);
end
% fclose(arduino);

%   encontrar el valor de MVC
% [~,rawMvcValues] = getpoints(lineRawMvcValues);
% maxValueMvc = max(y1);
% mvc = mvcReadValue - min(mvcReadValue);
% maxValueMvc = max(mvc);
% fhUpdateThreshold = getappdata(mainGui,'fhUpdateThreshold');
% setappdata(mainGui,'maxMvc',maxValueMvc);
% feval(fhUpdateThreshold);


% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mvcKeepReading mvcBaseLine rawMvcValues syncCaptureMode mainGui ...
    arduino flagFirstReading lineRawMvcValues;
mvcKeepReading = false; 
fclose(arduino);

[~,rawMvcValues] = getpoints(lineRawMvcValues);

if syncCaptureMode==1
    mvcBaseLine = mean(rawMvcValues);
    setappdata(mainGui,'mvcBaseLine',mvcBaseLine);
    flagFirstReading = true;
else
    realValues = rawMvcValues - mvcBaseLine;
    mvc = max(realValues);
    setappdata(mainGui,'mvc',mvc);
    flagFirstReading = true;
end

set(handles.btnNext,'Enable','on');




% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% hObject    handle to btnNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global arrayUserPrompts;
global syncCaptureMode;
if syncCaptureMode == 1
    syncCaptureMode = 2;
end

%{
actualizar variable global con la media de la señal leída
cambiar el prompt de usuario
limpiar datos del axes

%}

% mvcBaseLine = mean(rawMvcValues);
set(handles.txtUserPrompt,'String',arrayUserPrompts(2));
% msgbox(mensaje);

%%codigo de prueba
% h2 = animatedline;
% for i=1:5
% addpoints(h2,i,i*i/2);
% drawnow
% end
% [a,points] = getpoints(h2)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% verificar si hay que hacer global arduino;
global arduino;
fclose(arduino);
delete(hObject);

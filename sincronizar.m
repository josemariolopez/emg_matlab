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

% Last Modified by GUIDE v2.5 08-Mar-2017 01:00:34

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

% Update handles structure
guidata(hObject, handles);
global flag;
flag = false;




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

%   configuración de ejes 
axes(handles.axSync);
title('Lecturas de intensidad de MVC');
xtitle('Tiempo (ms)');
ytitle('Intensidad de EMG');

%   lectura de variables de entorno
mainGui = getappdata(0, 'mainGui');
arduino = getappdata(mainGui, 'arduino');

%   grafica de EMG
h1 = animatedline('Parent',handles.axSync,'LineWidth',1.5,'Color','r');
grid on;

timeSync1 = tic;
i=1;
fopen(arduino);
global flag;
flag=true;
% while toc(timeSync1)<100
while flag
    t1(i) = toc(timeSync1);
%   podría ver si hay bytes available y luego leer
    y1(i) = fscanf(arduino,'%d');
    addpoints(h1,t1(i),y1(i));
    drawnow
    i=i+1;
%   necesario añadir pause(0.1)
end
fclose(arduino);

%   encontrar el valor de MVC
% [~,force] = getpoints(h1);
mvc = max(y1);
fhUpdateThreshold = getappdata(mainGui,'fhUpdateThreshold');
setappdata(mainGui,'mvc',mvc);
feval(fhUpdateThreshold);


% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global flag;
flag = false; 

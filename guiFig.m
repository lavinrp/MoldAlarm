function varargout = guiFig(varargin)
% GUIFIG M-file for guiFig.fig
%      GUIFIG, by itself, creates a new GUIFIG or raises the existing
%      singleton*.
%
%      H = GUIFIG returns the handle to a new GUIFIG or the handle to
%      the existing singleton*.
%
%      GUIFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIFIG.M with the given input arguments.
%
%      GUIFIG('Property','Value',...) creates a new GUIFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiFig_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      exit.  All inputs are passed to guiFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiFig

% Last Modified by GUIDE v2.5 06-Apr-2015 12:36:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiFig_OpeningFcn, ...
                   'gui_OutputFcn',  @guiFig_OutputFcn, ...
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


% --- Executes just before guiFig is made visible.
function guiFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiFig (see VARARGIN)

%initialize variables for GUI

%set(handles.useRefImg, true);
useRefImg = false;
handles.useRefImg = useRefImg;
guidata(hObject, handles);

% Choose default command line output for guiFig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Testing 2~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
handles.centralColor = 0;
handles.colorRange = 0;
handles.obj_size = 0;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

initialize(handles); %sets Initial values for global values


% --- Outputs from this function are returned to the command line.
function varargout = guiFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%===================================================================
%creates objects within the gui
% --- Executes during object creation, after setting all properties.


function Frames_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
function Folder_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
   
    
%==========================================================================
%callback functions for text input

%------TAKES input values of the variables
function Frames_Callback(hObject, eventdata, handles)

    global NumFrames;
    
    NumFrames = str2num(get(hObject,'String'));

function Folder_Callback(hObject, eventdata, handles)
    
    global ImageFolder;
    global Text;

   ImageFolder = get(hObject,'String'); %returns content as a string
   folderExists = isdir(ImageFolder);

   if not(folderExists)
   %updatelog text
         text = get(handles.logText,'string');
         s = size(text,1);
         newText = strcat('image Folder: "', ImageFolder, '" does not exist');
         Text{s+1} = newText;
         
         set(handles.Folder,'string',' ');
         set(handles.logText,'string',Text);
   end
   
   set(handles.reference,'enable','on');


%----------------------------------------------------------------------
% checkboxes  
 
%==========================================================================
% BUTTON CALLBACKS

function reference_Callback(hObject, eventdata, handles)
   
   % get the frames for cropping the images and the reference Image
   global Frames;
   global Text;
   global ImageFolder
   
   setButtonsForRun(handles); 
   
   getFrames();
   
   %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~testing~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   %directory for tif files
   tifFiles = dir(strcat(ImageFolder,'/*.tif')); 
   
   %find reference Image
   refImageName = tifFiles(1).name; %reference image should always be the first image
   refImagePath = strcat(ImageFolder,'/',refImageName);  %finds the filepath
   refImage = imread(refImagePath);
   cropedRefImage = imcrop(refImage(:,:,1), Frames);
   
   %find Calibration Image
   calibrationImageName = tifFiles(2).name;
   calibrationImagePath = strcat(ImageFolder,'/',calibrationImageName);  %finds the filepath
   calibrationImage = imread(calibrationImagePath);
   cropedSecondImage = imcrop(calibrationImage(:,:,1), Frames);

   
   %for the greater good :'(
   
   %this is the initial decloration of the variables central_color,
   %color_range, and object_size
   %they will be passed to start_callback from here
   global central_color;
   global color_range;
   global object_size;
   
   %Calibrate for image analysis
   
   %auto calibrate
   if ~get(handles.CalibrationType, 'Value')
       [central_color, color_range, object_size] = getObjectInfo(cropedSecondImage);
       maxColor = central_color + color_range;
       minColor = central_color - color_range;
        
       %set gui values from calibration
       set(handles.MaxColor, 'String', num2str(maxColor));
       set(handles.MinColor, 'String', num2str(minColor));
       set(handles.ObjectSize, 'String', num2str(object_size));
   end
   %update guidata
   guidata(hObject, handles);
   %This should work instead of global vars, but it doesnt because matlab is dumb
   % Update handles structure
   %guidata(hObject, handles);
   
   %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   numOfFrames = size(Frames,1);
   
   %updating log text
   %~~~~~~~~~~~~~~~~~~~~~~~~testing 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   text = get(handles.logText,'string');
   
   s = size(text,1);
   newText = strcat('I got ',num2str(numOfFrames),' frame(s)');
   Text{s+1} = newText;
   set(handles.logText,'string',Text);
   %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   %set Buttons
   set(handles.start,'enable','on');
   set(handles.reset,'enable','on');
  
   
   
function reset_Callback(hObject, eventdata, handles)

    set(handles.reference,'enable','on')
    set(handles.reset,'enable','off')
    set(handles.start,'enable','off') 
    set(handles.Frames,'enable','on');
    set(handles.Folder,'enable','on');
 
    
function start_Callback(hObject, eventdata, handles)

    global HasMold;
    global Beep;
    global NumBeep;
    global Done;
    global ImageFolder;
    global AllOldImagesProcessed;
    global NumImagesProcessed;
    global Text;
    
    %the variables central_color, color_range, and object_size are created
    %in the reference_callback function and are only used here.
    %
    %The variables will be passed to processImage
    global central_color;
    global color_range;
    global object_size;
%     minColor = str2num(handles.MinColor);
%     maxColor= str2num(handles.MaxColor);
%     objectSize = str2num(handles.ObjectSize);
    minColor = str2num(get(handles.MinColor, 'string'));
    maxColor = str2num(get(handles.MaxColor, 'string'));
    objectSize = str2num(get(handles.ObjectSize, 'string'));
    
    %TODO: remove figure?
    figure;
    
    setButtonsForRun(handles);
    
    while not(Beep) && not(Done)
        
        pause(10);
        % run the program as longa as no mold was found or the alarm is on
        % check how many files there are in the image folder

        tifFiles = dir(strcat(ImageFolder,'/*.tif')); 
        newNumFiles = length(tifFiles);

        %first process all images that are already there
        if (not(AllOldImagesProcessed)&& (newNumFiles>NumImagesProcessed))
                for imageNumber = (NumImagesProcessed+1):length(tifFiles)
                    newimageName = tifFiles(imageNumber).name;
                    processImage(newimageName, minColor, maxColor, objectSize);
                    if Beep
                        break;
                    end
                    pause(1);
                end
         else
              AllOldImagesProcessed = true;
        end

        %process new images as they show up in the image folder one by one
        if (AllOldImagesProcessed && (newNumFiles>NumImagesProcessed)&& not(Beep))
            pause(30);
            imageNameNew = tifFiles(NumImagesProcessed+1).name;
            processImage(imageNameNew, minColor, maxColor, objectSize);     
        end       
        pause(1);
    end
    
    if Beep
        %updatelog text
         Text = get(handles.logText,'string');
         s = size(Text,1);
         newText = strcat('Check if image: ',HasMold(NumBeep).imageName,' has mold');
         Text{s+1} = newText;
         set(handles.logText,'string',Text);
        
        %set Buttons
        setButtonsForWait(handles);
        
        %turn alarm on
        while Beep;
            load handel;
            %TODO: move this out of the loop
            player = audioplayer(y, Fs);
            play(player);
            pause(10);
        end
    end
    
    
% 
 function contin_Callback(hObject, eventdata, handles)
% 
    global Beep;
    global Done;
    global ImageFolder;
    global AllOldImagesProcessed;
    global NumImagesProcessed;
    global NumBeep;
    global HasMold;
    global Text;
    
    
    %the variables central_color, color_range, and object_size are created
    %in the reference_callback function and are only used here.
    %
    %The variables will be passed to processImage
    %TODO: remove variables below and comment above
%     global central_color;
%     global color_range;
%     global object_size; 

    
    Beep = false;
    setButtonsForRun(handles);
    
    while not(Beep)&& not(Done)
        
        pause(10);
        % run the program as longa as no mold was found or the alarm is on
        % check how many files there are in the image folder

        tifFiles = dir(strcat(ImageFolder,'/*.tif')); 
        newNumFiles = length(tifFiles);
        
        %first process all images that are already there
        if (not(AllOldImagesProcessed)&&(newNumFiles>NumImagesProcessed))
                for imageNumber = (NumImagesProcessed+1):length(tifFiles)
                    newimageName = tifFiles(imageNumber).name;
                    processImage(newimageName, minColor, maxColor, objectSize);
                    if Beep
                        break;
                    end
                    pause(1);
                end
         else
              AllOldImagesProcessed = true;
        end

        %process new images as they show up in the image folder one by one
        if (AllOldImagesProcessed && (newNumFiles>NumImagesProcessed)&& not(Beep))
            pause(30);
            imageNameNew = tifFiles(NumImagesProcessed+1).name;
            processImage(imageNameNew, handels.centralColor, handels.colorRange, handels.obj_size);     
        end
        pause(1);
    end
    
    if Beep
         %updatelog text
         text = get(handles.logText,'string');
         s = size(text,1);
         newText = strcat('Check if image: ',HasMold(NumBeep).imageName,' has mold');
         Text{s+1} = newText;
         text{s+1} = newText;
         
         if s>8
             set(handles.logText,'string',text(s+1,:));
         else
             set(handles.logText,'string',text);
         end
         
         %set Buttons
         setButtonsForWait(handles);
    
        while Beep;          
            load handel;
            player = audioplayer(y, Fs);
            play(player);
            pause(10);
        end
    end
    
%==================================================
%other functions

function setButtonsForRun(handles)   
    set(handles.start,'enable','off');
    set(handles.reset,'enable','off');
    set(handles.Frames,'enable','off');
    set(handles.Folder,'enable','off');  
    set(handles.contin,'enable','off');
    set(handles.reference,'enable','off');
    
function setButtonsForWait(handles)
    set(handles.contin,'enable','on');

function y = initialize(handles)
   % 'initialize'

   global Beep;
   global NumFrames;
   global BWThreshold;
   global NumImagesProcessed;
   global AllOldImagesProcessed;
   global NumBeep;
   global OutputFolder;
   global EulerNumber;
   global GSFgridsize;
   global BWFgridsize;
   global Done;
   global Text;

   %initial settings
   
   
   NumBeep = 0;
   AllOldImagesProcessed = false;
   Beep = false;
   NumFrames = 1;
   BWThreshold = 3.3;
   NumImagesProcessed = 0;
   EulerNumber = 4;
   GSFgridsize = 2;
   BWFgridsize = 2;
   Done = false;
  
   %make an output folder
   time = fix(clock);
   OutputFolder = strcat('output',num2str(time(1)),'_',num2str(time(2)),'_',num2str(time(3)),'_',...
          num2str(time(4)),'_',num2str(time(5)));
   mkdir(OutputFolder);
   
   imageFolder = strcat(OutputFolder,'/images');
   mkdir(imageFolder);
    
   %initialize GUI
   set(handles.contin,'enable','off');
   set(handles.start,'enable','off');
   set(handles.reset,'enable','off');
   set(handles.reference,'enable','off');
   set(handles.Folder,'enable','on');
   set(handles.Frames,'enable','on');
   Text{1} = 'First enter image folder, check settings, and then press ENTER';
   set(handles.logText,'string',Text);
   
   set(handles.Frames,'string','1');
   set(handles.Folder,'string','');
   
%------------------------------------------------------------------------
% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
    global Done;
    global OutputFolder;

    Done = true;
    
    str = strcat(OutputFolder,'/output.mat');
    save(str);
    delete(handles.figure1);
    clear all;
    close all;


% --- Executes on button press in UseRefImg.
function UseRefImg_Callback(hObject, eventdata, handles)
% hObject    handle to UseRefImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% Hint: get(hObject,'Value') returns toggle state of UseRefImg


% --- Executes on button press in CalibrationType.
function CalibrationType_Callback(hObject, eventdata, handles)
% hObject    handle to CalibrationType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Manual Calibration on
if get(handles.CalibrationType, 'Value')
    set(handles.MaxColor, 'enable', 'on');
    set(handles.MinColor, 'enable', 'on');
    set(handles.ObjectSize, 'enable', 'on');
    %user can start program after calibration
    set(handles.start, 'enable', 'on');
%manual Calibration Off
else
    set(handles.MaxColor, 'enable', 'inactive');
    set(handles.MinColor, 'enable', 'inactive');
    set(handles.ObjectSize, 'enable', 'inactive');
    %if program is not calibrated user can not start program
    set(handles.start, 'enable', 'off');
end

%update variables
guidata(hObject, handles);


% Hint: get(hObject,'Value') returns toggle state of CalibrationType



function MaxColor_Callback(hObject, eventdata, handles)
% hObject    handle to MaxColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxColor as text
%        str2double(get(hObject,'String')) returns contents of MaxColor as a double


% --- Executes during object creation, after setting all properties.
function MaxColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinColor_Callback(hObject, eventdata, handles)
% hObject    handle to MinColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinColor as text
%        str2double(get(hObject,'String')) returns contents of MinColor as a double


% --- Executes during object creation, after setting all properties.
function MinColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ObjectSize_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ObjectSize as text
%        str2double(get(hObject,'String')) returns contents of ObjectSize as a double


% --- Executes during object creation, after setting all properties.
function ObjectSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



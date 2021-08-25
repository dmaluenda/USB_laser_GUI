%              ----------------------------------------------
% % ---------- D R.   D A V I D   M A L U E N D A   N I U B O ----------- %
% %            ----------------------------------------------             %
% %                  Universidad Complutense de Madrid                    %
% %                                                                       %
% %                                                     CC: BY , NC , SA  %
% % ---------------------------- 2 0 1 7 -------------------------------- %
%
% This software provides a GUI to manage the Monocrom C4050USB-SMF USBlaser
% (Diode Laser Pigtailed at 405nm -BLUE-) via the USB PIC CTL 7V driver.
%
%       --- RUN THIS SCRIPT instead of opening the .fig ---
%
% USB PIC CTL 7V driver is employed as a SERIAL PORT, thus before running
% this script, the name of the SERIAL PORT must be known.
% A pop up menu shows all available ports then, choose the correct one.
%
% This program is made and tested in a MATLAB r2015b in a MacOS platform.
% Whitout installing any previous driver (just PlugAndPlay), the laser is
% connected to the port named '/dev/tty.usbmodemXXXXX'.
%
%
%                    Program under licence of Creative Commons (By,NC,SA).
% ------------------------------------------------------------------------


function varargout = USBlaser_monocrom(varargin)
    % USBlaser_monocrom MATLAB code for USBlaser_monocrom.fig
    %      USBlaser_monocrom, by itself, creates a new USBlaser_monocrom or
    %      raises the existing singleton*.
    %
    %      H = USBlaser_monocrom returns the handle to a new USBlaser_monocrom
    %      or the handle to the existing singleton*.
    %
    %      USBlaser_monocrom('CALLBACK',hObject,eventData,handles,...) calls
    %      the local function named CALLBACK in USBlaser_monocrom.M with the
    %      given input arguments.
    %
    %      USBlaser_monocrom('Property','Value',...) creates a new 
    %      USBlaser_monocrom or raises the existing singleton*. 
    %      Starting from the left, property value pairs are
    %      applied to the GUI before USBlaser_monocrom_OpeningFcn gets called.
    %      An unrecognized property name or invalid value makes property
    %      application stop. 
    %      All inputs are passed to USBlaser_monocrom_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help USBlaser_monocrom

    % Last Modified by GUIDE v2.5 19-Apr-2017 12:48:06

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @USBlaser_monocrom_OpeningFcn, ...
                       'gui_OutputFcn',  @USBlaser_monocrom_OutputFcn, ...
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




% --- Executes just before USBlaser_monocrom is made visible.
function USBlaser_monocrom_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to USBlaser_monocrom (see VARARGIN)
    %
    % UIWAIT makes USBlaser_monocrom wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


    % %%% --- S E R I A L - P O R T - O P T I O N S --- %%% -------------------

    % get and show all available serial ports
    INSTR_OBJ   = instrhwinfo('serial');
    INSTRs_TEXT = INSTR_OBJ.SerialPorts;
    set(handles.SERIALPORTS_PUM, 'string',INSTRs_TEXT );

    % load all available serial ports
    for iSPs = 1:length(INSTRs_TEXT)
        handles.SERIALs(iSPs) = serial(INSTRs_TEXT{iSPs});
    end

    % draw some images on the GUI
    [image,map] = imread('Background_Image.gif');
    imshow( image,map , 'Parent',handles.IMAGE_FRAME );

    [image,map] = imread('UCM_logo.png');
    imshow( image,map ,'Parent',handles.LOGO_FRAME );

    [image,map] = imread('CC_by-nc-sa.jpg');
    imshow( image,map , 'Parent',handles.CC_FRAME );

    % %%% --------------------------------------------- %%% -------------------


    % Choose default command line output for USBlaser_monocrom
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);




% --- Executes on selection change in SERIALPORTS_PUM.
function SERIALPORTS_PUM_Callback(hObject, eventdata, handles)
    % hObject    handle to SERIALPORTS_PUM (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: contents = cellstr(get(hObject,'String')) returns SERIALPORTS_PUM 
    % contents as cell array
    % contents{get(hObject,'Value')} returns selected item from SERIALPORTS_PUM


    % %%% --- S E R I A L - P O R T - C O N N E C T I O N --- %%% -------------

    % get the new value of the PopUpMenu
    SERIAL_PORT_VALUE = get( handles.SERIALPORTS_PUM , 'Value' );

    % close the port if its open
    if strcmp( handles.SERIALs(SERIAL_PORT_VALUE).Status , 'open' )
        fclose( handles.SERIALs(SERIAL_PORT_VALUE) );
    end

    % set the TERMINATOR and the BrandRate and try to open the port 
    set( handles.SERIALs(SERIAL_PORT_VALUE) , ...
         'BaudRate',9600 , 'Terminator','CR' );
    try 
        fopen( handles.SERIALs(SERIAL_PORT_VALUE) );
        STRING_SP_DISPLAY = handles.SERIALs(SERIAL_PORT_VALUE).Name;
    catch
        STRING_SP_DISPLAY = 'WRONG SERIAL PORT: Imposible to open this port!';
        SERIAL_PORT_VALUE = -1;
    end
    set( handles.SERIAL_PORT_DISP , 'String',STRING_SP_DISPLAY );

    % save the opened port to close at the end of the program (just once)
    OPEN_SP_VALUE = get( handles.OPEN_SERIAL_PORTS,'Value' );
    if any(OPEN_SP_VALUE ~= SERIAL_PORT_VALUE) && SERIAL_PORT_VALUE > 0
        if any(OPEN_SP_VALUE==0)
            OPEN_SP_VALUE(end) = SERIAL_PORT_VALUE;
        else
            OPEN_SP_VALUE(end+1) = SERIAL_PORT_VALUE;
        end
    end
    set( handles.OPEN_SERIAL_PORTS , 'Value',OPEN_SP_VALUE )

% %%% -------------------------------------------------- %%% --------------






% --- Executes on button press in ON_BUTTON.
function ON_BUTTON_Callback(hObject, eventdata, handles)
    % hObject    handle to ON_BUTTON (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hint: get(hObject,'Value') returns toggle state of ON_BUTTON


    % %%% --- L A S E R - O N --- %%% -----------------------------------------

    COMMAND_str = 'LDON';
    ON_VALUE    = get( handles.ON_BUTTON , 'Value' );

    % Change the string of the button depending its value
    if ON_VALUE
        BUTTON_STRING = 'POWER OFF';
        set( handles.ON_BUTTON , 'ForegroundColor',[0.9 0 0]);
    else
        BUTTON_STRING = 'POWER ON';
        set( handles.ON_BUTTON , 'ForegroundColor',[0 0 0]);
    end
    set( handles.ON_BUTTON , 'String',BUTTON_STRING );

    % send the command to the driver
    fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
             [COMMAND_str num2str(ON_VALUE)]                           );

    % read and display the answer recieved from the driver
    OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
    set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );

    % show the state (ON/OFF) of the laser with the LED
    if strcmp( OUTPUT_VALUE(1:end-1) , 'Off' ) , LED_VALUE = 0;
    else LED_VALUE = 1; end
    set( handles.ON_LED , 'Value',LED_VALUE );

    % save the serial port used if it's the 1st attempt to get on andall is correct
    if handles.RIGHT_SERIAL_PORT.Value == 0 && strcmp( OUTPUT_VALUE(1:end-1) , 'On')
        RIGHT_SP_VALUE = get( handles.SERIALPORTS_PUM , 'Value' );
        set( handles.RIGHT_SERIAL_PORT , 'String',num2str(RIGHT_SP_VALUE) );
    end

    % read the power value from the driver
    fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , 'GTPT' );
    OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
    if str2double(OUTPUT_VALUE) > 1023, OUTPUT_VALUE = num2str(0); end

    % convert the uint16 power value to mW value (or 0mW if it's power OFF)
    POWER_STRING = ['~ ' num2str(round(0.06520*str2double(OUTPUT_VALUE)-17.74)) ' mW'];
    if 0.06520*str2double(OUTPUT_VALUE)-17.74 < 0, POWER_STRING='~ 0 mW'; 
    elseif  ~LED_VALUE , POWER_STRING='0 mW'; end

    % display the power value in the slider and numerically
    set( handles.POWER_DISP   , 'String',POWER_STRING )
    set( handles.POWER_SLIDER , 'Value',str2double(OUTPUT_VALUE) )

% %%% ------------------------- %%% ---------------------------------------






% --- Executes on slider movement.
function POWER_SLIDER_Callback(hObject, eventdata, handles)
    % hObject    handle to POWER_SLIDER (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


    % %%% --- P O W E R - S E T T I N G --- %%% -------------------------------

    COMMAND_str = 'LDPT';
    POWER_VALUE = get( handles.POWER_SLIDER,'Value' );

    % send the command to the driver
    fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
             [COMMAND_str num2str(round(POWER_VALUE))]                );

    % read and display the answer from the driver
    OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
    set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );

    % convert the uint16 power value to mW value (or 0mW if it's power OFF)
    POWER_STRING = ['~ ' num2str(round(0.06520*str2double(OUTPUT_VALUE)-17.74)) ' mW'];
    if 0.06520*str2double(OUTPUT_VALUE)-17.74 < 0 , POWER_STRING='~ 0 mW';
    elseif  ~handles.ON_LED.Value , POWER_STRING='0 mW'; end

    % display the power value
    set( handles.POWER_DISP , 'String',POWER_STRING )

% %%% --------------------------------- %%% -------------------------------






% --- Executes on selection change in CW_PUM.
function CW_PUM_Callback(hObject, eventdata, handles)
    % hObject    handle to CW_PUM (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: contents = cellstr(get(hObject,'String')) returns CW_PUM contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from CW_PUM


    % %%% --- C W - or - P U L S E D --- %%% ----------------------------------

    CW_VALUE    = get( handles.CW_PUM,'Value' );
    FREQ_VALUE  = str2double(get( handles.FREQ_TEXT,'String' ));

    % % fix the limits for the frequency
    % if      FREQ_VALUE < 1   , FREQ_VALUE = 1;
    % elseif  FREQ_VALUE > 1000, FREQ_VALUE = 1000;
    % end

    % send the command to the driver
    fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
             ['LMCW' num2str((CW_VALUE==1))]                          );

    % read and display the answer from the driver     
    OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
    set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );


% %%% ------------------------------ %%% ----------------------------------






function FREQ_TEXT_Callback(hObject, eventdata, handles)
    % hObject    handle to FREQ_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of FREQ_TEXT as text
    %        str2double(get(hObject,'String')) returns contents of FREQ_TEXT as a double


    % %%% --- F R E Q - S E T T I N G --- %%% ---------------------------------

    CW_VALUE    = get( handles.CW_PUM,'Value' );
    FREQ_VALUE  = str2double(get( handles.FREQ_TEXT,'String' ));

    % fix the limits for the frequency
    if      FREQ_VALUE < 1   , FREQ_VALUE = 1;
    elseif  FREQ_VALUE > 1000, FREQ_VALUE = 1000;
    end

    % the command depends on the mode (Pulsed/Square)
    switch CW_VALUE
        case 3 % Square
            % send the command to the driver
            fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
                     ['LMFS' num2str(round(FREQ_VALUE)*10)]         );
            
            % read and display the answer from the driver
            OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
            set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );
            
        case 2 % Pulsed
            % send the command to the driver
            fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
                     ['LMFC' num2str(round(FREQ_VALUE)*10)]         );
                 
            % read and display the answer from the driver
            OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
            set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );
    end

% %%% ------------------------------- %%% ---------------------------------





function WIDTH_TEXT_Callback(hObject, eventdata, handles)
    % hObject    handle to WIDTH_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of WIDTH_TEXT as text
    %        str2double(get(hObject,'String')) returns contents of WIDTH_TEXT as a double


    % %%% --- P U L S E - W I D T H - S E T T I N G --- %%% -------------------

    % get the input value
    WIDTH_VALUE = str2double(get( hObject,'String' ))*1000;

    % fix the limits
    if WIDTH_VALUE < 0.1, WIDTH_VALUE = 0.1; 
    elseif  WIDTH_VALUE > 900000, WIDTH_VALUE = 900000; 
    end

    % send the command to the driver
    fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
             ['LMWC' num2str(WIDTH_VALUE)]       );
         
    % read and display the answer from the driver     
    OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
    set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );

% %%% -------------------------------------------- %%% --------------------






function INPUT_TEXT_Callback(hObject, eventdata, handles)
    % hObject    handle to INPUT_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of INPUT_TEXT as text
    %        str2double(get(hObject,'String')) returns contents of INPUT_TEXT as a double


    % %%% --- I N P U T - C O M M A N D --- %%% -------------------------------

    % get and send the command to the driver
    COMMAND = get( hObject,'String' );
    fprintf( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) , ...
             COMMAND    );
         
    % read and display the answer from the driver
    OUTPUT_VALUE = fgets( handles.SERIALs( get(handles.SERIALPORTS_PUM,'Value') ) );
    set( handles.OUTPUT_TEXT , 'String',OUTPUT_VALUE );

% %%% --------------------------------- %%% -------------------------------






% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)


    % %%% --- C L O S E - & - E X I T --- %%% ---------------------------------

    % ger the serial port of the laser (eventhough it's not currently selected) 
    right_serial_port = str2double( get( handles.RIGHT_SERIAL_PORT,'String' ) );

    % force to turn OFF the laser if it was turned on at least once
    if right_serial_port ~= 0
        fprintf( handles.SERIALs( right_serial_port ) , 'LDON0' );
    end

    % close the opened ports which has been opened in this program at least once
    OPEN_SP_VALUEs = get( handles.OPEN_SERIAL_PORTS,'Value' );
    for i = OPEN_SP_VALUEs
        if i ~= 0  &&  strcmp( handles.SERIALs(i).Status , 'open' )
            fclose( handles.SERIALs(i) );
        end
    end

    % delete all serial ports loaded
    delete(handles.SERIALs(:));

    % %%% ------------------------------- %%% ---------------------------------


    % Hint: delete(hObject) closes the figure
    delete(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = USBlaser_monocrom_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;










%   ---   ---   CrateFcn's with default altered values   ---   ---   ---  

% --- Executes during object creation, after setting all properties.
function SERIALPORTS_PUM_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to SERIALPORTS_PUM (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function SERIAL_PORT_DISP_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to SERIAL_PORT_DISP (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function RIGHT_SERIAL_PORT_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to RIGHT_SERIAL_PORT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function OPEN_SERIAL_PORTS_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to OPEN_SERIAL_PORTS (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function POWER_SLIDER_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to POWER_SLIDER (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: slider controls usually have a light gray background.

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

    set( hObject , 'Max',1024 );

% --- Executes during object creation, after setting all properties.
function POWER_DISP_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to POWER_DISP (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function CW_PUM_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to CW_PUM (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function FREQ_TEXT_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to FREQ_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function WIDTH_TEXT_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to WIDTH_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function INPUT_TEXT_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to INPUT_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function IMAGE_FRAME_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to INPUT_TEXT (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    %
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.

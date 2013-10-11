% PROCESSRATDATAGUI MATLAB code for processRatDataGui.fig
%      PROCESSRATDATAGUI, by itself, creates a new PROCESSRATDATAGUI or raises the existing
%      singleton*.
%
%      H = PROCESSRATDATAGUI returns the handle to a new PROCESSRATDATAGUI or the handle to
%      the existing singleton*.
%
%      PROCESSRATDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSRATDATAGUI.M with the given input arguments.
%
%      PROCESSRATDATAGUI('Property','Value',...) creates a new PROCESSRATDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before processRatDataGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to processRatDataGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
function varargout = processRatDataGui(varargin)
    % Edit the above text to modify the response to help processRatDataGui

    % Last Modified by GUIDE v2.5 11-Oct-2013 14:45:19

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @processRatDataGui_OpeningFcn, ...
                       'gui_OutputFcn',  @processRatDataGui_OutputFcn, ...
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
end

%======================================================================
% My functions
%======================================================================

function loadData(strFolder, hObject, stctHandles)
    stctHandles.strBaseFolder = strFolder;
    guidata(hObject, stctHandles);
    set(stctHandles.tbxDataFolder, 'String', strFolder);

    try
        % Load the data from the folder and store the resultant object in the
        % handles of this figure for access from other methods.
        objRatData = RatData(strFolder);
        stctHandles.objRatData = objRatData;
        guidata(hObject, stctHandles);

        % Plot the locations of the spikes (and the regions if they exist).
        plotSpikeAndRegions(stctHandles);
    catch exFailedToLoad
        % Some error occurred. Alert the user.
        errordlg('Please ensure that the data folder is in the proper format.', ...
                 'Failed to load data', 'modal');
    end
end

function saveData(hObject, stctHandles)
    strFolder = uigetdir();

    if strFolder ~= 0
        stctHandles.strAnalysisFolder = strFolder;
        guidata(hObject, stctHandles);
        strFile = [strFolder filesep() 'data.mat'];

        % Collect the values that we want to save.
        stctRegions = stctHandles.stctRegions;
        nRippleWaveChannel = str2num(get(stctHandles.tbxRippleWave, 'String'));
        nSharpLowChannel = str2num(get(stctHandles.tbxSharpLow, 'String'));
        nSharpHighChannel = str2num(get(stctHandles.tbxSharpHigh, 'String'));
        dMaxFiringRate = str2num(get(stctHandles.tbxMaxFiring, 'String'));
        vInterneurons = str2num(get(stctHandles.tbxInterneuronList, 'String'));

        save(strFile, '-v7.3', 'stctRegions', 'nRippleWaveChannel', ...
             'nSharpLowChannel', 'nSharpHighChannel', 'dMaxFiringRate', 'vInterneurons');
    end
end

function runAnalysis(stctHandles)
    % Display a timer.
    nAnalysisTic = tic();
    updateMessage = @(~, ~) set( ...
        stctHandles.txtMessage, ...
        'String', ['Analysis has been running for ' ...
                   num2str(round(toc(nAnalysisTic))) ' seconds']);
    objTimer = timer( ...
        'ExecutionMode', 'fixedRate', ...
        'Period', 1, ...
        'TimerFcn', updateMessage);
    start(objTimer);

    % Retrieve necessary variables.
    objRatData = stctHandles.objRatData;
    stctRegions = stctHandles.stctRegions;
    nRippleWaveChannel = str2num(get(stctHandles.tbxRippleWave, 'String'));
    nSharpLowChannel = str2num(get(stctHandles.tbxSharpLow, 'String'));
    nSharpHighChannel = str2num(get(stctHandles.tbxSharpHigh, 'String'));
    dMaxFiringRate = str2num(get(stctHandles.tbxMaxFiring, 'String'));
    vInterneurons = str2num(get(stctHandles.tbxInterneuronList, 'String'));

    % Set the current channels in each of the rat's conditions.
    cellChannels = {nRippleWaveChannel, nSharpLowChannel, nSharpHighChannel};

    objRatData.pre.setCurrentChannels(cellChannels{:});
    objRatData.musc.setCurrentChannels(cellChannels{:});
    objRatData.post.setCurrentChannels(cellChannels{:});

    % Compile a list of all sequences.
    cellSequences = {};
    cellConditions = {'pre', 'musc', 'post'};

    for i = 1 : length(cellConditions)
        strCond = cellConditions{i};
        cellRippleSeqs = getRippleSequences(objRatData.(strCond));
        cellWheelSeqs = getWheelSequences(objRatData.(strCond));
        cellPlaceFieldSeqs = getPlaceFieldSequences(objRatData.(strCond));

        cellSequences = {cellSequences; cellRippleSeqs; cellWheelSeqs; ...
                         cellPlaceFieldSeqs};
    end

    % Save the sequences in the analysis folder.
    save([stctHandles.strAnalysisFolder 'cellSequences.mat'], '-v7.3', 'cellSequences');

    % Compute the matrix of rho values and save it.
    mtxRho = computeRhoMatrix(cellSequences);
    save([stctHandles.strAnalysisFolder 'mtxRho.mat'], '-v7.3', 'mtxRho');

    % Compute the matrix of p-values.
    mtxP = computePValues(cellSequences, nTrials, [strFolder 'sequences/']);
    save([stctHandles.strAnalysisFolder 'mtxP.mat'], '-v7.3', 'mtxP');

    % Stop and delete the timer.
    stop(objTimer);
    delete(objTimer);
end

function [vX, vY] = getSpikeLocations(objRatData)
    vX = [objRatData.pre.Spike.xMM; objRatData.musc.Spike.xMM; ...
          objRatData.post.Spike.xMM];
    vY = [objRatData.pre.Spike.yMM; objRatData.musc.Spike.yMM; ...
          objRatData.post.Spike.yMM];
end

function plotSpikeAndRegions(stctHandles)
    % Retrieve the x- and y-values, and plot the location os the spikes.
    [vX, vY] = getSpikeLocations(stctHandles.objRatData);
    plot(stctHandles.axRegions, vX, vY, '.', ...
         'Color', [0.75, 0.75, 0.75]);

    % Remove axis ticks and tick labels.
    set(stctHandles.axRegions, 'XTick', []);
    set(stctHandles.axRegions, 'XTickLabel', []);
    set(stctHandles.axRegions, 'YTick', []);
    set(stctHandles.axRegions, 'YTickLabel', []);

    % Center the plot in the axes.
    dMinX = min(vX);
    dMaxX = max(vX);
    dXPadding = (dMaxX - dMinX) / 10;
    xlim([dMinX - dXPadding, dMaxX + dXPadding]);

    dMinY = min(vY);
    dMaxY = max(vY);
    dYPadding = (dMaxY - dMinY) / 10;
    ylim([dMinY - dYPadding, dMaxY + dYPadding]);

    % If regions have been specified, plot them.
    if isfield(stctHandles, 'stctRegions')
        stctRegions = stctHandles.stctRegions;
        cellFields = fieldnames(stctRegions);
        nFields = length(cellFields);

        mtxColors = [1, 0,   0; ...
                     0, 0,   1; ...
                     0, 0.5, 0];

        % Each field is a region.
        for i = 1 : nFields
            cellSubregions = stctRegions.(cellFields{i});
            nSubregions = length(cellSubregions);

            % Each region can potentially have subregions. Each one is a
            % rectangle. Plot the rectangle and place it below everything
            % else.
            for j = 1 : nSubregions
                hdlRect = rectangle('Parent', stctHandles.axRegions, ...
                                    'Position', cellSubregions{j}, ...
                                    'FaceColor', mtxColors(i, :));
                uistack(hdlRect, 'bottom');
            end
        end
    end
end

function selectRegions(hObject, stctHandles)
    [vX, vY] = getSpikeLocations(stctHandles.objRatData);
    stctRegions = setTrackRegions(vX, vY);

    stctHandles.stctRegions = stctRegions;
    guidata(hObject, stctHandles);

    plotSpikeAndRegions(stctHandles);
end

%======================================================================
% GUIDE functions
%======================================================================

% --- Executes just before processRatDataGui is made visible.
function processRatDataGui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to processRatDataGui (see VARARGIN)

    % Choose default command line output for processRatDataGui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes processRatDataGui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = processRatDataGui_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkbox1
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of radiobutton1
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of radiobutton2
end


function tbxMaxFiring_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxMaxFiring (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxMaxFiring as text
    %        str2double(get(hObject,'String')) returns contents of tbxMaxFiring as a double
end

% --- Executes during object creation, after setting all properties.
function tbxMaxFiring_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxMaxFiring (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function tbxInterneuronList_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxInterneuronList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxInterneuronList as text
    %        str2double(get(hObject,'String')) returns contents of tbxInterneuronList as a double
end

% --- Executes during object creation, after setting all properties.
function tbxInterneuronList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxInterneuronList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function tbxRippleWave_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxRippleWave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxRippleWave as text
    %        str2double(get(hObject,'String')) returns contents of tbxRippleWave as a double
end

% --- Executes during object creation, after setting all properties.
function tbxRippleWave_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxRippleWave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function tbxSharpLow_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxSharpLow (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxSharpLow as text
    %        str2double(get(hObject,'String')) returns contents of tbxSharpLow as a double
end

% --- Executes during object creation, after setting all properties.
function tbxSharpLow_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxSharpLow (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function tbxSharpHigh_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxSharpHigh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxSharpHigh as text
    %        str2double(get(hObject,'String')) returns contents of tbxSharpHigh as a double
end

% --- Executes during object creation, after setting all properties.
function tbxSharpHigh_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxSharpHigh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function tbxDataFolder_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxDataFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxDataFolder as text
    %        str2double(get(hObject,'String')) returns contents of tbxDataFolder as a double
end

% --- Executes during object creation, after setting all properties.
function tbxDataFolder_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxDataFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, ~, handles)
    % hObject    handle to btnBrowse (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    strFolder = uigetdir(pwd());

    if strFolder ~= 0
        loadData([strFolder filesep()], hObject, handles);
    end
end

% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
    % hObject    handle to btnRun (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    runAnalysis(handles);
end

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
    % hObject    handle to btnSave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    saveData(hObject, handles);
end

% --- Executes on button press in btnSelectRegions.
function btnSelectRegions_Callback(hObject, ~, handles)
    % hObject    handle to btnSelectRegions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selectRegions(hObject, handles);
end

% --- Executes on button press in btnBrowseAnalysis.
function btnBrowseAnalysis_Callback(hObject, eventdata, handles)
    % hObject    handle to btnBrowseAnalysis (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

function tbxAnalysisFolder_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxAnalysisFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxAnalysisFolder as text
    %        str2double(get(hObject,'String')) returns contents of tbxAnalysisFolder as a double
end

% --- Executes during object creation, after setting all properties.
function tbxAnalysisFolder_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxAnalysisFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

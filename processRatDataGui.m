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

    % Last Modified by GUIDE v2.5 16-Oct-2013 09:45:41

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
    stctHandles.strDataFolder = strFolder;
    guidata(hObject, stctHandles);
    set(stctHandles.tbxDataFolder, 'String', strFolder);

    try
        % Load the data from the folder and store the resultant object in the
        % handles of this figure for access from other methods.
        objRatData = RatData(strFolder);
        stctHandles.objRatData = objRatData;
        guidata(hObject, stctHandles);

        % Ensure that the appropriate subfolders exsits.
        initDataDirStructure(strFolder);

        % Suggest an analysis folder, and populate the appropriate field.
        stctHandles.strAnalysisFolder = suggestedAnalysisFolder(strFolder);
        guidata(hObject, stctHandles);
        set(stctHandles.tbxAnalysisFolder, ...
            'String', stctHandles.strAnalysisFolder);

        % Plot the locations of the spikes (and the regions if they exist).
        plotSpikeAndRegions(stctHandles);
    catch exFailedToLoad
        % Some error occurred. Alert the user.
        errordlg('Please ensure that the data folder is in the proper format.', ...
                 'Failed to load data', 'modal');
    end
end

function strSuggestion = suggestedAnalysisFolder(strDataFolder)
    % By default, we will suggest that the analysis folder be a subdirectory
    % of the "analysis" folder, which itself lives inside of the given data
    % directory.
    strAnalysisFolder = fullfile(strDataFolder, 'analysis');

    % The suggested name will be "trial{n}", where {n} is the smallest
    % natural number such that "trial{n}" is not a folder. (The braces are
    % used to specify string interpolation; they are not part of the string.)
    % Proceed by finding all folders of this form.
    stctDirs = dir(fullfile(strAnalysisFolder, 'trial*'));
    cellTrialDirs = {stctDirs([stctDirs.isdir]).name};
    cellTokens = discard(@(x) length(x) == 0, ...
                         regexp(cellTrialDirs, '^trial(\d+)$', ...
                                'tokens', 'once'));
    vTrialNums = cellfun(@(x) str2num(x{1}), cellTokens);

    if isempty(vTrialNums)
        strSuggestion = fullfile(strAnalysisFolder, 'trial1');
    else
        % Find the lowest number that we can use.
        vOneToMaxPlus1 = (1 : max(vTrialNums) + 1);
        vMissing = setdiff(vOneToMaxPlus1, vTrialNums);
        strSuggestion = fullfile(strAnalysisFolder, ...
                                 ['trial' num2str(min(vMissing))]);
    end
end

function initDataDirStructure(strFolder)
    strPreFolder = fullfile(strFolder, 'pre-muscimol');
    strMuscFolder = fullfile(strFolder, 'muscimol');
    strPostFolder = fullfile(strFolder, 'post-muscimol');

    if exist(strPreFolder, 'dir')
        mkdirIfNonexistent(fullfile(strPreFolder, 'lfps'));
        mkdirIfNonexistent(fullfile(strPreFolder, 'computed'));
        mkdirIfNonexistent(fullfile(strPreFolder, 'computed', 'spects'));
    end

    if exist(strMuscFolder, 'dir')
        mkdirIfNonexistent(fullfile(strMuscFolder, 'lfps'));
        mkdirIfNonexistent(fullfile(strMuscFolder, 'computed'));
        mkdirIfNonexistent(fullfile(strMuscFolder, 'computed', 'spects'));
    end

    if exist(strPostFolder, 'dir')
        mkdirIfNonexistent(fullfile(strPostFolder, 'lfps'));
        mkdirIfNonexistent(fullfile(strPostFolder, 'computed'));
        mkdirIfNonexistent(fullfile(strPostFolder, 'computed', 'spects'));
    end
end

function mkdirIfNonexistent(strFolder)
    if ~exist(strFolder, 'dir')
        mkdir(strFolder);
    end
end

% Set the analysis folder (as a string in the handles structure) based on the
% string in the corresponding text box.
function setAnalysisFolder(stctHandles)
    strFolder = get(stctHandles.tbxAnalysisFolder, 'String');

    if strcmp(strFolder, stctHandles.strDataFolder)
        errordlg(['Please select a folder different from the ' ...
                  'data folder.']);
    else
        strFolder = [strFolder filesep()];
        stctHandles.strAnalysisFolder = strFolder;
        guidata(hObject, stctHandles);
        set(stctHandles.tbxAnalysisFolder, 'String', strFolder);
    end
end

function invokeNeuroscope(strDatFile)
    % Call neuroscope using the command line, and record the return status.
    nStatus = system(['neuroscope ' strDatFile]);

    % If the status is non-zero, then there was an issue. Alert the user that
    % something went wrong.
    if nStatus ~= 0
        errordlg(['Failed to start Neuroscope with exit code ' ...
                  num2str(nStatus) '. Please ensure that Neuroscope is ' ...
                  'installed and can be started by running `neuroscope` ' ...
                  'in the command line.']);
    end
end

function detectRipples(stctHandles)
    % Create a dialog to display the progress of this action.
    strMessage = 'Detecting pre-muscimol ripples...';
    dProgress = 0;
    hdlProgressBarFigure = waitbar(0, strMessage);

    % Display a timer.
    nDetectionTic = tic();
    updateMessage = @(~, ~) ...
        waitbar(dProgress, hdlProgressBarFigure, ...
                {strMessage, ['(Total time: ' ...
                        num2str(round(toc(nDetectionTic))) ' seconds)']});
    objTimer = timer( ...
        'ExecutionMode', 'fixedRate', ...
        'Period', 1, ...
        'TimerFcn', updateMessage);
    start(objTimer);

    % Set the current channels in each of the rat's conditions.
    nRippleWaveChannel = str2num(get(stctHandles.tbxRippleWave, 'String'));
    nSharpLowChannel = str2num(get(stctHandles.tbxSharpLow, 'String'));
    nSharpHighChannel = str2num(get(stctHandles.tbxSharpHigh, 'String'));

    cellChannels = {nRippleWaveChannel, nSharpLowChannel, nSharpHighChannel};

    objRatData.pre.setCurrentChannels(cellChannels{:});
    objRatData.musc.setCurrentChannels(cellChannels{:});
    objRatData.post.setCurrentChannels(cellChannels{:});

    % Detect the ripples and save them to the ripple file.
    stctRipples = [];
    strMessage = 'Detecting pre-muscimol ripples...';
    stctRipples.pre = stctHandles.objRatData.pre.detectRipples();

    strMessage = 'Detecting muscimol ripples...';
    dProgress = 0.2;
    stctRipples.musc = stctHandles.objRatData.musc.detectRipples();

    strMessage = 'Detecting post-muscimol ripples...';
    dProgress = 0.4;
    stctRipples.post = stctHandles.objRatData.post.detectRipples();

    strMessage = 'Saving ripples...';
    dProgress = 0.6;
    strRippleFile = fullfile(stctHandles.strAnalysisFolder, 'ripples.mat');
    save(strRippleFile, 'stctRipples');

    % For convenience, also store the start and end of the ripples as events. To
    % ensure that no data is overwritten, we access the event file using the
    % `matfile` function. There are performance penalties to pay for this, but
    % they should be minor in this case.
    strEventFile = fullfile(stctHandles.strAnalysisFolder, 'events.mat');
    objEventFile = matfile(strEventFile);

    strMessage = 'Saving ripple events...';
    dProgress = 0.8;
    objEventFile.pre.ripple = stctRipples.pre([1, 3]);
    objEventFile.musc.ripple = stctRipples.musc([1, 3]);
    objEventFile.post.ripple = stctRipples.post([1, 3]);

    dProgress = 1;
    strMessage = 'Finished!';

    % Stop and delete the timer.
    stop(objTimer);
    delete(objTimer);
end

function bSuccess = saveData(hObject, stctHandles)
    bSuccess = false;

    if isfield(stctHandles, 'strAnalysisFolder')
        % Ensure that the analysis folder exists.
        mkdirIfNonexistent(stctHandles.strAnalysisFolder);

        % Set the file name that we'll be saving to.
        strFile = fullfile(stctHandles.strAnalysisFolder, 'data.mat');

        % Collect the values that we want to save.
        stctRegions = stctHandles.stctRegions;
        nRippleWaveChannel = str2num(get(stctHandles.tbxRippleWave, 'String'));
        nSharpLowChannel = str2num(get(stctHandles.tbxSharpLow, 'String'));
        nSharpHighChannel = str2num(get(stctHandles.tbxSharpHigh, 'String'));
        dMaxFiringRate = str2num(get(stctHandles.tbxMaxFiring, 'String'));
        vInterneurons = str2num(get(stctHandles.tbxInterneuronList, 'String'));

        % Save the experiment set-up data.
        save(strFile, '-v7.3', 'stctRegions', 'nRippleWaveChannel', ...
             'nSharpLowChannel', 'nSharpHighChannel', 'dMaxFiringRate', ...
             'vInterneurons');

        % Success!! Tell the caller that the save didn't fail silently.
        bSuccess = true;
    else
        errordlg(['Please select a folder to store the parameters in (the ' ...
                  '"Analysis Folder").']);
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
    dMaxFiringRate = str2num(get(stctHandles.tbxMaxFiring, 'String'));
    vInterneurons = str2num(get(stctHandles.tbxInterneuronList, 'String'));

    % Compile a list of all sequences.
    cellSequences = {};
    cellConditions = {'pre', 'musc', 'post'};
    stctSequences = [];

    for i = 1 : length(cellConditions)
        % Retrieve the currend condition name.
        strCond = cellConditions{i};

        % Retrieve sequences from ripples, wheel runs, and when the animal is
        % moving through the maze.
        cellRippleSeqs = getRippleSequences(objRatData.(strCond));
        cellWheelSeqs = getWheelSequences(objRatData.(strCond));
        cellPlaceFieldSeqs = getPlaceFieldSequences(objRatData.(strCond));

        % Construct a structure that stores all of the collections of sequences
        % individually. We will save this.
        stctSequences.(strCond).ripple = cellRippleSeqs;
        stctSequences.(strCond).wheel = cellWheelSeqs;
        stctSequences.(strCond).placeField = cellPlaceFieldSeqs;

        % Construct a list of all of the sequences. This list will be used to
        % run further computations.
        cellSequences = [cellSequences; cellRippleSeqs; cellWheelSeqs; ...
                         cellPlaceFieldSeqs];
    end

    % Save the sequences in the analysis folder.
    save(fullfile(stctHandles.strAnalysisFolder, 'sequences.mat'), ...
         '-v7.3', 'stctSequences');

    % Compute the matrix of rho values and save it.
    mtxRho = computeRhoMatrix(cellSequences);
    save(fullfile(stctHandles.strAnalysisFolder, 'mtxRho.mat'), ...
         '-v7.3', 'mtxRho');

    % Compute the matrix of p-values.
    mtxP = computePValues(cellSequences, 1e4, ...
                          fullfile(stctHandles.strAnalysisFolder, 'sequences'));
    save(fullfile(stctHandles.strAnalysisFolder, 'mtxP.mat'), '-v7.3', 'mtxP');

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
function btnRun_Callback(hObject, ~, handles)
    % hObject    handle to btnRun (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    bSaved = saveData(hObject, handles);

    if bSaved
        runAnalysis(handles);
    end
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
function btnBrowseAnalysis_Callback(hObject, eventdata, stctHandles)
    % hObject      handle to btnBrowseAnalysis (see GCBO)
    % eventdata    reserved - to be defined in a future version of MATLAB
    % stctHandles  structure with handles and user data (see GUIDATA)
    strFolder = uigetdir(stctHandles.strDataFolder);

    if strFolder ~= 0
        setAnalysisFolder(stctHandles);
    end
end

function tbxAnalysisFolder_Callback(hObject, eventdata, stctHandles)
    % hObject      handle to tbxAnalysisFolder (see GCBO)
    % eventdata    reserved - to be defined in a future version of MATLAB
    % stctHandles  structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxAnalysisFolder as text
    %        str2double(get(hObject,'String')) returns contents of tbxAnalysisFolder as a double
    strCurrString = get(stctHandles.tbxAnalysisFolder, 'String');

    % Only update if the string hasn't changed.
    if ~strcmp(strCurrString, stctHandles.strAnalysisFolder)
        setAnalysisFolder(stctHandles);
    end
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

% --- Executes on button press in btnNeuroscope.
function btnNeuroscope_Callback(hObject, eventdata, handles)
    % hObject    handle to btnNeuroscope (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Ask the user which drug state to load data from.
    strCond = questdlg('Choose a condition...', ...
                       'pre-muscimol', 'muscimol', 'post-muscimol', ...
                       'str1');

    invokeNeuroscope(fullfile(handles.strDataFolder, strCond, '*.dat'));
end

% --- Executes on button press in btnDetectRipples.
function btnDetectRipples_Callback(hObject, eventdata, handles)
    % hObject    handle to btnDetectRipples (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    detectRipples(handles);
end

% --- Executes on button press in btnEditEvents.
function btnEditEvents_Callback(hObject, eventdata, handles)
    % hObject    handle to btnEditEvents (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

%
% USAGE:
%
%    mtxModifiedEvents = browseEvents(objNeuralData, mtxEvents)
%
% DESCRIPTION:
%
%    Browse (and modify) the supplied list of events
%
% ARGUMENTS:
%
%    objNeuralData
%
%       A `NeuralData` object on which `setCurrentChannels` has been called
%
%    mtxEvents
%
%       A 2-column matrix of event times in seconds. The first column should
%       contain starting times, and the second column should contain ending
%       times.
%
% RETURNS:
%
%    mtxModifiedEvents
%
%       A matrix of the same form as the input `mtxEvents` containing the list
%       of events once the GUI has been closed
%
function varargout = browseEvents(varargin)
    % Edit the above text to modify the response to help browseEvents

    % Last Modified by GUIDE v2.5 24-Oct-2013 14:36:25

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @browseEvents_OpeningFcn, ...
                       'gui_OutputFcn',  @browseEvents_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT

function updateGui(handles)
    % Retrive the event times and the time window to use when displaying the
    % event.
    vEvent = handles.mtxEvents(handles.nCurrentEvent, :);
    vTimeWindow = getTimeWindow(handles);

    % Plot the main ripple events over the LFP-triple.
    objLocalLfps = subseries(handles.objLfps, vTimeWindow(1), vTimeWindow(2));
    plot(handles.axEvent, objLocalLfps.Time, objLocalLfps.Data);
    PlotIntervals(vEvent, 'rectangles');

    % Set plot niceties.
    set(handles.axEvent, 'Layer', 'top');
    legend('Main', 'Low', 'High');
    % title(['LFPs and Ripple Event ' num2str(handles.nCurrentEvent)]);
    ylabel('');
    xlabel(handles.axEvent, 'Time (seconds)');
    xlim(vTimeWindow);
    set(handles.axEvent, 'Color', [1, 1, 1]);

    % % For each of the provided orderings, create plots of the associated spike
    % % trains and activity patterns.
    % for i = 1 : length(cellOrderings)
    %     % Retrieve the current ordering and intersect those cells with
    %     % the provided `neuronSet`.
    %     ordering = cellOrderings{i};
    %     orderingDesc = 'Spike Raster';
    %
    %     if isa(ordering, 'cell')
    %         orderingDesc = ordering{2};
    %         ordering = ordering{1};
    %     end
    %
    %     [ordering, ~, idxs] = intersect(ordering, neuronSet, 'stable');
    %
    %     % Plot the spike trains.
    %     vSubplotLocs = i * nPlotCols + (1 : nPlotCols);
    %     h(i + 1) = subplot(nPlotRows, nPlotCols, vSubplotLocs);
    %     plotSpikeTrains(spikeTrains, ripple([1, 3]), ordering, colors);
    %     title(orderingDesc);
    % end

    % % Set the window's title.
    % speed = this.Track.speed_MMsec(round(ripple(2) * sampleRate(this)));
    % set(gcf, 'name', ...
    %     ['----------Ripple ' num2str(nRipple) '----------' ...
    %      'Speed: ' num2str(speed) ' mm/sec----------' ...
    %      'Width: ' num2str((ripple(3) - ripple(1)) * 1000) ' ms----------']);

    % set(h(end), 'XTickLabelMode', 'auto')
    % xlabel(h(end), 'Time (seconds)');
end

function vWindow = getTimeWindow(handles)
    % Get the current event.
    vEvent = handles.mtxEvents(handles.nCurrentEvent, :);

    % Retrieve the user-set, padding-related information.
    strEventPadding = get(handles.tbxEventPadding, 'String');
    cellPaddingUnitOptions = get(handles.pbxEventPaddingUnits, 'String');
    strEventPaddingUnits = cellPaddingUnitOptions{ ...
        get(handles.pbxEventPaddingUnits, 'Value')};

    dEventPadding = str2double(strEventPadding);

    switch strEventPaddingUnits
      case '%'
        dEventDuration = diff(vEvent);
        dPadding = (dEventPadding / 100) * dEventDuration;
      case 'ms'
        dPadding = dEventPadding / 1000;
      case 's'
        dPadding = dEventPadding;
    end

    % Now that we have the padding, we can compute the time window.
    vWindow = vEvent + [-dPadding, dPadding];
end

function selectEvent(handles, nEvent)
    % Select the provided event, rounding to the appropriate range.
    nNumEvents = size(handles.mtxEvents, 1);
    handles.nCurrentEvent = max(1, min(nNumEvents, nEvent));

    % Make sure that we update the handles object, and then update the GUI.
    guidata(handles.figure1, handles)
    updateGui(handles);
end

function selectNextEvent(handles)
    % Make sure that we select an event in the range.
    nNumEvents = size(handles.mtxEvents, 1);
    nCurrentEvent = handles.nCurrentEvent;

    if nCurrentEvent == nNumEvents
        selectEvent(handles, 1);
    else
        selectEvent(handles, nCurrentEvent + 1);
    end
end

function selectPreviousEvent(handles)
    % Make sure that we select an event in the range.
    nNumEvents = size(handles.mtxEvents, 1);
    nCurrentEvent = handles.nCurrentEvent;

    if nCurrentEvent == 1
        selectEvent(handles, nNumEvents);
    else
        selectEvent(handles, nCurrentEvent - 1);
    end
end

% --- Executes just before browseEvents is made visible.
function browseEvents_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to browseEvents (see VARARGIN)

    % Process `varargin`. The first argument should be a `NeuralData` object;
    % the second should be a 2-column matrix of event times.
    handles.objNeuralData = varargin{1};
    handles.objLfps = getLfps(handles.objNeuralData);
    handles.objLfps.Data = bsxfun(@minus, handles.objLfps.Data, ...
                                  mean(handles.objLfps.Data, 1));
    handles.mtxEvents = varargin{2};

    % Initially, we want to display the first event.
    handles.nCurrentEvent = 1;

    % Update handles structure
    guidata(hObject, handles);

    % Update the display.
    updateGui(handles);

    % UIWAIT makes browseEvents wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = browseEvents_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.mtxEvents;

    % The figure can be deleted now
    delete(handles.figure1);
end

function tbxEventPadding_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxEventPadding (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxEventPadding as text
    %        str2double(get(hObject,'String')) returns contents of tbxEventPadding as a double
end

% --- Executes during object creation, after setting all properties.
function tbxEventPadding_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxEventPadding (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in pbxEventPaddingUnits.
function pbxEventPaddingUnits_Callback(hObject, eventdata, handles)
    % hObject    handle to pbxEventPaddingUnits (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns pbxEventPaddingUnits contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from pbxEventPaddingUnits
end

% --- Executes during object creation, after setting all properties.
function pbxEventPaddingUnits_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to pbxEventPaddingUnits (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in btnPreviousEvent.
function btnPreviousEvent_Callback(hObject, eventdata, handles)
    % hObject    handle to btnPreviousEvent (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selectPreviousEvent(handles);
end

% --- Executes on button press in btnNextEvent.
function btnNextEvent_Callback(hObject, eventdata, handles)
    % hObject    handle to btnNextEvent (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selectNextEvent(handles);
end

function tbxJumpToEvent_Callback(hObject, eventdata, handles)
    % hObject    handle to tbxJumpToEvent (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of tbxJumpToEvent as text
    %        str2double(get(hObject,'String')) returns contents of tbxJumpToEvent as a double

    % Retrieve the input.
    strInput = get(hObject, 'String');

    if all(isstrprop(strInput, 'digit'))
        selectEvent(handles, str2double(strInput));
    else
        errordlg('Please enter a valid event number');
    end
end

% --- Executes during object creation, after setting all properties.
function tbxJumpToEvent_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbxJumpToEvent (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in btnRemoveEvent.
function btnRemoveEvent_Callback(hObject, eventdata, handles)
    % hObject    handle to btnRemoveEvent (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in btnMoveLeftEdge.
function btnMoveLeftEdge_Callback(hObject, eventdata, handles)
    % hObject    handle to btnMoveLeftEdge (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in btnMoveRightEdge.
function btnMoveRightEdge_Callback(hObject, eventdata, handles)
    % hObject    handle to btnMoveRightEdge (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in btnSplitEvent.
function btnSplitEvent_Callback(hObject, eventdata, handles)
    % hObject    handle to btnSplitEvent (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

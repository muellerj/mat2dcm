function varargout = mdfimport(varargin)
% MDFIMPORT MDF File import tool and function
%   MDFIMPORT Launches the MDF import GUI tool or raises the existing tool
%   to the front. This tools lets you interactively import signals from an
%   MDF data file.
% 
%   MDFIMPORT(fileName) Imports signals from the specified MDF file to the
%   workspace using default options.
%
%   MDFIMPORT(fileName,importlocation,signalselection,timevectortype,ratedesignation,additionaltext)
%   Imports signals from the specified MDF file with specific options set.
% 
%   All parameters are optional except for the first, the file name, which
%   must be provided if MDFIMPORT is to be called as a function. See
%   <a href="mdfimportfunctionhelp.html">MDF import function help</a> for all possible input parameter options. 
%
%   When resampling, it also fills shortest and allsignals in 
%   the location.

% Resample feature added by Ralph Richter, bugfixed by Jonas Mueller.
%----------------------------------------------------------------------------
%   syntax:
%      mdfimport( ...
%         <measurement_file_name>, ...
%         {'workspace' | 'Auto MAT-File'}, ...
%           ~~~~~~~~~
%         {<cell_array of variable_names> | <signal_file_name>}, ...  % if empty, take all
%         {'actual' | 'ideal' | 'resample_x.x'}, ...
%           ~~~~~~
%         {'ratenumber' | 'ratestring'}, ...
%         <additional_text>,
%      );
%
%   x.x ... new sample rate
%
%----------------------------------------------------------------------------
%   example call:
%                                                new sampletime [s] --+
%                                                                     |
%                                                                     V
%      mdfimport('measure.dat','workspace','signallist.txt','resample_0.01');
%
%----------------------------------------------------------------------------
%
%      in addition to the signals, the variables
%           - shortest
%           - allsignals
%      will appear in the workspace.
%
%----------------------------------------------------------------------------

%   Tip:
%    % shorten all signals to the shortest vector
%    for i=1: length(allsignals)
%        oldsize=evalin('base', ['length(' allsignals{i} ')']);
%        assignin('base', allsignals{i}, ...
%            evalin('base', [allsignals{i} '(1:shortest)'])); %shorten all signals
%        disp([allsignals{i} ' shortened from ' int2str(oldsize) ' to ' int2str(shortest) ' (' int2str(shortest-oldsize) ').']);
%        clear oldsize;
%    end
%    clear i;
%
%----------------------------------------------------------------------------

%% --- history
%   $Source: //desgs0004/Projekte/250/Staende/CTCU_250/tools/matlab/utils/rcs/mdfimport.m $
%
%   $Id: mdfimport.m 1.9 2006/10/23 16:25:25 Ralph.Richter Exp $
%
%   $ProjectName: //desgs0004/Projekte/250/Staende/CTCU_250/tools.pj $
%
%   $ProjectRevision: 2.1 $
%
% ---------------------------------------------------------------------------
%
%   vx.x:   empty signals ignored for shortest calculation
%   vx.x:   missing end quote in generatecommand added
%   vx.x:   propeller added
%   vx.x:   resample added
%   vx.x:   naming inconsitency between workspace and mat export fixed
%   initial version (of internet)
%
%  $Log: mdfimport.m $
%  Revision 1.9  2006/10/23 16:25:25  Ralph.Richter
%  Ric: bug fix; write command line corrected and others.
%  
%


%% GUIDE generated code edited
% Intercept GUI function for command line operation
% If some parameters or second is not gcbo then coming from caommand line
if nargin % If arguments past in
    if nargin>1 % Could be from command line or GUI
        if isa(varargin{2},'double') & ~isempty(varargin{2}) %#ok allows for [] input
            % Its coming form the GUI, do nothing, gcbo
        else
            disp('   ');
            options=parseparameters(varargin);
            importdatawithoptions(options);
            return
        end
    else  % Just one argument, must be from the command line
        disp('   ');
        options=parseparameters(varargin);
        importdatawithoptions(options);
        return
    end
end
%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mdfimport_OpeningFcn, ...
    'gui_OutputFcn',  @mdfimport_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1}) %#ok
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


%%  Executes just before mdfimport is made visible.
function mdfimport_OpeningFcn(hObject, eventdata, handles, varargin) %#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mdfimport (see VARARGIN)

% Choose default command line output for mdfimport
handles.output = hObject;

% Set figure name and calculate uibackground color
set(handles.figure1,'Name','MDF File Import');
uibackgroundcolor=get(handles.selectallchannels,'background'); % Get color

% Initialize signal selection panel uicontrols
set(handles.Select_Signals_axes,'color',uibackgroundcolor); % Set axes color
set(handles.MDF_File_Text_Box,'String','No file specified'); % No MDF file selected
set(handles.Selection_File_Text_Box,'String','No file specified'); % No MDF file selected

set(handles.unselectedchannellistbox,'Max',2); % Allow Multi-select
set(handles.selectedchannellistbox,'Max',2); % Allow Multi-select

set(handles.unselectedchannellistbox,'String',[]); % Clear
set(handles.selectedchannellistbox,'String',[]); % Clear
set(handles.unselectedchannellistbox,'Value',[]); % Clear
set(handles.selectedchannellistbox,'Value',[]); % Clear

set(handles.removedevicenames_checkbox,'Value',1); % Initialize to remove names

% Signal import uicontrols
set(handles.Signal_Import_Options_axes,'color',uibackgroundcolor); % Set axes color

% Time vector generation uicontrols
set(handles.Time_Vector_axes,'color',uibackgroundcolor); % Set axes color
set(handles.timevectorchoice1,'Value',1); % Default to use actual times. Select this radion button..
set(handles.timevectorchoice2,'Value',0); % ...and deselect other radio button.
set(handles.timevectorchoice3,'Value',0); % ...and deselect other radio button.
set(handles.selectedrates_listbox,'String',[]); % Clear rates list box
set(handles.selectedrates_listbox,'Value',1); % Initialize selected value (must be>0 for single selection list boxes)

% Initalize data storage values
handles.pathName=pwd; % Set directory to look in to current directory
handles.fullFileName=''; % set to blank
handles.unselectedChannelList=[]; % Clear unselected channel data
handles.selectedChannelList=[]; % Clear selected channel data
handles.channelList=[]; % Clear total channel data
handles.removeDeviceNames=1; % Default is to remove device names
handles.requestedChannelList=''; % Initialize to none
handles.possibleRates=[];
handles.possibleRateIndices=[];
handles.MDFInfo=[];

%handles.timechannel=1; % Default location of time channel

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mdfimport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%%  Outputs from this function are returned to the command line.
function varargout = mdfimport_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%  Executes during object creation, after setting all properties.
function unselectedchannellistbox_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to unselectedchannellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  Executes on selection change in unselectedchannellistbox.
function unselectedchannellistbox_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to unselectedchannellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns unselectedchannellistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unselectedchannellistbox


%%  Executes during object creation, after setting all properties.
function selectedchannellistbox_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to selectedchannellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  Executes on selection change in selectedchannellistbox.
function selectedchannellistbox_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to selectedchannellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectedchannellistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectedchannellistbox


%%  Executes on button press in selectchannels.
function selectchannels_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to selectchannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selection list
selectedChannelIndices=get(handles.unselectedchannellistbox,'Value');

% Check if there are any   selected loaded and any have been unselected
if length(handles.unselectedChannelList)>0 & length(selectedChannelIndices)>0 %#ok

    % Update these channels by appending to existing list
    handles.selectedChannelList=[handles.selectedChannelList;...
        handles.unselectedChannelList(selectedChannelIndices,:)];

    % Sort these channels
    [dummy,sortIndices]=sort(handles.selectedChannelList(:,1)); % Get sorted names

    handles.selectedChannelList=handles.selectedChannelList(sortIndices,:);

    % Update channel list box for these channels
    updatedNames=processsignalname(handles.selectedChannelList,handles.removeDeviceNames,1);
    set(handles.selectedchannellistbox,'String',updatedNames);

    % Update channels and list box for other set
    handles.unselectedChannelList(selectedChannelIndices,:)=[];

    updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
    set(handles.unselectedchannellistbox,'Value',[]); % Update unselected list
    set(handles.unselectedchannellistbox,'String',updatedNames);

    % Updates rate list box and edit box
    handles=updaterates(handles);

    % Update handles structure
    guidata(hObject, handles);

end


%%  Executes on button press in unselectchannels.
function unselectchannels_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to unselectchannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get selection list
unselectedChannelIndices=get(handles.selectedchannellistbox,'Value');

% Check if there are any unselected loaded and any have been   selected
if length(handles.selectedChannelList)>0 & length(unselectedChannelIndices)>0 %#ok

    % Update these channels by appending to existing list
    handles.unselectedChannelList=[handles.unselectedChannelList;...
        handles.selectedChannelList(unselectedChannelIndices,:)];

    % Sort these channels
    [dummy,sortIndices]=sort(handles.unselectedChannelList(:,1)); % Get sorted names
    handles.unselectedChannelList=handles.unselectedChannelList(sortIndices,:);

    % Update channel list box for these channels
    updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
    set(handles.unselectedchannellistbox,'String',updatedNames);

    % Update channels and list box for other set
    handles.selectedChannelList(unselectedChannelIndices,:)=[];
    updatedNames=processsignalname(handles.selectedChannelList,handles.removeDeviceNames,1);
    set(handles.selectedchannellistbox,'Value',[]); % Clear selected list
    set(handles.selectedchannellistbox,'String',updatedNames);

    % Updates rate list box and edit box
    handles=updaterates(handles);

    % Update handles structure
    guidata(hObject, handles);
end


%%  Executes on button press in createselectionfile.
function createselectionfile_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to createselectionfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if length(handles.selectedChannelList)>0

    current=pwd; % Get and store current directory
    cd (handles.pathName); % Change to last directory looked at

    % Get name of file to same channel list in
    filterSpec='signal_selection1.txt';
    [selectionFileName,pathName]= uiputfile(filterSpec,'Specify TXT File to Save Signal Selections');
    cd(current);

    if isequal(selectionFileName,0)|isequal(pathName,0) %#ok
        % Ignore if dialog is closed without selecting file
    else
        % Set current directory back and store pathname
        if ~strcmp(selectionFileName(end-3:end),'.txt')
            selectionFileName=[selectionFileName '.txt'];
        end

        handles.pathName=pathName; % Set path name for later usage

        % Get list of selected channels
        selectedChannelList=handles.selectedChannelList;

        % Save as text file
        fid=fopen([pathName selectionFileName],'wt');
        for signal=1:size(selectedChannelList,1)
            fprintf(fid,'%s\n',removedevicenames(selectedChannelList{signal,1}));
        end
        fclose(fid);

        % Update handles structure
        guidata(hObject, handles);
    end

end


%%  Executes on button press in importdata.
function importdata_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to importdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedChannelList=handles.selectedChannelList; % X

if length(selectedChannelList)>0

    % Plot waitbar
    waitbarhandle=waitbar(0, 'Importing...');
    uibackgroundcolor=get(handles.selectallchannels,'background'); % Get color
    set(waitbarhandle,'color',uibackgroundcolor) % Set background color
    set(waitbarhandle,'Name','Import Signals'); %Set Window title
    drawnow; % Ensure title is drawn immediately

    %% Extract some options from GUI   
    options=getoptionsfromgui(handles);
    options.waitbarhandle=waitbarhandle;
    
    % Call generic import function
    importdatawithoptions(options);
    
    % Finish up waitbar display
    waitbar(1,waitbarhandle,'Finished');
    close(waitbarhandle);
end


%%  Executes during object creation, after setting all properties.
function mdffileedit_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to mdffileedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  mdffileedit_Callback
function mdffileedit_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to mdffileedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mdffileedit as text
%        str2double(get(hObject,'String')) returns contents of mdffileedit as a double


%%  Executes during object creation, after setting all properties.
function selectionfile_edit_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to selectionfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  selectionfile_edit_Callback
function selectionfile_edit_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to selectionfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selectionfile_edit as text
%        str2double(get(hObject,'String')) returns contents of selectionfile_edit as a double


%%  populate_GUI
function handles=populate_GUI(handles)

[MDFsummary, MDFInfo, counts, channelList]=mdfinfo(handles.fullFileName);
handles.MDFInfo=MDFInfo;

handles.selectedChannelList=[];
handles.unselectedChannelList=channelList;

% Remove Time channels
handles.unselectedChannelList(cell2mat(handles.unselectedChannelList(:,9))==1,:)=[]; %Remove

% % Remove data blocks containing Type 7 channels
% channelIndicesWithSignalType7=cell2mat(handles.unselectedChannelList(:,8))==7;
% channelsWithSignalType7=handles.unselectedChannelList(channelIndicesWithSignalType7,:);
% blocksWithSignalType7=unique(cell2mat(channelsWithSignalType7(:,4)));
% remove=ismember(cell2mat(handles.unselectedChannelList(:,4)),blocksWithSignalType7);
% handles.unselectedChannelList(remove,:)=[]; %Remove

% Remove blcoks with no records
channelIndicesWithNoRecords=cell2mat(handles.unselectedChannelList(:,6))==0;
handles.unselectedChannelList(channelIndicesWithNoRecords,:)=[]; %Remove

% Sort alphabetically
[dummy,sortIndices]=sort(handles.unselectedChannelList(:,1)); % Get sorted names
handles.unselectedChannelList=handles.unselectedChannelList(sortIndices,:);

% Set default list
handles.channelList=handles.unselectedChannelList;

% Initialize listboxes
updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
set(handles.unselectedchannellistbox,'String',updatedNames);

set(handles.selectedchannellistbox,'String','No signals selected');
set(handles.selectedchannellistbox,'Value',[]); % Update unselected list


%%  Executes on button press in removedevicenames_checkbox.
function removedevicenames_checkbox_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to removedevicenames_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of removedevicenames_checkbox

remove=get(handles.removedevicenames_checkbox,'Value'); % Get value of check ox
handles.removeDeviceNames=remove;

if length(handles.selectedChannelList)>0
    updatedNames=processsignalname(handles.selectedChannelList,handles.removeDeviceNames,1);
    set(handles.selectedchannellistbox,'String',updatedNames);
end

if length(handles.unselectedChannelList)>0
    updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
    set(handles.unselectedchannellistbox,'String',updatedNames);
end

% Update handles structure
guidata(hObject, handles);


%%  Executes on button press in selectallchannels.
function selectallchannels_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to selectallchannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get all channels
selectedChannelIndices=1:size(handles.unselectedChannelList,1);

% Check if any have been unselected
if length(handles.unselectedChannelList)>0 % Check if there are some unselected channels

    % Update selected channels
    handles.selectedChannelList=[handles.selectedChannelList;...
        handles.unselectedChannelList(selectedChannelIndices,:)];

    % Sort these channels
    [dummy,sortIndices]=sort(handles.selectedChannelList(:,1)); % Get sorted names
    handles.selectedChannelList=handles.selectedChannelList(sortIndices,:);

    % Update channel list box for these channels
    updatedNames=processsignalname(handles.selectedChannelList,handles.removeDeviceNames,1);
    set(handles.selectedchannellistbox,'String',updatedNames);

    % Update channels and list box for other set
    handles.unselectedChannelList(selectedChannelIndices,:)=[];

    set(handles.unselectedchannellistbox,'Value',[]); % Update unselected list
    set(handles.unselectedchannellistbox,'String',[]);

    % Updates rate list box and edit box
    handles=updaterates(handles);

    % Update handles structure
    guidata(hObject, handles);

end


%%  Executes on button press in unselectallchannels.
function unselectallchannels_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to unselectallchannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set all channels
unselectedChannelIndices=1:size(handles.selectedChannelList,1);

% Check if there are any unselected loaded and any have been   selected
if length(handles.selectedChannelList)>0 % Check if there are some selected channels

    % Update these channels and list box
    handles.unselectedChannelList=[handles.unselectedChannelList;...
        handles.selectedChannelList(unselectedChannelIndices,:)];

    % Sort
    [dummy,sortIndices]=sort(handles.unselectedChannelList(:,1)); % Get sorted names
    handles.unselectedChannelList=handles.unselectedChannelList(sortIndices,:);

    % Update channel list box for these channels
    updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
    set(handles.unselectedchannellistbox,'String',updatedNames);

    % Update channels and list box for other set
    handles.selectedChannelList(unselectedChannelIndices,:)=[];

    set(handles.selectedchannellistbox,'Value',[]); % Update selected list
    set(handles.selectedchannellistbox,'String',[]);

    % Updates rate list box and edit box
    handles=updaterates(handles);

    % Update handles structure
    guidata(hObject, handles);

end


%%  Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  edit3_Callback
function edit3_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

if length(handles.possibleRates>0)
    if get(handles.timevectorchoice2,'Value')==1
        inputValue=str2double(get(hObject,'String')); % Input value
        selectedItem=get(handles.selectedrates_listbox,'Value'); % Get item selected in list box
        handles.possibleRates(selectedItem)=inputValue; % Store new value

        % Update string in listbox
        rateStrings=get(handles.selectedrates_listbox,'String'); % Current strings
        currentString=rateStrings{selectedItem};
        index=strfind(currentString,'|'); % Find '|'
        newString=[currentString(1:index-1) '| ' num2str(inputValue)];%[ Old to | new]
        rateStrings{selectedItem}=newString;
        set(handles.selectedrates_listbox,'String',rateStrings);
    end
    % Update handles structure
    guidata(hObject, handles);
end


%%  File_Callback
function File_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  Load_MDF_File_Callback
function Load_MDF_File_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Select_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current=pwd;
cd (handles.pathName); % Change to current or last directory looked at
[fileName,pathName]= uigetfile({'*.dat';'*.mdf';'*.*'},'Select MDF File'); % Get file name
cd(current); %set cd back

if isequal(fileName,0)|isequal(pathName,0) %#ok
    % Ignore if dialog is closed without selecting file
else
    if strcmpi(fileName(end-3:end),'.dat') | strcmpi(fileName(end-3:end),'.mdf')  %#ok Look at file type
        handles.fileName=fileName; % Store file name
        handles.fullFileName=[pathName fileName]; % Set file name
        handles.pathName=pathName; % Set path name for later usage
        set(handles.MDF_File_Text_Box,'String',fileName); %Display MDF in text box

        handles=populate_GUI(handles); % Populate GUI (list box)
        set(handles.selectedrates_listbox,'String',[]); % Clear select rate list box

        if length(handles.requestedChannelList)>0
            % Apply signal selection
            handles=applyselectionfile(handles,handles.requestedChannelList);
            set(handles.selectedchannellistbox,'FontAngle','normal');
        end

    else
        errordlg('Not valid file type', 'Not valid file type');
    end
end

% Update handles structure
guidata(hObject, handles);


%%  Executes during object creation, after setting all properties.
function selectedrates_listbox_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to selectedrates_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  Executes on selection change in selectedrates_listbox.
function selectedrates_listbox_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to selectedrates_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectedrates_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectedrates_listbox

selectedItem=get(handles.selectedrates_listbox,'Value'); % Get item selected
selectedRate=handles.possibleRates(selectedItem); % Get rate selected
set(handles.edit3,'String',num2str(selectedRate)); % Update edit box with rate


%%  Load_Signal_Selection_List_Callback
function Load_Signal_Selection_List_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Load_Signal_Selection_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current=pwd;
cd (handles.pathName); % Change to current or last directory looked at
[fileName,pathName]= uigetfile('*.txt','Select Signal Selection File'); % Get file name
cd(current); % Set cd back

if isequal(fileName,0)|isequal(pathName,0) %#ok
    % Ignore if dialog is closed without selecting file
else
    switch fileName(end-3:end) % Look at file type

        case '.txt'
            %Display selection file in text box
            set(handles.Selection_File_Text_Box,'String',fileName); 

            % Load text file
            requestedChannelList=readtextfile([pathName fileName]);
            
            handles.pathName=pathName; % Set path name for later usage
            handles.requestedChannelList=requestedChannelList;
            
            if isempty(handles.fullFileName); % No MDF file loaded
                set(handles.selectedchannellistbox,'String',requestedChannelList);
                set(handles.selectedchannellistbox,'FontAngle','italic');

            else % File already loaded. Do selection
                handles=applyselectionfile(handles,requestedChannelList);
            end

        otherwise
            errordlg('Not valid file type', 'Not valid file type');
    end
end

% Update handles structure
guidata(hObject, handles);


%%  Help_Callback
function Help_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  Help_About_Callback
function Help_About_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Help_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

toolVersion=1.3;
str = sprintf(['MDF File Import Tool ' num2str(toolVersion,'%1.1f') '\n']);
msgbox(str,'About MDF File Import Tool','modal');


%%  Helpmdfimport_Callback
function Helpmdfimport_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Helpmdfimport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web(['file:' which('mdfimporttoolhelp.html')])


%%  Executes on button press in timevectorchoice1.
function timevectorchoice1_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to timevectorchoice1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timevectorchoice1

set(hObject,'Value',1); % Turn this radio button on
set(handles.timevectorchoice2,'Value',0); % Turn other radio button off
set(handles.timevectorchoice3,'Value',0); % Turn other radio button off
set(handles.ratedesignation_popup, 'Enable','on'); % enable rate designation
set(handles.additionaltext, 'Enable','on'); % enable additional text edit box

set(handles.selectedrates_listbox,'Enable','off'); % Disable selected rates list box
set(handles.edit3,'Enable','off'); % Disable new sample rate edit box
set(handles.saveascsv,'Enable','off'); % Disable auto save as csv checkbox

%%  Executes on button press in timevectorchoice2.
function timevectorchoice2_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to timevectorchoice2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timevectorchoice2

set(hObject,'Value',1); % Turn this radio button on
set(handles.timevectorchoice1,'Value',0); % Turn other radio button off
set(handles.timevectorchoice3,'Value',0); % Turn other radio button off
set(handles.ratedesignation_popup, 'Enable','on'); % enable rate designation
set(handles.additionaltext, 'Enable','on'); % enable additional text edit box

set(handles.selectedrates_listbox,'Enable','on'); % Enable selected rates list box
set(handles.edit3,'Enable','on'); % Enable new sample rate edit box
set(handles.saveascsv,'Enable','off'); % Disable auto save as csv checkbox

% Update selected rates edit box
if ~isempty(handles.possibleRates)
    selectedItem=get(handles.selectedrates_listbox,'Value'); % Get item selected
    selectedRate=handles.possibleRates(selectedItem); % Get rate selected
    set(handles.edit3,'String',num2str(selectedRate)); % Update edit box with rate
end


%%  Executes on button press in timevectorchoice3.
function timevectorchoice3_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to timevectorchoice3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timevectorchoice3

set(hObject,'Value',1); % Turn this radio button on
set(handles.timevectorchoice1,'Value',0); % Turn other radio button off
set(handles.timevectorchoice2,'Value',0); % Turn other radio button off
set(handles.ratedesignation_popup, 'Enable','off'); % disable rate designation
set(handles.additionaltext, 'Enable','off'); % disable additional text edit box

set(handles.selectedrates_listbox,'Enable','off'); % Enable selected rates list box
set(handles.edit3,'Enable','on'); % Enable new sample rate edit box
set(handles.saveascsv,'Enable','on'); % Enable auto save as csv checkbox


%%  Clear_MDF_File_Callback
function Clear_MDF_File_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Clear_MDF_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.MDF_File_Text_Box,'String','No file specified'); % No MDF file selected

% Initalize data storage values
handles.fileName=''; % set to blank
handles.fullFileName=''; % set to blank
handles.unselectedChannelList=[]; % Clear unselected channel data
handles.selectedChannelList=[]; % Clear selected channel data
handles.channelList=[]; % Clear total channel data

% Clear list boxes
set(handles.unselectedchannellistbox,'Value',[]);
set(handles.selectedchannellistbox,'Value',[]);
set(handles.unselectedchannellistbox,'String',[]);
set(handles.selectedchannellistbox,'String',[]);

% Updates rate list box and edit box
handles=updaterates(handles);

% Update handles structure
guidata(hObject, handles);


%%  Signal_Selection_File_Menu_Callback
function Signal_Selection_File_Menu_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Signal_Selection_File_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  Clear_Signal_Selection_File_Callback
function Clear_Signal_Selection_File_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Clear_Signal_Selection_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update GUI
set(handles.Selection_File_Text_Box,'String','No file specified'); % No MDF file selected
set(handles.selectedchannellistbox,'FontAngle','normal');
set(handles.selectedchannellistbox,'Value',[]); % Update selected list
set(handles.selectedchannellistbox,'String',[]);

% Update data
handles.requestedChannelList=[];
handles.selectedChannelList=[];

if length(handles.channelList)>0  % If some have been loaded

    % Reset data
    %handles.selectedChannelList=[];
    handles.unselectedChannelList=handles.channelList;

    % Sort these channels
    [dummy,sortIndices]=sort(handles.unselectedChannelList(:,1)); % Get sorted names
    handles.unselectedChannelList=handles.unselectedChannelList(sortIndices,:);

    % Update channel list box
    updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
    set(handles.unselectedchannellistbox,'String',updatedNames);

end

% Updates rate list box and edit box
handles=updaterates(handles);

% Update handles structure
guidata(hObject, handles);


%%  Executes during object creation, after setting all properties.
function ratedesignation_popup_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to ratedesignation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  Executes on selection change in ratedesignation_popup.
function ratedesignation_popup_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to ratedesignation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ratedesignation_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ratedesignation_popup


%%  Executes during object creation, after setting all properties.
function importlocation_popup_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to importlocation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  Executes on selection change in importlocation_popup.
function importlocation_popup_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to importlocation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns importlocation_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from importlocation_popup


%%  Executes during object creation, after setting all properties.
function additionaltext_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to additionaltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  additionaltext_Callback
function additionaltext_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to additionaltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of additionaltext as text
%        str2double(get(hObject,'String')) returns contents of additionaltext as a double

maxLengthStr=10; % Maximum number of allowed characters
str=get(hObject,'String'); % Get current string

if length(str)>=maxLengthStr % If too long
    set(hObject,'String',str(1:maxLengthStr)); % Get current string
end


%%  Code_Generation_Menu_Callback
function Code_Generation_Menu_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Code_Generation_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  Generate_Function_Call_1_Menu_Callback
function Generate_Function_Call_1_Menu_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Generate_Function_Call_1_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedChannelList=handles.selectedChannelList; % 

if length(selectedChannelList)>0
    
     % Get import options structure form uicontrols in GUI
    options=getoptionsfromgui(handles);
    
    % Generate mdfimport command string
    cmd=generatecommand(options);
    cmd=[cmd ' % Copy and paste command from here to use'];
    
    % Display command string
    disp(cmd);
    if strcmpi(options.timeVectorChoice,'ideal')
        disp('% Any modified sample rates are ignored, as this feature is not supported when called at command line.');
    end
else
    % Display command string
    disp('No command can be generated as no signals have been selected.');
end


%%  Generate_Function_Call_2_Menu_Callback
function Generate_Function_Call_2_Menu_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Generate_Function_Call_2_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedChannelList=handles.selectedChannelList; % 

if length(selectedChannelList)>0
    
     % Get import options structure form uicontrols in GUI
    options=getoptionsfromgui(handles);
    options.selectedChannelList='enter_signal_selection_file_here.txt'; % Ovewrite selected signals
    
    % Generate mdfimport command string
    cmd=generatecommand(options);
    cmd=[cmd ' % Copy and paste command from here to use.'];

    % Display command string
    disp(cmd);
    if strcmpi(options.timeVectorChoice,'ideal')
        disp('% Any modified sample rates are ignored, as this feature is not supported when called in command line.');
    end
else
    % Display command string
    disp('No command can be generated as no signals have been selected.');
end


%%  removedevicenames
function varName=removedevicenames(signalName)
% Removes device names from the end of the signal name strings
% Outputs column vector

% Logical saying is input is string as opposed to cell array
stringinput=0; 
if ischar(signalName) % If just one string input
    signalName={signalName};
    stringinput=1;
end

% Find location of '\' characters
for signal =1:length(signalName)
    indices{signal,1}=strfind(signalName{signal},'\');
end  
%indices=strfind(signalName,'\'); % Find instances of '\' later version handles cell arrays

for signal=1:length(signalName) % For each signal
    
    if isempty(indices{signal}); % If not '\' characters in name
        varName(signal,1)=signalName(signal); % ...just copy, its fine
    else % If there are '\' characters in name
        if signalName{signal}(1)=='\' % If first character is '\'
            error('Bad signal name, begins with ''\'''); % Error out
        end
        varName{signal,1}=signalName{signal}(1:indices{signal}(1)-1); % Extract up to first '\'
    end
end

if stringinput
    varName=varName{1}; % Remove scell and return a string
end

% varName=signalName;
% varName = strrep(varName,'\ETKC:1','');
% varName = strrep(varName,'\device1','');
% varName = strrep(varName,'\ETK-Testdevice:1','');
% varName = strrep(varName,'\ETK-Testdevice:1/x','');
% varName = strrep(varName,'\ETK test device:1','');
% varName = strrep(varName,'\VADI-Testdevice:1','');
% varName = strrep(varName,'\CCP:1','');
% varName = strrep(varName,'\CCP:2','');
% %varName = strrep(varName,'\','');
% varName = strrep(varName,'\AD-Scan:1','');
% varName = strrep(varName,'\Thermo-Scan:1','');
% %varName = strrep(varName,'2ndPress','SecondPress');


%%  mdfload
function [samples signals]=mdfload(fileInfo,varargin)
% MDFLOAD Reads an MDF file and returns the signals
% into the workspace creating individual variables or each channel.
% The time channel is renamed 'time' if it is not so named

%storageType='';

% Inspect fileInfo variable
switch class(fileInfo)
    case 'char' % If its a filename...
        [MDFsummary MDFInfo counts]=mdfinfo(fileInfo); % ...load it
    case  'struct' % If its a structure...
        MDFInfo=fileInfo; % ...just copy it
end

% Default settings
blockDesignation='ratenumber';
newSampleRate=0.0;

% Set variables based on input parameters
switch nargin
    
    case 1 % Select all signals for all data blocks
        % Set to all blocks
        selectedDatablocks=1:double(MDFInfo.HDBlock.numberOfDataGroups); % Linear array

    case 2 % Select all signals from specified data block
        % Set specified block
        selectedDatablocks=varargin{1};
        
    case 3 % Select specified signals from specified data block
        selectedChannels= varargin{2}; % Set specified channels
        selectedDatablocks=varargin{1}; % Set specified block 
        
    case 4 % Select specified signals from specified data block
        blockDesignation= varargin{3}; % 'ratenumber' or 'ratestring'
        selectedChannels= varargin{2}; % Set specified channels
        selectedDatablocks=varargin{1}; % Set specified block 
        
    case 5 % Import location
        ws= varargin{4}; % import location
        blockDesignation= varargin{3}; % 'ratenumber' or 'ratestring'
        selectedChannels= varargin{2}; % Set specified channels
        selectedDatablocks=varargin{1}; % Set specified block 
    
    case 6 %  Additional text
        additionalText=varargin{5}; % Additional text
        ws= varargin{4}; % import location
        blockDesignation= varargin{3}; % 'ratenumber' or 'ratestring'
        selectedChannels= varargin{2}; % Set specified channels
        selectedDatablocks=varargin{1}; % Set specified block 
        
    case 7 %  new sample rate
        newSampleRate=varargin{6}; %  new sample rate
        additionalText=varargin{5}; % Additional text
        ws= varargin{4}; % import location
        blockDesignation= varargin{3}; % 'ratenumber' or 'ratestring'
        selectedChannels= varargin{2}; % Set specified channels
        selectedDatablocks=varargin{1}; % Set specified block 
        
    otherwise % Error
        error('Wrong number of parameters');
end

numValidBlocks   = 0; % Initialize block count
totalNumChannels = 0; % Initialize channel count
shortestSignal   = 0;
signals          = '';
lasttimecount    = 0; % Initialize time sample count
signalNames      =[];

for dataBlock=selectedDatablocks % For each (either one or all)
    
    % Find time channel
    timeChannel=findtimechannel(MDFInfo.DGBlock(dataBlock).CGBlock(1).CNBlock);

    numberOfRecords= MDFInfo.DGBlock(dataBlock).CGBlock(1).numberOfRecords; % Number of records in this block
    rateComment=MDFInfo.DGBlock(dataBlock).CGBlock.TXBlock.comment; % Comment rate for this block
    if numberOfRecords>=1 % As long as there is at least one record...
        
        numValidBlocks=numValidBlocks+1; % Increment block count
        
        % Load data
        if ~exist('selectedChannels','var') % If signals are not specified...
            [data signalNames]=mdfread(MDFInfo,dataBlock); % Load all signals

        else % If signals are specified...
            [data signalNames]=mdfread(MDFInfo,dataBlock,selectedChannels); % Load specified signals
        end
        lasttimecount = length(data{timeChannel});
        
        if newSampleRate == 0.0 % if is not set, use original data
            % Assign columns of data into workspace as seperate variables
            for k=1: length(signalNames) % for each signal of this block

                if selectedChannels(k)==timeChannel;
                    signalNames{k}='time'; % Overide to time string if time channel
                else
                    signalNames{k}=removedevicenames(signalNames{k}); % Remove device names
                end

                % Construct variable name
                if ~exist('additionalText','var') % If not defined, set to empty string
                    additionalText='';
                end
                % Determine if numbers or rate strings are to be used to
                % designatr the different rate variables
                switch blockDesignation
                    case 'ratenumber'
                        varEnding=int2str(dataBlock);
                        varName= [signalNames{k} '_' varEnding additionalText];
                    case 'ratestring'
                        varEnding=rateComment;
                        varName=[signalNames{k} '_' varEnding additionalText];
                    case 'empty'
                        varEnding=rateComment;
                        varName=signalNames{k};
                    otherwise
                        error('Block designator not known');
                end
                varName=mygenvarname(varName); % Make legal if you can

                % Test if legal, then assign to variable
                if ~exist('ws','var')
                    ws='base';
                end
                if isvarname(varName)  % If legal
                    assignin(ws, varName, data{k}); % Save it in choose location
                else % If not
                    warning(['Ignoring modified signal name ''' varName '''. Cannot be turned into a variable name.']);
                end

                totalNumChannels=totalNumChannels+1;
            end %end for signalNames

            % Display what was generated in command window
            tempvar=mygenvarname(['x_' varEnding additionalText]);  % Calculate var name
            if exist('selectedChannels','var') % If channel selction have been specified (if a called fom mdfimport tool)
                if ismember(timeChannel,selectedChannels) % If one of the channels selected is time
                    disp(['Created ' int2str(length(signalNames)-1) ' signal variable(s) appended with ''' tempvar(2:end) ''' for ''' rateComment ''' rate']);
                    disp(['... and 1 actual time vector ''' mygenvarname(['time_' varEnding additionalText]) '''']);
                else
                    disp(['Created ' int2str(length(signalNames)) ' signal variable(s) appended with ''' tempvar(2:end) ''' for ''' rateComment ''' rate']);
                end
            else
                disp(['Created ' int2str(length(signalNames)-1) ' signal variable(s) appended with ''' tempvar(2:end) ''' for ''' rateComment ''' rate']);
                disp(['... and 1 actual time vector ''' mygenvarname(['time_' varEnding additionalText]) '''']);
            end
        else % resample
            tt = data{timeChannel};
            lasttimecount = floor(tt(length(tt))/newSampleRate);
            if false %debug
                disp(' ');
                disp(['time: ' num2str(tt(length(tt)), '%0.5f') ', number of samples: ' num2str(lasttimecount, '%.0f')]);
            end
            commontime = (1:1:lasttimecount)' * newSampleRate;
            
            for k=1: length(signalNames) % for each signal
                if selectedChannels(k)==timeChannel;
                    signalNames{k}='time'; % Overide to time string if time channel
                else
                    signalNames{k}=removedevicenames(signalNames{k}); % Remove device names
                end

                % Construct variable name
                if ~exist('additionalText','var') % If not defined, set to empty string
                    additionalText='';
                end
                switch blockDesignation
                    case 'ratenumber'
                        varEnding=int2str(dataBlock);
                        varName= [signalNames{k} '_' varEnding additionalText];
                    case 'ratestring'
                        varEnding=rateComment;
                        varName=[signalNames{k} '_' varEnding additionalText];
                    case 'empty'
                        varName=signalNames{k};
                    otherwise
                        error('Block designator not known');
                end

                %varName = ['res_' varName];
                varName=mygenvarname(varName); % Make legal if you can
                signalNames{k}=varName;

                % Test if legal, then assign to variable
                if ~exist('ws','var'), ws='base'; end
                if isvarname(varName)  % If legal
                    if selectedChannels(k) ~= timeChannel;
                        try 
                          interp1(data{timeChannel}, data{k}, commontime, 'nearest');
                        catch exception
                          % Remove zero entries
                          zidx = (data{timeChannel} == 0);
                          data{timeChannel}(zidx) = [];
                          data{k}(zidx) = [];
                          if length(data{timeChannel}) < 2
                            data{timeChannel} = [0 1];
                            data{k} = zeros(2, 1);
                          end
                        end
                        dataReSampled=interp1(data{timeChannel}, data{k}, commontime, 'nearest');
                        assignin(ws, varName, dataReSampled); % Save it in choosen location
                    else
                        if length(commontime) > 0
                          assignin(ws, varName, commontime); % Save it in choosen location
                        end
                    end
                    if k ~= timeChannel
                        if false %debug
                            disp([' - ' signalNames{k}]); % list the process signal name
                        end
                    end
                    totalNumChannels=totalNumChannels+1;
                    prop = '/-\|/-\|'; 
                    fprintf('\b\b%c ', prop(1+mod(totalNumChannels,length(prop))));
                else % If not legal
                    warning(['Ignoring modified signal name ''' varName '''. Cannot be turned into a variable name.']);
                end

            end %end for signalNames
            
        end % resample
    end
end
samples = lasttimecount;

for k=1: timeChannel-1, signals{k}=signalNames{k}; end;
for k=timeChannel+1: length(signalNames), signals{k-1}=signalNames{k}; end;
signals=signals';

%%  mdfinfo
function [MDFsummary, MDFstructure, counts, channelList]=mdfinfo(fileName)
% MDFINFO Return information about an MDF (Measure Data Format) file
%
%   MDFSUMMARY = mdfinfo(FILENAME) returns an array of structures, one for
%   each data group, containing key information about all channels in each
%   group. FILENAME is a string that specifies the name of the MDF file.
%
%   [..., MDFSTRUCTURE] = mdfinfo(FILENAME) returns a structure containing
%   all MDF file information matching the structure of the file. This data structure
%   match closely the structure of the data file.
%
%   [..., COUNTS] = mdfinfo(FILENAME) contains the total
%   number of channel groups and channels.

% Open file
fid=fopen(fileName,'r');

if fid==-1
    error([fileName ' not found'])
end
% Input information about the format of the individual blocks
formats=blockformats;
channelGroup=1;

% Insert fileName into field or output data structure
MDFstructure.fileName=fileName;

%%% Read header block (HDBlock) information

% Set file poniter to start of HDBlock
offset=64;

% Read Header block info into structure
MDFstructure.HDBlock=mdfblockread(formats.HDFormat,fid,offset,1);

%%% Read Data Group blocks (DGBlock) information

% Get pointer to first Data Group block
offset=MDFstructure.HDBlock.pointerToFirstDGBlock;
for dataGroup=1:double(MDFstructure.HDBlock.numberOfDataGroups) % Work for older versions

    % Read data Data Group block info into structure
    DGBlockTemp=mdfblockread(formats.DGFormat,fid,offset,1);

    % Get pointer to next Data Group block
    offset=DGBlockTemp.pointerToNextCGBlock;

    %%% Read Channel Group block (CGBlock) information - offset set already

    % Read data Channel Group block info into structure
    CGBlockTemp=mdfblockread(formats.CGFormat,fid,offset,1);

    offset=CGBlockTemp.pointerToChannelGroupCommentText;

    % Read data Text block info into structure
    TXBlockTemp=mdfblockread(formats.TXFormat,fid,offset,1);

    % Read data Text block comment into structure after knowing length
    current=ftell(fid);
    TXBlockTemp2=mdfblockread(formatstxtext(TXBlockTemp.blockSize),fid,current,1);

    % Convert blockIdentifier and comment string data from uint8 to char
    TXBlockTemp.blockIdentifier=truncintstochars(TXBlockTemp.blockIdentifier);
    TXBlockTemp.comment=truncintstochars(TXBlockTemp2.comment); % accessing TXBlockTemp2

    % Copy temporary Text block info into main MDFstructure
    CGBlockTemp.TXBlock=TXBlockTemp;

    % Get pointer to next first Channel block
    offset=CGBlockTemp.pointerToFirstCNBlock;

    % For each Channel
    for channel=1:double(CGBlockTemp.numberOfChannels)

        %%% Read Channel block (CNBlock) information - offset set already

        % Read data Channel block info into structure

        CNBlockTemp=mdfblockread(formats.CNFormat,fid,offset,1);

        % Convert blockIdentifier, signalName, and signalDescription
        % string data from uint8 to char
        CNBlockTemp.signalName=truncintstochars(CNBlockTemp.signalName);
        CNBlockTemp.signalDescription=truncintstochars(CNBlockTemp.signalDescription);

        %%% Read Channel text block (TXBlock)

        offset=CNBlockTemp.pointerToTXBlock1;
        if double(offset)==0
            TXBlockTemp=struct('blockIdentifier','NULL','blocksize', 0);
            CNBlockTemp.longSignalName='';
        else
            % Read data Text block info into structure
            TXBlockTemp=mdfblockread(formats.TXFormat,fid,offset,1);

            if TXBlockTemp.blockSize>0 % If non-zero (check again)
                % Read data Text block comment into structure after knowing length
                current=ftell(fid);
                TXBlockTemp2=mdfblockread(formatstxtext(TXBlockTemp.blockSize),fid,current,1);

                % Convert blockIdentifier and comment string data from uint8 to char
                TXBlockTemp.blockIdentifier=truncintstochars(TXBlockTemp.blockIdentifier);
                TXBlockTemp.comment=truncintstochars(TXBlockTemp2.comment); % accessing TXBlockTemp2
                CNBlockTemp.longSignalName=TXBlockTemp.comment;
            else % If block size is zero (sometimes it is)
                TXBlockTemp=struct('blockIdentifier','NULL','blocksize', 0);
                CNBlockTemp.longSignalName='';
            end

        end
        % Copy temporary Text block info into main MDFstructure
        CNBlockTemp.TXBlock=TXBlockTemp;
        % NOTE: This could be removed later, only required for long name which
        % gets stored in structure seperately

        if CNBlockTemp.signalDataType==7 % If text only
            offset=CNBlockTemp.pointerToConversionFormula;
            CCBlockTemp=mdfblockread(formats.CCFormat,fid,offset,1);
            %% to support strings?
        else

            %%% Read Channel Conversion block (CCBlock)

            % Get pointer to Channel convertion block
            offset=CNBlockTemp.pointerToConversionFormula;

            if offset==0; % If no conversion formula, set to 1:1
                CCBlockTemp.conversionFormulaIdentifier=65535;
            else % Otherwise get conversion formula, parameters and physical units
                % Read data Channel Conversion block info into structure
                CCBlockTemp=mdfblockread(formats.CCFormat,fid,offset,1);

                % Extract Channel Conversion formula based on conversion
                % type(conversionFormulaIdentifier)

                switch CCBlockTemp.conversionFormulaIdentifier

                    case 0 % Parameteric, Linear: Physical =Integer*P2 + P1

                        % Get current file position
                        currentPosition=ftell(fid);

                        % Read data Channel Conversion parameters info into structure
                        CCBlockTemp2=mdfblockread(formats.CCFormatFormula0,fid,currentPosition,1);

                        % Extract parameters P1 and P2
                        CCBlockTemp.P1=CCBlockTemp2.P1;
                        CCBlockTemp.P2=CCBlockTemp2.P2;

                    case 1 % Table look up with interpolation

                        % Get number of paramters sets
                        num=CCBlockTemp.numberOfValuePairs;

                        % Get current file position
                        currentPosition=ftell(fid);

                        % Read data Channel Conversion parameters info into structure
                        CCBlockTemp2=mdfblockread(formats.CCFormatFormula1,fid,currentPosition,num);

                        % Extract parameters int value and text equivalent
                        % arrays
                        CCBlockTemp.int=CCBlockTemp2.int;
                        CCBlockTemp.phys=CCBlockTemp2.phys;

                    case 2 % table look up

                        % Get number of paramters sets
                        num=CCBlockTemp.numberOfValuePairs;

                        % Get current file position
                        currentPosition=ftell(fid);

                        % Read data Channel Conversion parameters info into structure
                        CCBlockTemp2=mdfblockread(formats.CCFormatFormula1,fid,currentPosition,num);

                        % Extract parameters int value and text equivalent
                        % arrays
                        CCBlockTemp.int=CCBlockTemp2.int;
                        CCBlockTemp.phys=CCBlockTemp2.phys;

                    case 6 % Polynomial

                        %  Get current file position
                        currentPosition=ftell(fid);

                        % Read data Channel Conversion parameters info into structure
                        CCBlockTemp2=mdfblockread(formats.CCFormatFormula6,fid,currentPosition,1);

                        % Extract parameters P1 to P6
                        CCBlockTemp.P1=CCBlockTemp2.P1;
                        CCBlockTemp.P2=CCBlockTemp2.P2;
                        CCBlockTemp.P3=CCBlockTemp2.P3;
                        CCBlockTemp.P4=CCBlockTemp2.P4;
                        CCBlockTemp.P5=CCBlockTemp2.P5;
                        CCBlockTemp.P6=CCBlockTemp2.P6;

                    case 10 % Text formula

                        %  Get current file position
                        currentPosition=ftell(fid);
                        CCBlockTemp2=mdfblockread(formats.CCFormatFormula10,fid,currentPosition,1);
                        CCBlockTemp.textFormula=truncintstochars(CCBlockTemp2.textFormula);
                        
                    case {65535, 11,12} % Physical = integer (implementation) or ASAM-MCD2 text table

                    otherwise

                        % Give warning that conversion formula is not being
                        % made
                        warning(['Conversion Formula type (conversionFormulaIdentifier='...
                            int2str(CCBlockTemp.conversionFormulaIdentifier)...
                            ')not supported.']);
                end
                
                % Convert physicalUnit string data from uint8 to char
                CCBlockTemp.physicalUnit=truncintstochars(CCBlockTemp.physicalUnit);
            end
        end


        % Copy temporary Channel Conversion block info into temporary Channel
        % block info
        CNBlockTemp.CCBlock=CCBlockTemp;

        % Get pointer to next Channel block ready for next loop
        offset=CNBlockTemp.pointerToNextCNBlock;

        % Copy temporary Channel block info into temporary Channel
        % Group info
        CGBlockTemp.CNBlock(channel,1)=CNBlockTemp;
    end
    
    % Sort channel list before copying in because sometimes the first
    % channel is not listed first in the block
    pos=zeros(length(CGBlockTemp.CNBlock),1);
    for ch = 1: length(CGBlockTemp.CNBlock)
        pos(ch)=CGBlockTemp.CNBlock(ch).numberOfTheFirstBits; % Get start bits
    end
    
    [dummy,idx]=sort(pos); % Sort positions to getindices
    clear CNBlockTemp2
    for ch = 1: length(CGBlockTemp.CNBlock)
        CNBlockTemp2(ch,1)= CGBlockTemp.CNBlock(idx(ch)); % Sort blocks
    end
    
    % Copy sorted blocks back
    CGBlockTemp.CNBlock=CNBlockTemp2;
    
    % Copy temporary Channel Group block info into temporary Channel
    % Group array in temporary Data Group info
    DGBlockTemp.CGBlock(channelGroup,1)=CGBlockTemp;


    % Get pointer to next Data Group block ready for next loop
    offset=DGBlockTemp.pointerToNextDGBlock;

    % Copy temporary Data Group block info into Data Group array
    % in main MDFstructure ready for returning from the function
    MDFstructure.DGBlock(dataGroup,1)=DGBlockTemp;
end

% CLose the file
fclose(fid);

% Calculate the total number of Channels

totalChannels=0;
for k= 1: double(MDFstructure.HDBlock.numberOfDataGroups)
    totalChannels=totalChannels+double(MDFstructure.DGBlock(k).CGBlock.numberOfChannels);
end

% Return channel coutn information in counts variable
counts.numberOfDataGroups=MDFstructure.HDBlock.numberOfDataGroups;
counts.totalChannels=totalChannels;

% Put summary of data groups into MDFsummary structure
[MDFsummary, channelList]=mdfchannelgroupinfo(MDFstructure);


%%  blockformats
function formats = blockformats
% This function returns all the predefined formats for the different blocks
% in the MDF file as specified in "Format Specification MDF Format Version 3.0"
% doucment version 2.0, 14/11/2002

%%  Data Type Definitions
LINK=  'int32';
CHAR=  'uint8';
REAL=  'double';
BOOL=  'int16';
UINT8= 'uint8';
UINT16='uint16';
INT32= 'int32';
UINT32='uint32';
%BYTE=  'uint8';

formats.HDFormat={...
    UINT8  [1 4]  'ignore';...
    INT32  [1 1]  'pointerToFirstDGBlock';  ...
    UINT8  [1 8]   'ignore';  ...
    UINT16 [1 1]  'numberOfDataGroups'};

formats.TXFormat={...
    UINT8  [1 2]  'blockIdentifier';...
    UINT16 [1 1]  'blockSize'};

% Can use anonymous fuction for R14 onwards instead of subfuntion
% formats.TXtext= @(blockSize)( [{'uint8'}  {[1 double(blockSize)]}  {'comment'}]);


formats.DGFormat={...
    UINT8  [1 4]  'ignore';...
    LINK   [1 1]  'pointerToNextDGBlock';  ...
    LINK   [1 1]  'pointerToNextCGBlock';  ...
    UINT8  [1 4]  'ignore'; ...
    LINK   [1 1]  'pointerToDataRecords'; ...
    UINT16  [1 1] 'numberOfChannelGroups';...
    UINT16  [1 1] 'numberOfRecordIDs'}; % Ignore rest

formats.CGFormat={...
    UINT8  [1 8]  'ignore';...
    LINK   [1 1]  'pointerToFirstCNBlock';  ...
    LINK   [1 1]  'pointerToChannelGroupCommentText'; ...
    UINT16 [1 1]  'recordID'; ...
    UINT16 [1 1]  'numberOfChannels'; ...
    UINT16 [1 1]  'dataRecordSize'; ...
    UINT32 [1 1]  'numberOfRecords'};

% last one missing

formats.CNFormat={...
    UINT8  [1 4]   'ignore';...
    LINK   [1 1]   'pointerToNextCNBlock';  ...
    LINK   [1 1]   'pointerToConversionFormula';  ...
    UINT8  [1 12]   'ignore'; ...
    UINT16 [1 1]   'channelType'; ...
    CHAR   [1 32]  'signalName'; ...
    CHAR   [1 128] 'signalDescription'; ...

    UINT16 [1 1]   'numberOfTheFirstBits'; ...
    UINT16 [1 1]   'numberOfBits'; ...
    UINT16 [1 1]   'signalDataType'; ...
    BOOL   [1 1]   'valueRangeKnown'; ...
    REAL   [1 1]   'valueRangeMinimum'; ...
    REAL   [1 1]   'valueRangeMaximum'; ...
    REAL   [1 1]   'rateVariableSampled';...
    LINK   [1 1]   'pointerToTXBlock1'};


formats.CCFormat={...
    UINT8  [1 22]  'ignore';...
    CHAR   [1 20]  'physicalUnit'; ...
    UINT16 [1 1]   'conversionFormulaIdentifier'; ...
    UINT16 [1 1]   'numberOfValuePairs'};

formats.CCFormatFormula0={...
    REAL   [1 1] 'P1'; ...
    REAL   [1 1] 'P2'};

formats.CCFormatFormula1={... % Tablular or Tabular with interp
    REAL   [1 1] 'int'; ...
    REAL   [1 1] 'phys'};

formats.CCFormatFormula10={... % Text formula
    CHAR   [1 256] 'textFormula'};

formats.CCFormatFormula11={... % ASAM-MCD2 text table
    REAL  [1 1] 'int'; ...
    CHAR  [1 32] 'text'};

formats.CCFormatFormula6={...
    REAL   [1 1] 'P1'; ... % polynomial
    REAL   [1 1] 'P2'; ...
    REAL   [1 1] 'P3'; ...
    REAL   [1 1] 'P4'; ...
    REAL   [1 1] 'P5'; ...
    REAL   [1 1] 'P6'};


%%  mdfchannelgroupinfo
function [summary, channelList]=mdfchannelgroupinfo(MDFStructure)
% Returns summary information of an MDF file (summary) taken from the
% MDFstrusture data structure and a cell array containing many
% important fields of informtation for each channel in the file
% (channelList)

numberOfDataGroups=double(MDFStructure.HDBlock.numberOfDataGroups);
channelGroup=1;
fieldNames=fieldnames(MDFStructure.DGBlock(1).CGBlock(channelGroup).CNBlock);
startChannel=1;

for dataBlock = 1: numberOfDataGroups

    numberOfChannels=double(MDFStructure.DGBlock(dataBlock).CGBlock(channelGroup).numberOfChannels);
    numberOfRecords=double(MDFStructure.DGBlock(dataBlock).CGBlock(channelGroup).numberOfRecords);
    endChannel=startChannel+numberOfChannels-1;

    % Make summary
    summary(dataBlock,1).numberOfChannels=numberOfChannels;
    summary(dataBlock,1).numberOfRecords=numberOfRecords;
    summary(dataBlock,1).rateVariableSampled=MDFStructure.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(1).rateVariableSampled;
    channelCells=[fieldNames struct2cell(MDFStructure.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock)];

    % Signal Name and descriptions
    signalNames=channelCells(4,:)'; % Signal names
    longSignalNames=channelCells(14,:)'; % Long names
    useNames=cell(size(signalNames)); % Pre allocate

    for signal=1:length(signalNames)
        if isempty(longSignalNames{signal}) % If no long name, use signal name
            useNames(signal)=signalNames(signal);
        else
            useNames(signal)=longSignalNames(signal); % Use Long name
        end
    end
    summary(dataBlock,1).signalNamesandDescriptions(:,1)=useNames;
    summary(dataBlock,1).signalNamesandDescriptions(:,2)=channelCells(5,:)';

    % Other
    summary(dataBlock,1).channelCells=channelCells;

    % Make channel List
    channelCells2=struct2cell(MDFStructure.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock);

    % Signal Names
    signalNames=channelCells2(4,:)'; % Signal names
    longSignalNames=channelCells2(14,:)'; % Long names
    useNames=cell(size(signalNames)); % Pre allocate

    for signal=1:length(signalNames)
        if length(signalNames{signal})>length(longSignalNames{signal}) % If signal name longer use it
            useNames(signal)=signalNames(signal);
        else
            useNames(signal)=longSignalNames(signal); % Use Long name
        end
    end

    channelList(startChannel:endChannel,1)= useNames; % Names

    channelList(startChannel:endChannel,2)= channelCells2(5,:)'; % Descriptons
    channelList(startChannel:endChannel,3)= num2cell((1:numberOfChannels)');
    channelList(startChannel:endChannel,4)={dataBlock};
    channelList(startChannel:endChannel,5)={MDFStructure.DGBlock(dataBlock).CGBlock.CNBlock(1).rateVariableSampled};
    channelList(startChannel:endChannel,6)={numberOfRecords};
    channelList(startChannel:endChannel,7)=channelCells2(7,:)';
    channelList(startChannel:endChannel,8)=channelCells2(8,:)';
    channelList(startChannel:endChannel,9)=channelCells2(3,:)';
    channelList(startChannel:endChannel,10)={MDFStructure.DGBlock(dataBlock).CGBlock.TXBlock.comment};

    startChannel=endChannel+1;

end


%%  formatstxtext
function tx = formatstxtext(blockSize)
% Return format for txt block section

tx= [{'uint8'}  {[1 double(blockSize)]}  {'comment'}];


%%  mdfread
function [data, signalNames]=mdfread(file,dataBlock,varagin)
% MDFREAD Reads MDF file and returns all the channels and signal names of
% one data group in an MDF file.
%
%   DATA = MDFREAD(FILENAME,DATAGROUP) returns in the cell array DATA, all channels
%   from data group DATAGROUP from the file FILENAME.
%
%   DATA = MDFREAD(MDFINFO,DATAGROUP) returns in the cell array DATA,  all channels
%   from data group DATAGROUP from the file whos information is in the data
%   structure MDFINFO returned from the function MDFINFO.
%
%
%   [..., SIGNALNAMES] = MDFREAD(...) Creates a cell array of signal names
%   (including time).
%
%    Example 1:
%
%             %  Retrieve info about DICP_V6_vehicle_data.dat
%             [data signaNames]= mdfread('DICP_V6_vehicle_data.dat');


%% Assume for now only sorted files supported
channelGroup=1;

%% Get MDF structure info
if ischar(file)
    fileName=file;
    [MDFsummary MDFInfo]=mdfinfo(fileName);
else
    MDFInfo=file;
end

numberOfChannels=double(MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).numberOfChannels);
numberOfRecords= double(MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).numberOfRecords);

if nargin==3
    selectedChannels=varagin; % Define channel selection vector
    if any(selectedChannels>numberOfChannels)
        error('Select channel out of range');
    end
end

if numberOfRecords==0 % If no data record, ignore
    warning(['No data records in block ' int2str(dataBlock) ]);
    data=cell(1); % Return empty cell
    signalNames=''; % Return empty cell
    return
end

%% Set pointer to start of data
offset=MDFInfo.DGBlock(dataBlock).pointerToDataRecords; % Get pointer to start of data block

%% Create channel format cell array
for channel=1:numberOfChannels
    numberOfBits= MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).numberOfBits;
    signalDataType= MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).signalDataType;
    datatype=datatypeformat(signalDataType,numberOfBits); %Get signal data type (e.g. 'int8')
    if signalDataType==7 % If string
        channelFormat(channel,:)={datatype [1 double(numberOfBits)/8] ['channel' int2str(channel)]};
    else
        channelFormat(channel,:)={datatype [1 1] ['channel' int2str(channel)]};
    end
end

%% Check for multiple record IDs
numberOfRecordIDs=MDFInfo.DGBlock(dataBlock).numberOfRecordIDs; % Number of RecordIDs
if numberOfRecordIDs==1 % Record IDs
    channelFormat=[ {'uint8' [1 1] 'recordID1'} ; channelFormat]; % Add column to start get record IDs
elseif numberOfRecordIDs==2
    error('2 record IDs Not suported')
    %channelFormat=[ channelFormat ; {'uint8' [1 1] 'recordID2'}]; % Add column to end get record IDs
end

%% Check for time channel
timeChannel=findtimechannel(MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock);

if length(timeChannel)~=1
    error('More than one time channel in data block');
end

%% Open File
fid=fopen(MDFInfo.fileName,'r');
if fid==-1
    error(['File ' MDFInfo.fileName ' not found']);
end

%% Read data
% Set file pointer to start of channel data
fseek(fid,double(offset),'bof');

if ~exist('selectedChannels','var')
    if numberOfRecordIDs==1 % If record IDs are used (unsorted)
        Blockcell = mdfchannelread(channelFormat,fid,numberOfRecords); % Read all
        recordIDs=Blockcell(1);         % Extract Record IDs
        Blockcell(1)=[];                % Delete record IDs
        selectedChannels=1:numberOfChannels; % Set selected channels
    else
        Blockcell = mdfchannelread(channelFormat,fid,numberOfRecords); % Read all
        selectedChannels=1:numberOfChannels; % Set selected channels
    end
else % if selectedChannels exists
    if numberOfRecordIDs==1  % If record IDs are used (unsorted)
        % Add Record ID column no mater the orientation of selectedChannels
        newSelectedChannels(2:length(selectedChannels)+1)=selectedChannels+1; % Shift
        newSelectedChannels(1)=1; % Include first channel of Record IDs
        Blockcell = mdfchannelread(channelFormat,fid,numberOfRecords,newSelectedChannels);
        recordIDs=Blockcell(1);         % Extract Record IDs, for future expansion
        Blockcell(1)=[];                % Delete record IDs,  for future expansion
    else
        Blockcell = mdfchannelread(channelFormat,fid,numberOfRecords,selectedChannels);
    end
end

% Cloce file
fclose(fid);

% Preallocate
data=cell(1,length(selectedChannels)); % Preallocate cell array for channels

% Extract data
for selectedChannel=1:length(selectedChannels)
    channel=selectedChannels(selectedChannel); % Get delected channel
    
    % Get signal names
    longSignalName=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).longSignalName;
    if ~isempty(longSignalName) % if long signal name is not empty use it
        signalNames{selectedChannel,1}=longSignalName; % otherwise use signal name
    else
        signalNames{selectedChannel,1}=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).signalName;
    end

    if MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).signalDataType==7
        % Strings: Signal Data Type 7
        data{selectedChannel}=truncintstochars(Blockcell{selectedChannel}); % String
    elseif MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).signalDataType==8
        % Byte arrays: Signal Data Type 8
        error('MDFReader:signalType8','Signal data type 8 (Byte array) not currently supported');
        
%     elseif MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).valueRangeKnown % If physical value is correct...
%         % No need for conversion formula
%         data{selectedChannel}=double(Blockcell{selectedChannel});
    else
        % Other data types: Signal Data Type 0,1,2, or 3
        
        % Get conversion formula type
        conversionFormulaIdentifier=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.conversionFormulaIdentifier;

        % Based on each convwersion fourmul type...
        switch conversionFormulaIdentifier
            case 0 % Parameteric, Linear: Physical =Integer*P2 + P1
                
                % Extract coefficients from data structure
                P1=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P1;
                P2=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P2;
                int=double(Blockcell{selectedChannel});
                data{selectedChannel}=int.*P2 + P1;
                
            case 1 % Tabular with interpolation
                
                % Extract look-up table from data structure                
                int_table=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.int;
                phys_table=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.phys;
                int=Blockcell{selectedChannel};
                data{selectedChannel}=interptable(int_table,phys_table,int);

            case 2 % Tabular
                
                % Extract look-up table from data structure
                int_table=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.int;
                phys_table=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.phys;
                int=Blockcell{selectedChannel};
                data{selectedChannel}=floortable(int_table,phys_table,int);
             
            case 6 % Polynomial
                
                % Extract polynomial coefficients from data structure
                P1=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P1;
                P2=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P2;
                P3=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P3;
                P4=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P4;
                P5=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P5;
                P6=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.P6;
                
                int=double(Blockcell{selectedChannel}); % Convert to doubles
                numerator=(P2-P4.*(int-P5-P6)); % Evaluate numerator
                denominator=(P3.*(int-P5-P6)-P1); % Evaluate denominator
                
                 % Avoid divide by zero warnings and return nan
                denominator(denominator==0)=nan; % Set 0's to Nan's
                result=numerator./denominator;

                data{selectedChannel}=result;
                
            case 10 % ASAM-MCD2 Text formula
                textFormula=MDFInfo.DGBlock(dataBlock).CGBlock(channelGroup).CNBlock(channel).CCBlock.textFormula;
                x=double(Blockcell{selectedChannel}); % Assume stringvariable is 'x'
                data{selectedChannel}=eval(textFormula); % Evaluate string
                
            case 65535 % 1:1 conversion formula (Int = Phys)
                data{selectedChannel}=double(Blockcell{selectedChannel});
                
            case {11, 12} % ASAM-MCD2 Text Table or ASAM-MCD2 Text Range Table
                % Return numbers instead of strings/enumeration
                data{selectedChannel}=double(Blockcell{selectedChannel}); 

            otherwise % Un supported conversion formula
               error('MDFReader:conversionFormulaIdentifier','Conversion Formula Identifier not supported'); 

        end
    end
end


%%  mygenvarname
function varName=mygenvarname(signalName)
% Returns a valid valiable name from the string in SIGNALNAME
%
% Example
%  a=mygenvarname('45\67')
%  a =
%  x45_bs_67

varName=signalName; % Its a valid variable names, we are done

% Not valid
if ~isvarname(varName)
   
    % Remove unsupported characaters
    varName = strrep(varName,'\','_bs_');  % Replace '\' with '_bs_'
    varName = strrep(varName,'/','_fs_');  % Replace '/' with '_fs_'

    varName = strrep(varName,'[','_ls_');  % Replace '[' with '_ls_'
    varName = strrep(varName,']','_rs_');  % Replace ']' with '_rs_'

    varName = strrep(varName,'(','_lp_');  % Replace '(' with '_lp_'
    varName = strrep(varName,')','_rp_');  % Replace ')' with '_rp_'

    varName = strrep(varName,'@','_at_');  % Replace '@' with '_at_'
        
    %varName = strrep(varName,' ','_sp_');  % Replace ' ' with '_sp_'
    varName = strrep(varName,' ','_');      % Replace ' ' with '_'
    varName = strrep(varName,':','_co_');  % Replace ':' with '_co_'
    varName = strrep(varName,'-','_hy_');  % Replace '-' with '_hy_'
    varName = strrep(varName,'.','p');     % Replace '.' with 'p'
    varName = strrep(varName,'$','S_');    % Replace '$' with 'S_'
    %varName = strrep(varName,'.','_dot_'); % Replace '.' with '_dot_'
    
    if double(varName(1))>=48 & double(varName(1))<=57 % If starts with a number
    % if ~isvarname(varName)          
        varName=['x'  varName];  % ...add an x to the start
    end
end


%%  mdfblockread
function Block=mdfblockread(blockFormat,fid,offset,repeat)
% MDFBLOCKREAD Extract block of data from MDF file in orignal data types
%   Block=MDFBLOCKREAD(BLOCKFORMAT, FID, OFFSET, REPEAT) returns a
%   structure with field names specified in data structure BLOCKFORMAT, fid
%   FID, at byte offset in the file OFFSET and repeat factor REPEAT
%
% Example block format is:
% blockFormat={...
%     UINT8  [1 4]  'ignore';...
%     INT32  [1 1]  'pointerToFirstDGBlock';  ...
%     UINT8  [1 8]   'ignore';  ...
%     UINT16 [1 1]  'numberOfDataGroups'};
%
% Example function call is:
% Block=mdfblockread(blockFormat, 1, 413, 1);

% Extract parameters
numFields=size(blockFormat,1); % Number of fields
precisions=blockFormat(:,1); % Precisions (data types) of each field
fieldnames=blockFormat(:,3); % Field names

% Number of elements of a data type in one field
% This is only not relevent to one for string arrays

% Calculate counts variable to store number of data types
% For R14SP3: counts= cellfun(@max,blockFormat(:,2));
counts=zeros(numFields,1); 
for k=1:numFields
    %counts(k)=max(blockFormat{k,2});
    counts(k)=blockFormat{k,2}(end); % Get last value
end

fseek(fid,double(offset),'bof');
for record=1:double(repeat)
    for field=1:numFields
        count=counts(field);
        precision=precisions{field};
        fieldname=fieldnames{field};
        if strcmp(fieldname,'ignore')
            fseek(fid,getsize(precision)*count,'cof');
        else
            Block.(fieldname)(record,:)=fread(fid,count,['*' precision])';
        end
    end
end


%%  datatypeformat
function dataType= datatypeformat(signalDataType,numberOfBits)
% DATATYPEFORMAT Data type format precision to give to fread
%   DATATYPEFORMAT(SIGNALDATATYPE,NUMBEROFBITS) is the precision string to
%   give to fread for reading the data type specified by SIGNALDATATYPE and
%   NUMBEROFBITS

switch signalDataType
    
    case 0 % unsigned
        switch numberOfBits
            case 8
                dataType='uint8';
            case 16
                dataType='uint16';
            case 32
                dataType='uint32';
            case 1
                dataType='ubit1';
            case 2
                dataType='ubit2';
            otherwise
                error('Unsupported number of bits for unsigned int');
        end
        
    case 1 % signed int
        switch numberOfBits
            case 8
                dataType='int8';
            case 16
                dataType='int16';
            case 32
                dataType='int32';
            otherwise
                error('Unsupported number of bits for signed int');
        end
        
    case {2, 3} % floating point
        switch numberOfBits
            case 32
                dataType='single';
            case 64
                dataType='double';
            otherwise
                error('Unsupported number of bit for floating point');
        end
        
    case 7 % string
        dataType='uint8';
        
     otherwise
        error('Unsupported Signal Data Type');
end


%%  mdfchannelread
function Block=mdfchannelread(blockFormat,fid,repeat,varagin)

% Store starting point of file pointer
offset=ftell(fid);

if nargin==4
    selectedChannels=varagin; % Define channel selection vector
end

% Extract parameters
numFields=size(blockFormat,1); % Number of fields
precisions=blockFormat(:,1); % Precisions (data types) of each field

% Number of elements of a data type in one field
% This is only not relevent to one for string arrays

% For R14SP3: counts= cellfun(@max,blockFormat(:,2));
counts=zeros(numFields,1);
for k=1:numFields
    counts(k,1)=max(blockFormat{k,2});
end

% For R14 SP3: numFieldBytes=cellfun(@getsize,precisions).*counts;

% Number of bytes in each field
for k=1:numFields
    numFieldBytes(k,1)=getsize(precisions{k}).*counts(k); % Number of bytes in each field
end

numBlockBytes=sum(numFieldBytes); % Total number of bytes in block
numBlockBytesAligned=ceil(numBlockBytes); % Aligned to byte boundary
cumNumFieldBytes=cumsum(numFieldBytes); % Cumlative number of bytes
startFieldBytes=[0; cumNumFieldBytes]; % Starting number of bytes for each field relative to start

% Preallocate Clock cell array
Block= cell(1,numFields);

% Find groups of fields with the same data type
fieldGroup=1;
numSameFields(fieldGroup)=1;
countsSameFields(fieldGroup)=counts(1);
for field =1:numFields-1
    if strcmp(precisions(field),precisions(field+1))& counts(field)==counts(field+1) % Next field is the same data type
        numSameFields(fieldGroup,1)=numSameFields(fieldGroup,1)+1; % Increment counter

    else
        numSameFields(fieldGroup+1,1)=1; % Set to 1...
        countsSameFields(fieldGroup+1)=counts(field+1);
        fieldGroup=fieldGroup+1; % ...and more to next filed group
    end
end

field=1;
for fieldGroup=1:length(numSameFields)

    % Set pointer to start of fieldGroup
    offsetPointer=offset+startFieldBytes(field);
    fseek(fid,offsetPointer,'bof');

    count=1*repeat; % Number of rows repeated
    precision=precisions{field}; % Extract precision of all channels in field

    % Calculate precision string
    if strcmp(precision, 'ubit1')
        skip=8*(numBlockBytesAligned-getsize(precision)*numSameFields(fieldGroup)); % ensure byte aligned
        precisionString=[int2str(numSameFields(fieldGroup)) '*ubit1=>uint8'];
    elseif strcmp(precision, 'ubit2')
        skip=8*(numBlockBytesAligned-getsizealigned(precision)*numSameFields(fieldGroup)); % ensure byte aligned
        precisionString=[int2str(numSameFields(fieldGroup)) '*ubit2=>uint8']; % TO DO change skip to go to next byte
    else        
        skip=numBlockBytesAligned-getsize(precision)*countsSameFields(fieldGroup)*numSameFields(fieldGroup); % ensure byte aligned
        precisionString=[int2str(numSameFields(fieldGroup)*countsSameFields(fieldGroup)) '*' precision '=>' precision];
    end

    % Read file
    if countsSameFields(fieldGroup)==1  % TO Do remove condistiuon
        data=fread(fid,double(count)*numSameFields(fieldGroup),precisionString,skip);
    else %% string
        % Read in columnwize, ech column is a string lengt - countsSameFields(fieldGroup)
         data=fread(fid,double([countsSameFields(fieldGroup) count*numSameFields(fieldGroup)]),precisionString,skip);   
         data=data';
    end

    % Copy each field from the field group into the cell array
    if numSameFields(fieldGroup)==1
        Block{field}=data;
        field=field+1;
    else
        for k=1:numSameFields(fieldGroup)
            Block{field}=data(k:numSameFields(fieldGroup):end);
            field=field+1;
        end
    end
end
if exist('selectedChannels','var')
    Block=Block(:,selectedChannels);
end

%%  Align to start of next row
current=ftell(fid); % Current poisition
movement=current-offset; % Distance gone
remainder=rem(movement,numBlockBytesAligned); % How much into next row it is
fseek(fid,-remainder,'cof'); % Rewind to start of next row


%%  interptable
function interpdata=interptable(int_table,phys_table,int)
% INTERPTABLE return physical values from look up table
%   FLOORTABLE(INT_TABLE,PHYS_TABLE,INT) returns the physical value
%   from PHYS_TABLE corresponding to the value in INT_TABLE that is closest
%   to and less than INT.
%
%   Example:
%   floorData=floortable([1 5 7],[10 50 70],3);

if ~all(diff(int_table)>=0)
    error('Interpolation table not monotically increasing');
end

int=double(int);
if min(size(int_table))==1 || min(size(phys_table))==1
    % Saturate data to min and max
    int(int>int_table(end))= int_table(end);
    int(int<int_table(1))= int_table(1);

    % Interpolate
    interpdata=interp1(int_table,phys_table,int,'linear');
else
    error('Only vector input supported');
end


%%  floortable
function floorData=floortable(int_table,phys_table,int)
% FLOORTABLE return physcial values looked up
%   FLOORTABLE(INT_TABLE,PHYS_TABLE,INT) returns the physical value
%   from PHYS_TABLE corresponding to the value in INT_TABLE that is closest
%   to and less than INT.

%   Example:
%   floorData=floortable([1 5 7],[10 50 70],3);

if ~all(diff(int_table)>=0)
    error('Table not monotically increasing');
end

int=double(int);
if min(size(int_table))==1 || min(size(phys_table))==1

    % Saturate data to min and max
    int(int>int_table(end))= int_table(end);
    int(int<int_table(1))= int_table(1);
    floorData=zeros(size(int)); % Preallocate
    
    % Look up value in table
    for k=1:length(int)
        differences=(int(k)-int_table);
        nonNegative=differences>=0;
        [floorInt,index]=min(differences(nonNegative));
        temp=phys_table(nonNegative);
        floorData(k)=temp(index);
    end
else
    error('Only vector input supported');
end


%%  getsize
function sz = getsize(f)
% GETSIZE returns the size in bytes of the data type f
%
%   Example: 
%
% a=getsize('uint32');

switch f
    case {'double', 'uint64', 'int64'}
        sz = 8;
    case {'single', 'uint32', 'int32'}
        sz = 4;
    case {'uint16', 'int16'}
        sz = 2;
    case {'uint8', 'int8'}
        sz = 1;
    case {'ubit1'}
        sz = 1/8;
    case {'ubit2'}
        sz = 2/8; % for purposes of fread
end


%%  processsignalname
function updatedNames=processsignalname(ChannelList,removeDeviceNames,addCGTX)
% Process the signal names in the cell array CHANNELLIST ready for displaying in the list boxes
% by adding addtional information such as rates
%
% removeDeviceNames ==1 add then remove devoce names
%
% addCGTX ==1 add the channel group block text
% 

if size(ChannelList,1)>0 % Check that there are some names to process
    updatedNames=ChannelList(:,1); % Copy names
    
    if removeDeviceNames % If the device names are to be removed
        updatedNames=removedevicenames(updatedNames);
    end
    
    if addCGTX   % If the channel group block text is to be added
        %updatedNames=strcat(updatedNames,' (', cellstr(num2str(cell2mat(ChannelList(:,4)))),')');
        updatedNames=strcat(updatedNames,' (', ChannelList(:,10),')');
    end
else
    updatedNames=[]; % Return null cell
end


%%  processrates
function [rateStrings, possibleRates,possibleRateIndices]=processrates(ChannelList)
% Returns a cell array of strings displaying information about the unique
% rates of the signals in ChannelList

if size(ChannelList,1)>0
    
    formatString='%6.5f';
    
    % Get rates
    selectedDataBlocks=cell2mat(ChannelList(:,4));
    
    [possibleBlocks,lastIndices,possibleRateIndices]=unique(selectedDataBlocks); % Find all the possible data blocks
    possibleRates=cell2mat(ChannelList(lastIndices,5));
    
    % Prepend with space ' '
    rateStrings=cellstr([repmat(' ',size(possibleRates,1),1) num2str(possibleRates,formatString)]);
    timeVectorStrings=cellstr(int2str(possibleBlocks));

    % Append with rate strings
    rateStrings= strcat(timeVectorStrings,') ',ChannelList(lastIndices,10),' | ',rateStrings);

else
    rateStrings=[]; % If no channels entered return null
    possibleRates=[];
    possibleRateIndices=[];
end


%%  findtimechannel
function timeChannel=findtimechannel(CNBlock)
% Finds the locations of time channels in the channel block
% Take channel blcok array of structures

% % Sort channel list
% position=zeros(length(CNBlock),1);
% for channel = 1: length(CNBlock)
%     position(channel)=CNBlock.numberOfFirstBits;
% end

channelsFound=0; % Initialize to number of channels found to 0

% For each channel
for channel = 1: length(CNBlock)
    if CNBlock(channel).channelType==1; % Check to see if is time
        channelsFound=channelsFound+1; % Increment couner of found time channels
        timeChannel(channelsFound)=channel; % Store time channel location
    end
end


%%  importdatawithoptions
function importdatawithoptions(options)
% Core data import function called from GUI and comand line

    channelsImported=0;
    numDataBlocks=length(options.MDFInfo.DGBlock);
    shortest = inf;
    allsignals = 'time';

    if strcmpi(options.importTo,'workspace')
        ws='base';
    else
        ws='caller';
    end

    % Load signals
    for dataBlock=1:numDataBlocks
        foundChannels=cell2mat(options.selectedChannelList(:,4))==dataBlock; % What channels are in this block
        thisBlockChannels=options.selectedChannelList(foundChannels,:); % Extract channel info
        selectedChannelIndices=cell2mat(thisBlockChannels(:,3));

        if strcmpi(options.timeVectorChoice,'actual') % If using actual time vectors
            if length(selectedChannelIndices)>=1
                % TO DO generalize time channel
                timechannel=findtimechannel(options.MDFInfo.DGBlock(dataBlock).CGBlock(1).CNBlock);
                channelIndices=sort([timechannel; selectedChannelIndices]); % Add time channel and sort
                [size names] = mdfload(options.MDFInfo,dataBlock,channelIndices,options.blockDesignation,ws,options.additionalText);
                 %disp(['Block size: ' int2str(size)]);
                if and(size < shortest, size > 0)
                    shortest = size;
                end
                allsignals = [allsignals; names];

                % Increment channel count
                channelsImported=channelsImported+length(channelIndices);
            end
        else % Create ideal uniform time vectors
            if strcmpi(options.timeVectorChoice,'ideal') % If using actual time vectors
                if length(selectedChannelIndices)>=1 % If some channels in this block
                    thisBlockChannelRateIndices=options.possibleRateIndices(foundChannels); % All should be the same
                    rateVariableSampled=options.possibleRates(thisBlockChannelRateIndices(1)); % All same
                    rateComment=options.MDFInfo.DGBlock(dataBlock).CGBlock.TXBlock.comment; % Comment rate for this block

                    numberOfRecords=double(options.MDFInfo.DGBlock(dataBlock).CGBlock.numberOfRecords);
                    channelIndices=sort(selectedChannelIndices); % sort
                    [size names] = mdfload(options.MDFInfo,dataBlock,channelIndices,options.blockDesignation,ws,options.additionalText);
                    %disp(['Block size: ' int2str(size)]);
                    if and(size < shortest, size > 0)
                        shortest = size;
                    end
                    allsignals = [allsignals; names];

                    %%  Make time channel and import to choosen location

                    % Construct variable name
                    switch options.blockDesignation
                        case 'ratenumber'
                            varName= ['time_' int2str(dataBlock) options.additionalText];
                        case 'ratestring'
                            varName=['time_' rateComment options.additionalText];
                        otherwise
                            error('Block designator not known');
                    end
                    varName=mygenvarname(varName); % Make legal if you can

                    % Test if legal
                    if isvarname(varName)  % If legal var name (usually is for time)
                        assignin(ws, varName, ((0:numberOfRecords-1)')*rateVariableSampled); % Save it in choosen location
                        disp(['... and 1 ideal uniform time vector ''' varName '''']);
                    else % If still not legal
                        warning(['Ignoring modified signal name ''' varName '''. Cannot be turned into a variable name.']);
                    end

                    % Increment channel count
                    channelsImported=channelsImported+length(channelIndices);
                end
            else  % Create ideal resampled time vector
                if strcmpi(options.timeVectorChoice,'resample') % If signals are to resample
                    if length(selectedChannelIndices)>=1 % If some channels in this block
                        timechannel=findtimechannel(options.MDFInfo.DGBlock(dataBlock).CGBlock(1).CNBlock);
                        channelIndices=sort([timechannel; selectedChannelIndices]); % Add time channel and sort
                        options.blockDesignation = 'empty';
                        [size names] = mdfload(options.MDFInfo,dataBlock,channelIndices,options.blockDesignation,ws,options.additionalText,options.newSampleRate);
                        %disp(['Block size: ' int2str(size)]);
                        if and(size < shortest, size > 0)
                            shortest = size;
                        end
                        allsignals = [allsignals; names];

                        % Increment channel count
                        channelsImported=channelsImported+length(channelIndices);
                    end
                end
            end
        end
        
        % If being called from GUI
        if ~isempty(options.waitbarhandle)
            waitbar(channelsImported/length(options.selectedChannelList),options.waitbarhandle,'Importing...');
        end
    end % for
    if strcmpi(options.timeVectorChoice,'resample') % show the shortest vector only when it was resampled
      disp(['shortest: ' int2str(shortest)]);
      assignin(ws, 'shortest', shortest); % Save it in choosen location
    end
    assignin(ws, 'allsignals', allsignals); % Save it in choosen location
    
    % Save to MAT file is requested
    if ~strcmpi(options.importTo,'workspace') % If not going to workspace

        % Find variables in this workspace
        vars=whos;
        allVariables=cell(1,length(vars)); % Preallocate cell array
        for var=1:length(vars)
            allVariables{var}=vars(var).name;
        end
        %%%R14Sp3%%% allVariables=arrayfun(@(x) x.name,whos,'UniformOutput',false);

        functionVariables={'MDFInfo';... % Variables used in the function
            'blockDesignation';'channelIndices';'channelsImported';...
            'dataBlock';'eventdata';'foundChannels';'hObject';'handles';'numDataBlocks';...
            'selectedChannelIndices';'thisBlockChannels';'uibackgroundcolor';'waitbarhandle';...
            'ws';'options';'timechannel'};

        % Difference is what was generated by mdfload
        generatedVariables=setdiff(allVariables,functionVariables);

        if strcmpi(options.importTo,'MAT-File')  % If called from GUI and MAT-File specified
            % Set MAT-file name initialy to MDF file name
            fileNameBase=options.fileName(1:end-4);

            % Let user specify a different name and location
            [selectionFileName,pathName]= uiputfile([fileNameBase '.mat'],'Specify MAT File to Save Signals');

            % Save MAT-file
            MATFileName=[pathName selectionFileName];
        else % MAT-File given as parameter
            MATFileName=options.importTo; % MAT-File is specified in import to parameter
        end

        % If being called from GUI
        if ~isempty(options.waitbarhandle)
            waitbar(1,options.waitbarhandle,'Saving MAT-File...');
        end
        
        save(MATFileName,generatedVariables{:});   % Save MAT-file
    end

    
%%  readtextfile
function requestedChannelList=readtextfile(fileName)
% Reads (signal selection) text file one line at a time
% and returns eac hline in a cell array

fid=fopen(fileName,'rt'); % Open text file for reading

signalName=1; % Initialize counter
requestedChannelList{signalName}=''; % Initialize cells

while ~feof(fid)
    requestedChannelList{signalName,1}=fgetl(fid); % Read one line
    signalName=signalName+1; % Increment counter
end
fclose(fid); % Close file


%%  applyselectionfile
function handles=applyselectionfile(handles,requestedChannelList)

% Find requested channels
[selectedChannelList,unselectedChannelList]=findrequestedchannels(requestedChannelList,handles.channelList);

% Update data strcuture when sure it is valid
handles.selectedChannelList=selectedChannelList;
handles.unselectedChannelList=unselectedChannelList;

% Sort these channels
[dummy,sortIndices]=sort(handles.selectedChannelList(:,1)); % Get sorted names
handles.selectedChannelList=handles.selectedChannelList(sortIndices,:);

% Update selected channels list box
updatedNames=processsignalname(handles.selectedChannelList,handles.removeDeviceNames,1);
set(handles.selectedchannellistbox,'String',updatedNames);

% Update unselected channels list box
updatedNames=processsignalname(handles.unselectedChannelList,handles.removeDeviceNames,1);
set(handles.unselectedchannellistbox,'Value',[]); % Update unselected list
set(handles.unselectedchannellistbox,'String',updatedNames);

% Updates rate list box and edit box
handles=updaterates(handles);


%%  updaterates
function handles=updaterates(handles)
% Looks at rate selection list box an edit box and modifies stored possible
% rates to new ones

% Update rates list
[rateStrings,possibleRates,possibleRateIndices]=processrates(handles.selectedChannelList);
handles.possibleRates=possibleRates; % Update stored possible rates
handles.possibleRateIndices=possibleRateIndices; % Update stored possible rate indices
selectedIndex=get(handles.selectedrates_listbox,'Value');    % Current selected index
if selectedIndex>length(possibleRates) | selectedIndex==0
    % Make sure value of list box is never more than length
    set(handles.selectedrates_listbox,'Value',length(possibleRates));
end
set(handles.selectedrates_listbox,'String',rateStrings); % Update strings

% Update edit box
selectedItem=get(handles.selectedrates_listbox,'Value'); % Get item selected
if ~isempty(handles.possibleRates) & selectedItem > 0
    selectedItem=get(handles.selectedrates_listbox,'Value'); % Get item selected
    selectedRate=handles.possibleRates(selectedItem); % Get rate selected
    set(handles.edit3,'String',num2str(selectedRate)); % Update edit box with rate
else
    set(handles.edit3,'String',[]); % Update edit box with rate
end


%%  findrequestedchannels
function [selectedChannelList,unselectedChannelList]=findrequestedchannels(requestedChannelList,oldUnselectedChannelList,options)
% Searches the cell array unselectedChannelList to find all the signals
% listed in requestedChannelList. The results are put in
% selectedChannelList and teh onces left are placed in
% unselectedChannelList

notFoundSignals=[]; % Initialize
selectedChannelList=[]; % Initialize
unselectedChannelList=oldUnselectedChannelList; % Initialize to starting list

numRequestedChannels=length(requestedChannelList); % Calculate number of requested channels

%keyboard

for channel=1:numRequestedChannels % For each requested channel
    % Get cell array of strings of names to check
    unselectedChannelListNoDeviceNames=removedevicenames(unselectedChannelList(:,1)); % Remove device names

    % Find selected channel(s) in list
    found=zeros(size(unselectedChannelList,1),1)~=0; % Preallocate
    for checkChannel=1:size(unselectedChannelList,1)
        found(checkChannel,1)=strcmp(... % Find each request channel in unselected list
        unselectedChannelListNoDeviceNames{checkChannel,1},requestedChannelList{channel});
    end
    
    % Move found channel(s) from unselected to selected (should be just
    % one. Could be expanded in future to allow selecting of multiple channels)
    selectedChannelList=[selectedChannelList;unselectedChannelList(found,:)];
    unselectedChannelList(found,:)=[]; % Clear unselected channel(s)
    unselectedChannelListNoDeviceNames(found)=[]; % Clear unselected channel(s) from name list too


    if sum(found)>1 % Warn if more than one signal found matching requested signal name
        disp('More than one signal found matching requested signal name');
    end
    if sum(found)==0 % Keep tally of the names of the signals that were not found
        notFoundSignals=[notFoundSignals;requestedChannelList(channel)];
    end

end

if  length(notFoundSignals)>0 % If some were not found, display message
    disp(['The following ' int2str(length(notFoundSignals)) ' signal(s) were not found in MDF file']);
    disp(notFoundSignals);
end


%%  parseparameters
function options=parseparameters(parameters)
% 1) filename: 'sdfdsf.dat' required
% 2) import to: ['workspace'], 'sdfds.mat'(test valid),  empty,
% 3) selecton file: ['all'], 'xxx.txt' (test valid), cell array of stings, empty
% 4) time vector times:  ['actual'], 'uniform', empty
% 5) rate desination: ['ratenumber'], 'ratestring', empty
% 6) additional text: ['']
% 7) include device names: [false], true
%
% help funtion to parse parameters when being called from command line

%% Process 1st parameter: File name
% Check file name of MDF file
if ~exist(parameters{1},'file') %TO Do put back
    error(['Can''t find MDF file ' parameters{1}]);
end
options.fileName=parameters{1}; % 1) File name


% Get MDF info
[MDFsummary, options.MDFInfo, counts, channelList]=mdfinfo(options.fileName);

timeChannels=cell2mat(channelList(:,9))==1;
channelList(timeChannels,:)=[]; % Delete time channels to create 'all' selection list

timeChannels=cell2mat(channelList(:,8))==7; % To DO
channelList(timeChannels,:)=[]; % Delete string channels to create 'all' selection list


%% Process 2nd parameter: import location
if length(parameters)>=2 % If 2nd paramter provided...
    % Is it empty or equal to 'workspace'
    if isempty(parameters{2}) | strcmpi(parameters{2},'workspace')
        options.importTo='workspace';  % then 'workspace' is the choose import location
        % Otherwise, if  it is equal to 'Auto MAT-File'...
    elseif strcmpi(parameters{2},'Auto MAT-File')
        options.importTo=[options.fileName(1:end-4) '.mat']; % Then an auto named MAT file is the import location
        % Otherwise, if ends in .mat...
    elseif strcmpi(parameters{2}(end-3:end),'.mat')
        options.importTo=parameters{2}; % Then use the specified MAT file
        % Otherwise, error out.
    else
        error(['2nd parameter ''' parameters{2} ''' is not valid. Should be either ''workspace'', ''Auto MAT-File'', a MAT file name or empty.']);
    end
else
    options.importTo='workspace'; % Default
end


%% Process 3rd parameter: signal selection
if length(parameters)>=3
    % 3) selecton file: ['all'], 'xxx.txt' (test valid), cell array of
    % stings, empty
    if length(parameters{3})>=5 % Test if long enough to be a file name
        txtFile=strcmpi(parameters{3}(end-3:end),'.txt'); % check for txt file
    end
    if isempty(parameters{3})  % a) Empty
        options.selectedChannelList=channelList; % Import all channels
        options.importAllChannels=true;
    elseif isa(parameters{3},'char') % If text value
        if strcmpi(parameters{3},'all') % a) all is only valid text value
            options.selectedChannelList=channelList; % Import all channels
            options.importAllChannels=true;

        elseif txtFile % b) Use specified txt file
            if exist(parameters{3},'file')
                requestedChannelList=readtextfile(parameters{3}); % Load file
                [selectedChannelList,unselectedChannelList]=...
                    findrequestedchannels(requestedChannelList,channelList,false);
                options.selectedChannelList=selectedChannelList;
                options.importAllChannels=false;
            else
                error(['Can''t read signal selection file ' parameters{3}]);
            end

        else % Must be one signal name
            requestedChannelList={parameters{3}}; % Put teh one siganl in a cell
            [selectedChannelList,unselectedChannelList]=...
                findrequestedchannels(requestedChannelList,channelList);
            options.selectedChannelList=selectedChannelList;
            options.importAllChannels=false;
            %error(['3rd parameter ' parameters{3}... % Error
            %' is not valid.''all'' is the only valid text string. Put signal names in a cell array']);
        end

    elseif isa(parameters{3},'cell') % c) Cell array
        requestedChannelList=parameters{3};
        [selectedChannelList,unselectedChannelList]=...
            findrequestedchannels(requestedChannelList,channelList);
        options.selectedChannelList=selectedChannelList;
        options.importAllChannels=false;

    else
        error(['3rd parameter ''' parameters{3} ''' is not valid. Should be either ''all'', a cell array of signal names, one signal name char array (string) or a signal selection file name']);
    end
else
    options.selectedChannelList=channelList; % Default
    options.importAllChannels=true; % Default
end

%% Process 4th parameter: time vector instants
if length(parameters)>=4
    if isempty(parameters{4}) | strcmpi(parameters{4},'actual') % a) Empty or actual
        options.timeVectorChoice='actual';
    elseif strcmpi(parameters{4},'ideal')
        options.timeVectorChoice='ideal';
    elseif strncmpi(parameters{4},'resample_', length('resample_'))
        options.timeVectorChoice='resample';
        sz_tmp = parameters{4}(length('resample_')+1:length(parameters{4}));
        options.newSampleRate=str2double(sz_tmp);
        if options.newSampleRate <= 0
            error(['4th parameter ''' parameters{4} ''' does not contain a valid number '''  sz_tmp ''' as sampling rate.']);
        end
            
    else
        error(['4th parameter ''' parameters{4} ''' is not valid. Should be ''actual'' or ''ideal'' or ''resample_x.x''']);
    end
else
    options.timeVectorChoice='actual'; % Default
end

%% Process 5th parameter: rate designation
if length(parameters)>=5 % rate designation
    if isempty(parameters{5}) | strcmpi(parameters{5},'ratenumber') % a) Empty or number
        options.blockDesignation='ratenumber';
    elseif strcmpi(parameters{5},'ratestring')
        options.blockDesignation='ratestring';
    elseif strncmpi(parameters{4},'resample_', length('resample_'))
        options.blockDesignation='ratenumber';
    else
        error(['5th parameter ''' parameters{5} ''' is not valid. Should be ''ratenumber'' or ''ratestring''']);
    end
else
    options.blockDesignation='ratenumber'; % Default
end

%% Process 6th parameter: additional text
if length(parameters)>=6 & ~isempty(parameters{6})
    if isa(parameters{6},'char')
        options.additionalText=parameters{6};
    else
        error(['6th parameter ''' parameters{6} ''' is not valid. Must be a char array (string) or empty']);
    end
else
    options.additionalText=''; % Default
end

if length(parameters)>=7
    if isa(parameters{7},'logical')
        options.includeDeviceName=parameters{7};
    else
        error(['7th parameter ''' parameters{7} ''' is not valid. Must be true, false or empty']);
    end
else
    options.includeDeviceName = false;
end

%% Error if more than 7 parameters
if length(parameters)>=8
    error('Too many parameters');
end

%% Other parameters
% These not defined when called from command line
[rateStrings,possibleRates,possibleRateIndices]=processrates(options.selectedChannelList);
options.possibleRateIndices=possibleRateIndices;
options.possibleRates=possibleRates;
options.waitbarhandle=[];


%%  getoptionsfromgui
function options=getoptionsfromgui(handles)
% Returns struction of options from GUI uicontrols and other GUI info
% used to control import routine

MDFInfo=handles.MDFInfo;

% Signal import location
choices={'workspace','MAT-File'};
importTo=choices{get(handles.importlocation_popup,'Value')};

% Choose how to designate block/rate
choices={'ratenumber','ratestring'};
blockDesignation=choices{get(handles.ratedesignation_popup,'Value')};

% Time vector type
choices={'actual','ideal', 'resample'};
newSampleRate = 0.005;
if get(handles.timevectorchoice1,'Value')==1 %
    timeVectorChoice=choices{1};
else
    if get(handles.timevectorchoice2,'Value')==1 %
        timeVectorChoice=choices{2};
    else
        if get(handles.timevectorchoice3,'Value')==1 %
            timeVectorChoice=choices{3};
            newSampleRate = str2double(get(handles.edit3, 'String'));
        end
    end
end

% Additional text
additionalText= get(handles.additionaltext,'String');

% Import all channels check
if isempty(handles.unselectedChannelList) % If no unselected channels
    importAllChannels=true; % Import them all
else
    importAllChannels=false;
end

% Other data from GUI
fileName=handles.fileName;
possibleRateIndices=handles.possibleRateIndices;
possibleRates=handles.possibleRates;

% Form parameters for function
options=struct('fileName',fileName,'MDFInfo',MDFInfo,...
    'importTo',importTo,'blockDesignation', blockDesignation,'timeVectorChoice', timeVectorChoice,...
    'possibleRateIndices', possibleRateIndices,'possibleRates', possibleRates,...
    'additionalText',additionalText,'importAllChannels',importAllChannels, 'newSampleRate', newSampleRate);

options.waitbarhandle=[]; % Default to empty
options.selectedChannelList=handles.selectedChannelList; % Add extra as it is a cell array


%%  generatecommand
function command = generatecommand(options)
% Generate equivalent commands for a successful import

% Menu option (commdn>generate command code and selection file, auto, cells) or automatic
% go backwards

% Initialize to empty
command='';

% Additional text
if ~isempty(options.additionalText) 
    command=[ ',''' options.additionalText '''' command];
end

% Rate designation
if strcmpi(options.blockDesignation,'ratenumber') % default
    if ~isempty(command) 
        command=[',[]' command];
    end
else
    command=[ ',''' options.blockDesignation '''' command];
end

% Time vector selection
if strcmpi(options.timeVectorChoice,'actual') % default
    if ~isempty(command) 
        command=[',[]' command];
    end
elseif strcmpi(options.timeVectorChoice,'resample')
    command=[',''resample_' num2str(options.newSampleRate,'%f') '''' command];
else
    command=[',''' options.timeVectorChoice  '''' command]; %ideal
end

% Signal selection
if options.importAllChannels | isempty(options.selectedChannelList) % default or ignore channels not found
    if ~isempty(command)
        command=[',[]' command];
    end
    
elseif isa(options.selectedChannelList,'cell') % If cell array of signal names

    str='{'; % Make cell array list
    for k= 1:size(options.selectedChannelList,1)
        str=[str '''' removedevicenames(options.selectedChannelList{k}) ''','];
    end
    str=[str(1:end-1) '}']; %  Remove last ',' and add }
    command=[',' str command]; % Put cell array in command
    
elseif isa(options.selectedChannelList,'char')% If text file
    command=[',''' options.selectedChannelList  '''' command];
else
    error('Wrong signal selection parameter');
end
%% Add warning if selected signal being ignored.

% Location
if strcmpi(options.importTo,'workspace')
    if ~isempty(command)
        command=[',[]' command];
    end
elseif strcmpi(options.fileName(1:end-4),options.importTo(1:end-4))  % Auto MAT file
    command=[',''Auto MAT-File''' command];
else
    command=[',''' options.importTo '''' command]; % Custom MAT file
end

% File name and finish
if isempty(command)
    command=['mdfimport(''' options.fileName ''');'];
else
    command=['mdfimport(''' options.fileName '''' command ');'];
end


%%  getsizealigned
function sz = getsizealigned(f)
% GETSIZE returns the size in bytes of the data type f
%
%   Example: 
%
% a=getsize('uint32');

switch f
    case {'double', 'uint64', 'int64'}
        sz = 8;
    case {'single', 'uint32', 'int32'}
        sz = 4;
    case {'uint16', 'int16'}
        sz = 2;
    case {'uint8', 'int8'}
        sz = 1;
    case {'ubit1'}
        sz = 1/8;
    case {'ubit2'}
        sz = 1; % for purposes of fread
end


%%  truncintstochars
function  truncstring=truncintstochars(ints)
% Converts an array of integers to characters and truncates the string to
% the first non zero integers.

[m,n]=size(ints);

if m > 1 % if multiple strings
    truncstring=cell(m,1); %preallocate
end

for k=1:m % for each row
    % For R14: lastchar=find(ints==0,1,'first')-1;
    lastchar=find(ints(k,:)==0)-1;

    if isempty(lastchar) % no blanks
        truncstring{k}=char(ints(k,:));
    else
        lastchar=lastchar(1); % Get first
        truncstring{k}=char(ints(k,1:lastchar));
    end
end

if m == 1 % If just one string
    truncstring=truncstring{1}; % Convert to char
end


%%  Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


%%  Executes on button press in saveascsv.
function saveascsv_Callback(hObject, eventdata, handles)
% hObject    handle to saveascsv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveascsv

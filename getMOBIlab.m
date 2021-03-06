function [ai, REC] = getMOBIlab(REC)
% g.MOBIlab specific settings
% These settings can be adjusted for different EEG hardware
% REC = handles.REC;
REC.devName = 'gmlplusdaq';
REC.Fs = 256;
REC.channels = 1:8;

waith = waitbar(0 , 'searching for EEG hardware');
% if ~exist('ai','var')
ai = [];
% Detect & connect recodrding hardware
waitbar(.1, waith, 'searching for EEG hardware');
try
    daqreset
    daqinfo = daqhwinfo(REC.devName);
catch ME
    delete(waith);
    errordlg('Some unexpected error ocurred, check whether the hardware is connected correctly')
    rethrow(ME)
end
% If connection fials, reset and try again
if isempty(daqinfo.InstalledBoardIds) || length(daqinfo.InstalledBoardIds) > 1
    waitbar(0.2, waith,'Unable to connect with the hardware, trying again... ')
    try
        daqreset
        daqinfo = daqhwinfo(REC.devName);
    catch ME
        delete(waith);
        errordlg('Some unexpected error ocurred, check whether the hardware is connected correctly')
        rethrow(ME)
    end
end
% if still no device is found, or two comports are found (e.g. after changing
% USB port)
if isempty(daqinfo.InstalledBoardIds) || length(daqinfo.InstalledBoardIds) > 1
    errordlg('Still unable to connect with recording hardware, quitting this session')
    delete(waith);
    return
else
    waitbar(.3,waith,'Device found, setting up connection')
    % when hardware has been found, initiate recording session
    ai = analoginput('gmlplusdaq',daqinfo.InstalledBoardIds{1});
    waitbar(.4,waith,'Device found, setting up connection')
    % add channels to record
    for ichan = 1:length(REC.channels)
        waitbar(.4+(.5*ichan) ,waith,['adding channel ' num2str(ichan) ])
        addchannel(ai,ichan);
    end
end
% else
%     waitbar(.9,waith,'clearing possible data')
%     flushdata(ai)
% end
% handles.REC = REC;
% guidata(hObject, handles)
waitbar(1,waith,'Done!')
fprintf('Connection established with %s on comport %s \n', ...
    daqinfo.BoardNames{1}, daqinfo.InstalledBoardIds{1})
delete(waith)
% reads multi-channel recording file and save the data channel by channel
% in to a .sev file
% function function dat2sev(fname)
function dat2sev(fname)

  if(exist([fname '.sev'],'file') ~= 0)
    disp('.sev file already exists.');
    return;
  end

  startRead = 0;
  % load meta file to get the startT
  fid = fopen([fname '.meta']);
  metaInfo=textscan(fid, '%s');
  metaInfo=metaInfo{1};
  fclose(fid);
  samplRate = str2double(metaInfo(55));
  fileSize = str2double(metaInfo(26));    % bytes
  nChannelsTot = str2double(metaInfo(38));    % total N of ch

  listing = dir([fname '.dat']);
  Nsamples = listing.bytes/2/nChannelsTot;  % sec


  nChunks = 1;
  lastChunkSize = 0;
  chunkLength = round(samplRate * 60);       % load 1 min of sync pulse at the time
  if Nsamples > chunkLength
    nChunks = floor(Nsamples / chunkLength);
    lastChunkSize = floor(Nsamples - (nChunks*chunkLength));
  end

  % load .dat file and save the data of each channel into individual
  % files
  for i = 1:nChannelsTot
    fNameCh = [fname '-ch' num2str(i) '.dat'];
    fid(i) = fopen(fNameCh,'w');
  end

  for n = 1:nChunks
    disp(['segment #' num2str(n) ' (out of ' num2str(nChunks+1) ')']);
    eeg = LoadDatFile([fname '.dat'], 1:nChannelsTot, startRead, chunkLength, nChannelsTot);
    startRead = startRead + chunkLength;
    for i = 1:nChannelsTot
      fwrite(fid(i),eeg(i,:),'int16');
    end
  end
  if lastChunkSize > 0
    disp(['segment #' num2str(nChunks+1) ' (out of ' num2str(nChunks+1) ')']);
    eeg = LoadDatFile([fname '.dat'], 1:nChannelsTot, startRead, lastChunkSize, nChannelsTot);
    for i = 1:nChannelsTot
      fwrite(fid(i),eeg(i,:),'int16');
    end
  end

  for i = 1:nChannelsTot
    fclose(fid(i));
  end

  % combine all the channel files into a .sev file, the order is all the
  % data from channel 1, all the data from channel 2, and so on
  fNameNew = [fname '.sev'];
  fid = fopen(fNameNew,'w');

  for i = 1:nChannelsTot
    tmp = [];
    disp(['Save data from channels ' num2str(i)]);
    fNameCh = [fname '-ch' num2str(i) '.dat'];
    fidCh = fopen(fNameCh,'r');
    for n = 1:nChunks
      startRead = (n-1)*chunkLength*2;
      [eeg] = LoadSevFile(fidCh,startRead,chunkLength);
      %             tmp = [tmp, eeg];
      fwrite(fid,eeg,'int16');
    end
    if lastChunkSize > 0
      startRead = nChunks*chunkLength*2;
      [eeg] = LoadSevFile(fidCh,startRead,lastChunkSize);
      %             tmp = [tmp, eeg];
      fwrite(fid,eeg,'int16');
    end
    fclose(fidCh);
  end
  fclose(fid);

  % delete all the channel files
  for i = 1:nChannelsTot
    fNameCh = [fname '-ch' num2str(i) '.dat'];
    delete(fNameCh);
  end
end

% function [eeg] = LoadDatFile(filename, chID, startRead, chunkLength, nChannelsTot)
%
%   % load dat data
%   fp = fopen(filename, 'r');
%   status = fseek(fp, startRead*nChannelsTot*2, 'bof');
%
%   buffersize = 2^12;
%
%   eeg=zeros(length(chID),chunkLength);
%   N_EL=0;
%
%   while N_EL < chunkLength
%     [data,count] = fread(fp,[nChannelsTot,buffersize],'int16');
%     numelm = count/nChannelsTot;
%     if numelm>0 % Kenji modified 061009.Otherwise if numelm == 0 an error occur.
%       eeg(:,N_EL+1:N_EL+numelm) = data(chID,:);
%       N_EL = N_EL+numelm;
%     else break;
%     end
%   end
%   fclose(fp);
%
%   eeg = eeg(:,1:chunkLength);
% end

function [eeg] = LoadSevFile(fid,startRead,chunkLength)
    status = fseek(fid, startRead, 'bof');
    eeg=zeros(1,chunkLength);

    buffersize = 2^12;

    N_EL=0;
    while N_EL < chunkLength
        [data,count] = fread(fid,[1,buffersize],'int16');
        if count>0 % Kenji modified 061009.Otherwise if numelm == 0 an error occur.
            eeg(N_EL+1:N_EL+count) = data;
            N_EL = N_EL+count;
        else break;
        end
    end

    eeg = eeg(1:chunkLength);
end
% This is the name of the file.
filename = ['/home/s-zroth1/data/Eva-new-maze-2013/' ...
            'A543-20120422-01/A543-20120422-01.sev'];
chIDs      = [34, 35, 46];
sampleRate = 2e4;
nChannels  = 256;

[spw, dat, fShp, fRip] = ripdetect_sev(filename, sampleRate, nChannels, chIDs);
function objData = loadRatData(strRatName, nRecording, strCondition)
    strBaseDir = '~/data/pastalkova/';
    structParams = [];

    switch strRatName
        case 'A543'
            cellChannels = { 35, 46, 34 };
            structParams.interneurons = [49, 66, 77, 90];

            % These neurons were taken from Eva's list:
            %    left: [91, 74, 109, 125, 36, 83, 30, 123, 79, 86, 117]
            %    right: [31, 86, 11, 95, 82, 106, 109, 30, 79, 16, ...
            %            117, 108, 73, 29, 87, 116, 24, 52]
            %
            % The following list was constructed by me from the above list.
            % Neurons were duplicated if multiple place fields seemed to exist,
            % and neurons were deleted if a place field did not seem to exist.
            structParams.placeCellOrdering =  [ ...
                26, 24, 16, 22, 2, 14, 24, 28, 20, 1, 12, 13, 9, 6, 2, 8, ...
                29, 4, 6, 27, 8, 2, 28, 7, 3, 12, 19, 24, 15, 29 ...
            ]

            switch nRecording
                case 1
                    strDate = '20120412';
                case 2
                    strDate = '20120422';
                case 3
                    strDate = '20120425';
                otherwise
                    error('loadRatData: Unrecognized recording number');
            end

            switch strCondition
                case 'normal'
                    strDrugState = '01';
                case 'muscimol'
                    strDrugState = '03';
                case 'post-muscimol'
                    strDrugState = '05';
                otherwise
                    error('loadRatData: Unrecognized drug condition');
            end
        otherwise
            error('loadRatData: Unrecognized rat name');
    end

    strFile = [strRatName '-' strDate '-' strDrugState];
    strFile = [strBaseDir strFile '/' strFile];

    objData = NeuralData(strFile);
    objData.parameters = structParams;
    objData.loadChannels(cellChannels{:});
end
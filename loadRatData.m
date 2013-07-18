function objData = loadRatData(strRatName, nRecording, strCondition)
    strBaseDir = '~/data/pastalkova/';
    structParams = [];

    switch strRatName
        case 'A543'
            cellChannels = { 35, 46, 34 };
            structParams.interneurons = [49, 66, 77, 90];

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
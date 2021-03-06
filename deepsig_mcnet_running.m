imds = imageDatastore('DeepSig\','IncludeSubfolders',true,'LabelSource','foldernames','FileExtensions',{'.mat'});
[imdsTrain,imdsTest] = splitEachLabel(imds,0.8,'randomized');

imdsTrain.Labels = categorical(imdsTrain.Labels);
imdsTrain.ReadFcn = @readFcnMatFile;
 
imdsTest.Labels = categorical(imdsTest.Labels);
imdsTest.ReadFcn = @readFcnMatFile;

batchSize   = 128;
ValFre      = fix(length(imdsTrain.Files)/batchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',batchSize, ...
    'MaxEpochs',60, ...
    'Shuffle','every-epoch',...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',30,...
    'LearnRateDropFactor',0.1,...
    'ValidationData',imdsTest, ...
    'ValidationFrequency',ValFre, ...
    'ValidationPatience',Inf, ...
    'Verbose',true ,...
    'VerboseFrequency',ValFre,...
    'Plots','training-progress',...
    'ExecutionEnvironment','gpu');
trainednet = trainNetwork(imdsTrain,lgraph,options);

YPred = classify(trainednet,imdsTest,'ExecutionEnvironment','gpu');
YTest = imdsTest.Labels;
accuracy = sum(YPred == YTest)/numel(YTest);


%% Create a NN generator function

% I had previously downloaded the historical stock data from Yahoo Finance
% through a Python script and then saved the files as CSVs for use in this
% LSTM neural network generator. 'dirc' pulls up the directory
direc=dir('C:\Users\Kyle\Desktop\quantquote_daily_sp500_83986\yahoo_data\');

direcNames = {direc.name};
    %Create a matrix of all files in the directory where you are generating
    %your neural networks
    
csv_names = direcNames(contains(direcNames,'.csv')); %contain index for the NN's
    %Since the Neural Networks will also be saved in this directory,
    %establish that we will only look for the '.csv' files as those contain
    %the stock data. This is stored as a cell matrix

%% Main loop
    %The below loop iterates both through the number of different stocks we
    %are hoping to follow (indexed by 'i'), as well as the depth of DAYS we
    %wish to follow that stock for.
    
    %On this first iteration, we are using a LSTM that only takes into
    %consideration the 'opening' data of each stock. This was done to limit
    %the enormous computational time on my computer. In future iterations,
    %or for you, if you want to tinker, there is also the close, high, low,
    %etc. Information usually presented in ticker data. These could be
    %extremely useful.

for days = 1:10  %Iterating ten days of depth for the neural networks.
for i = 1:15 %Iterating through the first 15 (alphabetical) stocks
%% Step 1 import the data

ticker = csv_names{i}(1:end-4); 
    %load the text of the ticker, this will be used to open the csv file

dat = readtable(strcat('C:\Users\Kyle\Desktop\quantquote_daily_sp500_83986\yahoo_data\',ticker,'.csv'));
    %loads the data in from the CSV to a variable called 'dat'

[nrow, ncol] = size(dat); 
    %number of rows is the data entry points
    
    
openMatrix = dat.Open;
    %As previously mentioned, we are only considering ourselves with the
    %opening information of each stock, if you wished to use more, you
    %would allocate different variables for the other information and then
    %include them into the LSTM

    
if iscell(openMatrix)==1
    openMatrix = str2double(openMatrix);
    index =(isnan(openMatrix));
    openMatrix((isnan(openMatrix)))=[];
    [nrow, ncol] = size(openMatrix);
end
    %The above 'if' statement is used to fix a bug were there is missing
    %information in the open data. Sometimes there will just be a few
    %stretches of time where the stock of interest does not have any data
    %present. This removes that data. 
    
    %From the perspective of a long-term use of the neural network
    %generation for stock prediction, it would be intelligent to not simply
    %remove the data, and to look acutely at what may have happened in the
    %time when the company did not have stock data present.

%% Step 2 load the correct amount of data based on number of days for LSTM

open = zeros(days,nrow-(days+1));
returns = zeros(1,nrow-(days+1));
    %As alluded to above, the 'nrow' variable is the number of data points
    %we have. We are subtracting 'days'+1 because we want the 'N'
    %preceeding days for each neural network to be the information we are
    %training on. Returns will be the next day. We this reduces the number
    %of data points we can test on by the number of days preceeding, and
    %one more, because we have to predict the CURRENT day.


for iter = (days+1):(nrow-1)
    prev = iter-1;
    open(:,iter-days) = ((openMatrix(iter-(days-1):iter)./openMatrix(prev-(days-1):prev))-1)*100;
    returns(:,iter-days) = ((openMatrix(iter+1)./openMatrix(iter))-1)*100;
end
    %The above 'for' loop iterates through the number of days deep we want
    %our LSTM to concern itself with. 'Iter' specifically is bounded by the
    %number of days we are intersted in, plus one, so that we can later
    %subtract the number of days to properly index our variables, but still
    %pull the correct information from the "open Matrix"
    
    %additionally, it is important to note, on this iteration of the code,
    %I am using information on the PERCENT CHANGE in day-to-day market
    %openings. Using the raw value for market openings simply does not work
    %for a number of reasons. But by normalizing it to a percent change, it
    %can stay MORE consistent over time. 
    
    %I do have thoughts that larger sized companies would tend to fluctuate
    %less, but I do not have data to substantiate that. It might mean that
    %if I am tracking a companies for long time, I would want to
    %iteratively generate neural nets on them to account for both current
    %market trends as well as the change in company size.



%% Step 3 Compute the training with your NN of interest
    %For this mini project I have chosen to use the LSTM architecture
    %present in MATLAB. MOST of the below is up for change, I have found
    %that an initial learning rate of 0.01 works best, but I have yet to
    %tinker with the number of hidden units.


numFeatures = days; %Features==inputs, we are feeding the past N number of days
numResponses = 1; % of couse, you are predicting the next day percent change
numHiddenUnits = 200;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];
options = trainingOptions('adam', ...
    'MaxEpochs',1800, ...  %1800 epochs is quite a bit.
    'GradientThreshold',1, ...
    'InitialLearnRate',.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',300, ...
    'LearnRateDropFactor',0.05, ...
    'Verbose',1);

net_past3 = trainNetwork(open,returns,layers,options); %execute training

%% Step 4 save the desired NN appropriately
%Save the neural network to the directory for later testing/analysis
    %you can choose to name it how you want, I would reccomend having
    %structured naming styles--makes iterating through your NNs later, much
    %easier.
    
save(strcat('C:\Users\Kyle\Desktop\quantquote_daily_sp500_83986\yahoo_data\', ticker, 'nnlong',num2str(days),'.mat'),'net_past3')
end
end


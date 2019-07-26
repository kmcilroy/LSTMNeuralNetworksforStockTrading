%% Contemporary Performance Checker for NN's
    %Now that we have generated all the  NNs that we are interested in, we
    %need to test them. The below code is my initial attempt at validating
    %the accuracy of the individual neural networks. This approach is
    %limited in scope at the moment. It currently uses a minimum percent
    %increase threshold, and uses that to inform whether or not it should
    %invest its money in it that given day.
    
    %The next step will be to have a master Neural Net to overview the
    %miniture Neural Nets, synthesizing the predictive data into a
    %selecting process to create a stable portfolio for generating income.


money=[];
%placeholder for the 'money' variable.

%% Load the completed NN (testing right now with just index 1)

    direc=dir('C:\Users\Kyle\Desktop\quantquote_daily_sp500_83986\yahoo_data\');
    %Again, create a list of all the NN's we have created.
    
    
    direcNames = {direc.name};
    %Create a matrix of the names in the directory
    
    nn1_index = contains(direcNames,'nn1.mat'); 
    %contain index for the NN's locations in the above 
    
    
    nn1s_names=direcNames(nn1_index); 
    %a cell array that has all our nn names.
    

%% TEST on the past 10 days of trading (make predictions and then update)
    %A small note: the testing data you use is critical to how you
    %generated your LSTM. LSTMs predict the NEXT step in a sequence. For
    %maximum perfomance, try not to predict too far into the future. For
    %this example I have tested only on the next 10 days in sequence from
    %when I have generated the NNs. Be warned that this even may be too
    %much. I am testing to see the longevity of the NNs

    
%The below for loop iterates through the first 50 tickers. This was
%done to save computational time.
for ticker_name = 1:50 
    
    test = nn1s_names{ticker_name}; 
    %Pull up the NN from the directory based on loop iteration.
    
    
    ticker = test(1:(end-7)); 
    %grab the ticker name string
 
    
    %Below pulls the CSV that correlates with the generated neural network
    dat = readtable(strcat('C:\Users\Kyle\Desktop\quantquote_daily_sp500_83986\yahoo_data\',ticker,'.csv'));
    nn1 = load(strcat('C:\Users\Kyle\Desktop\quantquote_daily_sp500_83986\yahoo_data\',ticker,'nn1.mat'));
    
    open_Mat = dat.Open;
    %store the opening information. My first pass-through the data only
    %used the opening information. You would have to load additional ticker
    %properties like close/high/low/volume if you wanted to use them.
    
    if iscell(open_Mat)==1
        open_Mat = str2double(open_Mat);
        index =(isnan(open_Mat));
        open_Mat((isnan(open_Mat)))=[];
        [nrow, ncol] = size(open_Mat);
    end
    %The above 'for' loop iterates through the number of days deep we want
    %our LSTM to concern itself with. 'Iter' specifically is bounded by the
    %number of days we are intersted in, plus one, so that we can later
    %subtract the number of days to properly index our variables, but still
    %pull the correct information from the "open Matrix"
    
    %Check 'MainNeuralNetworkGenerator' for further discussion
    
    recent10 = 10*((open_Mat((end-10):end)./open_Mat((end-101):(end-1)))-1); 
    %loaded the most recent 10 days
    
    %%
    net_pred=zeros(1,5); %initialize an empty mat for predicted change
    real = zeros(1,5); %initialize an empty mat for the actual market change
    for iter = 1:5
        net_pred(iter)= predict(nn1.net_past3, recent10(iter:(iter+2)));
        real(iter) = recent10(iter+3);
    end
    % test by using the predict fcn on the loaded nn
%% Save the output OF THE PREDICTIONS+REAL RESULTS W/ DATE INFO!
money_proto =1; 
%Setting the 'money' equal to one so we can see the % change from an intial
%value of 1.  1.3 ending value would result in an overall 30% increase in
%funds from original.


cutoff=0;
%Cutoff is the minimum precent threshold until the algorithm 'bets' its
%money on the given stock it is looking at. Later this simple
%single-variable cutoff will be replaced with a sential neural network that
%monitors all subsidiary networks.



%Iterate through the predicting + money making process
for iter2 = 1:5
    if net_pred(iter2) > cutoff
        money_proto = money_proto*(1+(real(iter2)/10) );
    end
end

money = [money,money_proto];

end

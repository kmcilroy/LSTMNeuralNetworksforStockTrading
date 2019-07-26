%% Web Scraper prototype for opening values
    %In the hope of automating the entire process, this web-scraper uses
    %the Yahoo Finance page to download the daily information on 

tic 
%in the interest of optimization, ideally retrieving the information in the
%morning would take a short amount of time so we do not waste any time
%before buying stocks!

load('snp_cell_array.mat') %a matrix that contains all of the ticker info


opened_values = zeros(1,max(size(snp500)));
%allocate a zeros matrix to hold the opening data.

options = weboptions('Timeout',60);
%this is just so that Yahoo Finance cannot time my requests out.

%the below for loop retrieves the daily opening stock data and stores it in
%'opened values'
for i = 1:max(size(snp500)) 
    web_url = ['https://finance.yahoo.com/quote/' snp500{i} '/history?p=AAPL'];
    page_data = webread(web_url);
    
    before_opening_price = '</span></td><td class="Py(10px) Pstart(10px)" data-reactid="52"><span data-reactid="53">';
    after_opening_price = '</span></td><td class="Py(10px) Pstart(10px)" data-reactid="54">';
    opened_values(i) = str2double(cell2mat(extractBetween(page_data, before_opening_price, after_opening_price)));
end

toc


% a small note would be: ideally we could create a second part of this
% script to store the daily stock info into the existing csv files and just
% update them every day! Another mini project for another time
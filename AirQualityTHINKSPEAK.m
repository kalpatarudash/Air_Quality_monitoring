% This script uses the Air Quality Index (AQI) calculated
% in "particulateConcentration" to display the appropriate text associated %
with the index.
readChannelID = yourChannelID;
% TODO - Replace the [] with the Field ID to read data from: fieldID1
= 1;
% Channel Read API Key
% If your channel is private, then enter the read API %
Key between the '' below:
readAPIKey = yourChannelReadKey;
returnAQI = thingSpeakRead(readChannelID, 'Field', fieldID1,'ReadKey', readAPIKey);
[airCondition, conditionIdx] = returnairhealth(returnAQI); plotairhealth(airCondition,
conditionIdx)
%% Plot Air Health
function plotairhealth(airCondition, conditionIdx) 
vertices = [0 0; 1 0; 1 1; 0 1]; faces
= [1 2 3 4];
% Use Look Up Table and air health condition to get color for reading
faceColorPatchLUT = [0 0.83 0; 0.44 0.95 0.52; 1 0.98 0.53; 0.95 0.98 0.22; 1 0.39 0.39; 1 0 0];
faceColorPatch = faceColorPatchLUT(conditionIdx,:);
airHealthPatch = patch('Faces',faces,'Vertices',vertices,'FaceColor',faceColorPatch); hold
on
text(0.5,0.5,airCondition,'FontSize',16,'HorizontalAlignment','center') hold
off
% Remove Axis handle axHandle
= airHealthPatch.Parent;
axHandle.YTickLabel = [];
axHandle.XTickLabel = []; end
%% Air Health Condition
function [airCondition,conditionIdx] = returnairhealth(returnAQI)
airCondition = {'Good';'Moderate';'Unhealthy for Sensitive Groups';'Unhealthy';'Very
Unhealthy';'Hazardous'}; aqiLow = [0;51;101;151;201;301]; aqiHigh =
[50;100;150;200;300;500];
lutAQI = table(airCondition,aqiLow,aqiHigh,'VariableNames',{'Air_Health','AQI_low','AQI_high'});
conditionIdx = find(returnAQI >= lutAQI.AQI_low & returnAQI <= lutAQI.AQI_high);
airCondition = string(lutAQI.Air_Health(conditionIdx)); end
Code For particulate concentration-
% This script acquires data from a private ThingSpeak channel acquiring data from an NodeMcu and
sensors and uses it to calculate an Air Quality Index (AQI).
% Prior to running this MATLAB code template, assign the channel ID to read
% data from to the 'readChannelID' variable. Also, assign the field ID %
within the channel that you want to read data from to plot.
% TODO - Replace the [] with channel ID to read data from:
readChannelID = 628559;
% TODO - Replace the [] with the Field ID to read data from:
fieldID1 = 2;
% Channel Read API Key
% If your channel is private, then enter the read API %
Key between the '' below:
readAPIKey = '';
%% Read Data %%
[rawData, time] = thingSpeakRead(readChannelID, 'Field', fieldID1, 'Numminutes', 1440, 'ReadKey',
readAPIKey);
localTime = time - hours(4); % adjust for local time in Natick,MA
%% Run custom function that analyzes collected data, computes AQI and plots collected data
returnAQI = analyzeplotAQI(localTime,rawData); %% Send computed AQI to ThingSpeak
Channel (Field 1)
thingSpeakWrite(yourChannel,returnAQI,'WriteKey',yourChannelWriteKey,'Fields',1);
% CUSTOM FUNCTIONS BELOW
% Main function that smoothes collected data and calls other custom functions
function returnAQI = analyzeplotAQI(localTime,rawData)
%% Smooth data
smoothData = movmedian(rawData,10);
% Find max and plot data smoothDataMax
= max(smoothData); 
plotfun(localTime,rawData,smoothData,smoothDataMax) %
Combine smoothed data with time as # of elements are the same
smoothParticulateDataTable =
table(localTime,smoothData,'VariableNames',{'Time','Particulate_Conc'});
% Calculate AQI
pmObs = round(mean(smoothParticulateDataTable{:,2}),1); % Calculate 24 hour running average
returnAQI = calculateAQI(pmObs); end %% Plot Data
function plotfun(localTime,rawData,smoothData,smoothDataMax)
plot(localTime, rawData); hold on plot(localTime,smoothData,'-*')
% Plot max of smooth data
line(localTime,smoothDataMax * ones(length(localTime),1),'LineStyle','--')
title('2.5 micron particulate concentration \mug/m^{3}') xlabel('Time');
ylabel('Concentration \mug/m^{3}');
legend('Collected data','Smoothed data','Max of Smooth Data','Location','best')
axis tight hold off end
%% Calculate AQI function returnAQI =
calculateAQI(pmObs) % Learn about how
AQI is calcuated
% https://www.epa.gov/outdoor-air-quality-data
aqiLow = [0;51;101;151;201;301]; aqiHigh =
[50;100;150;200;300;500]; concLow =
[0;15.5;40.5;65.5;150.5;250.5]; concHigh =
[15.4;40.4;65.4;150.4;250.4;500.4];
% Create Look Up Table lutAQI =
table(aqiLow,aqiHigh,concLow,concHigh,...
 'VariableNames',{'AQI_low','AQI_high','PM_low','PM_high'});
% Find the necessary equation parameters
rowIdx = find(pmObs >= lutAQI.PM_low & pmObs <= lutAQI.PM_high);
PM_min = lutAQI.PM_low(rowIdx);
PM_max = lutAQI.PM_high(rowIdx);
AQI_min = lutAQI.AQI_low(rowIdx); AQI_max
= lutAQI.AQI_high(rowIdx);
returnAQI = round((((pmObs - PM_min) * (AQI_max - AQI_min))/(PM_max - PM_min)) +
AQI_min); end 
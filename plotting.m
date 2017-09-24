dirName=pwd;
key=strcat(dirName,'\','*.csv');
files = dir(key);

record_path=strcat(dirName,'\','record.csv');
stim_path=strcat(dirName,'\','stim.csv');

record_to_import=importdata(record_path);
record=record_to_import.data;
[numberOfRow_record numberOfColoumn_record]=size(record);
record=dlmread(record_path,';',[1 0 numberOfRow_record numberOfColoumn_record-2]);

% Normalizasyon
X = record(:, 2:end);
X = (X - mean(X(:))) / std(X(:));
record(:, 2:end) = X;

stim_to_import=importdata(stim_path);
stim=stim_to_import.data;
[numberOfRow_stim numberOfColoumn_stim]=size(stim);
stim=dlmread(stim_path,';',[1 0 numberOfRow_stim numberOfColoumn_stim-2]);



i=1;
j=1;
k=1;
inter_stop=0;
h=1;
start_indice=0;
stop_indice=0;
start=0;
stop=0;
indice=1;
numberOfsongs=10;
playing_time=120;
pause_time=10;

s=1;
indx=1;
while(s<2*numberOfsongs+1)
    songs(indx)=stim(s,2);
    indx=indx+1;
    s=s+2;
end

mod='';
parameter=2*numberOfsongs-1;

while(i<parameter)
    while(stim(i,1)>record(j,1))
        
        
        j=j+1;
    end
    start_indice=j;
    k=i+1;
    inter_stop=stim(k,1);
    h=j;
    
    while((inter_stop>record(h,1))&&(h<=numberOfRow_record-1))
        
        h=h+1;
        
    end
    stop_indice=h;
    
    if songs(indice)<6
        type='happy';
        mode='h';
    elseif ((songs(indice)>5)&&(songs(indice)<11))
        type='peaceful';
        mode='p';
    elseif ((songs(indice)>10)&&(songs(indice)<16))
        type='romantic';
        mode='r';
    elseif ((songs(indice)>15)&&(songs(indice)<21))
        type='sad';
        mode='s';
    elseif ((songs(indice)>20)&&(songs(indice)<26))
        type='tension';
        mode='t';
    end
    
    Song_Structure(indice).name=strcat(mode,int2str(songs(indice)));
    Song_Structure(indice).cat=type;
    Song_Structure(indice).eeg=record(start_indice:stop_indice,2:numberOfColoumn_record-1);
   
    indice=indice+1;
    i=i+2;

end

if songs(indice)<6
    type='happy';
    mode='h';
elseif ((songs(indice)>5)&&(songs(indice)<11))
    type='peaceful';
    mode='p';
elseif ((songs(indice)>10)&&(songs(indice)<16))
    type='romantic';
    mode='r';
elseif ((songs(indice)>15)&&(songs(indice)<21))
    type='sad';
    mode='s';
elseif ((songs(indice)>20)&&(songs(indice)<26))
    type='tension';
    mode='t';
end

Song_Structure(indice).name=strcat(mode,int2str(songs(indice)));
Song_Structure(indice).cat=type;
Song_Structure(indice).eeg=record(stop_indice:numberOfRow_record,2:numberOfColoumn_record-1);

record_to_import.colheaders(1) = [];
record_to_import.colheaders(end) = [];
for r=1:size(record_to_import.colheaders, 2)
    eval(strcat(record_to_import.colheaders{r}, '=', int2str(r)));
end

Afields = fieldnames(Song_Structure);
Acell = struct2cell(Song_Structure);
sz = size(Acell);
% Convert to a matrix
Acell = reshape(Acell, sz(1), []);      % Px(MxN)

% Make each field a column
Acell = Acell';                         % (MxN)xP

% Sort by first field "cat"
Acell = sortrows(Acell, 2);
% Put back into original cell array format
Acell = reshape(Acell', sz);

% Convert to Struct
AsortedStructOf_Songs = cell2struct(Acell, Afields, 1);
    
Fs=128;% sampling period
Ts = 1/Fs;
string1='';
string2='';
x = linspace(0,20);


ForPlotStruct(1).eeg=AsortedStructOf_Songs(1).eeg;
ForPlotStruct(1).name=AsortedStructOf_Songs(1).name;
ForPlotStruct(2).eeg=AsortedStructOf_Songs(3).eeg;
ForPlotStruct(2).name=AsortedStructOf_Songs(3).name;
ForPlotStruct(3).eeg=AsortedStructOf_Songs(5).eeg;
ForPlotStruct(3).name=AsortedStructOf_Songs(5).name;
ForPlotStruct(4).eeg=AsortedStructOf_Songs(7).eeg;
ForPlotStruct(4).name=AsortedStructOf_Songs(7).name;
ForPlotStruct(5).eeg=AsortedStructOf_Songs(9).eeg;
ForPlotStruct(5).name=AsortedStructOf_Songs(9).name;
ForPlotStruct(6).eeg=AsortedStructOf_Songs(2).eeg;
ForPlotStruct(6).name=AsortedStructOf_Songs(2).name;
ForPlotStruct(7).eeg=AsortedStructOf_Songs(4).eeg;
ForPlotStruct(7).name=AsortedStructOf_Songs(4).name;
ForPlotStruct(8).eeg=AsortedStructOf_Songs(6).eeg;
ForPlotStruct(8).name=AsortedStructOf_Songs(6).name;
ForPlotStruct(9).eeg=AsortedStructOf_Songs(8).eeg;
ForPlotStruct(9).name=AsortedStructOf_Songs(8).name;
ForPlotStruct(10).eeg=AsortedStructOf_Songs(10).eeg;
ForPlotStruct(10).name=AsortedStructOf_Songs(10).name;

tit(1).t=AF4;
tit(2).t=F7;
tit(3).t=F3;
tit(4).t=FC5;
tit(5).t=T7;
tit(6).t=P7;
tit(7).t=O1;
tit(8).t=O2;
tit(9).t=P8;
tit(10).t=T8;
tit(11).t=FC6;
tit(12).t=F4;
tit(13).t=F8;
tit(14).t=AF4;

stit(1).t='AF4';
stit(2).t='F7';
stit(3).t='F3';
stit(4).t='FC5';
stit(5).t='T7';
stit(6).t='P7';
stit(7).t='O1';
stit(8).t='O2';
stit(9).t='P8';
stit(10).t='T8';
stit(11).t='FC6';
stit(12).t='F4';
stit(13).t='F8';
stit(14).t='AF4';

for j=1:numberOfColoumn_record-2
    over_title=['Chanel -',stit(j).t];
    figure
    for id = 1:length(AsortedStructOf_Songs)
        data=ForPlotStruct(id).eeg;
        [N,nu]=size(data);%obtain size of data
        t=(1:N)*Ts;%generates time vector
        plot_title=['PWelch Spectrum (', ForPlotStruct(id).name, ')'];
        freq=(1:N)*Fs/N;%frequency vector
        [ps2,freq]=pwelch(data(:,tit(j).t),chebwin(128,100),[],N,Fs);% plotting half of the power spectrum with 50% overlap and chebwin window of length 128
        pwelch_result(id).ps=ps2;
        pwelch_result(id).freq=freq;
        [pr pc]=size(pwelch_result(id).ps);

        delta_counter=1;
        theta_counter=1;
        alpha_counter=1;
        beta_counter=1;
        gama_counter=1;        
        
        while((delta_counter<=pr)||(theta_counter<=pr)||(alpha_counter<=pr)||(beta_counter<=pr)||(gama_counter<=pr))
            while pwelch_result(id).freq(delta_counter,1)<4
                delta_counter=delta_counter+1;
            end
            pwelch_result(id).ps_delta=mean(sum(pwelch_result(id).ps(1:delta_counter,1:1)));
            theta_counter=delta_counter;
            while ((pwelch_result(id).freq(theta_counter,1)>4)&&(pwelch_result(id).freq(theta_counter,1)<8))
                theta_counter=theta_counter+1;
            end
            pwelch_result(id).ps_theta=mean(sum(pwelch_result(id).ps(delta_counter:theta_counter,1:1)));
            alpha_counter=theta_counter;
            while ((pwelch_result(id).freq(alpha_counter,1)>8)&&(pwelch_result(id).freq(alpha_counter,1)<12))
                alpha_counter=alpha_counter+1;
            end
            pwelch_result(id).ps_alpha=mean(sum(pwelch_result(id).ps(theta_counter:alpha_counter,1:1)));
            beta_counter=alpha_counter;
            while ((pwelch_result(id).freq(beta_counter,1)>12)&&(pwelch_result(id).freq(beta_counter,1)<16))
                beta_counter=beta_counter+1;
            end
            pwelch_result(id).ps_beta=mean(sum(pwelch_result(id).ps(alpha_counter:beta_counter,1:1)));
            gama_counter=beta_counter;
            while ((pwelch_result(id).freq(gama_counter,1)>16)&&(pwelch_result(id).freq(gama_counter,1)<20))
                gama_counter=gama_counter+1;
            end
            pwelch_result(id).ps_gama=mean(sum(pwelch_result(id).ps(beta_counter:gama_counter,1:1)));
            %counter=counter+1;
        end

        
        subplot(2,5,id);
        plot(pwelch_result(id).freq,pwelch_result(id).ps);
        title(plot_title);
        
    end
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 1,over_title,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
    Pwelch_result(j).p=pwelch_result;
end













% addpath('C:\Users\U66300\toolbox\CircStat2012a\');
% % addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
% addpath(genpath(pwd));
% % ft_defaults;

clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,~,Phase_st,POS_st]=Default_input_values('group');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');

Nfreq=length(Phase_st.FOI);
Nel=length(Phase_st.labels);
% Perform stats
mean_POS=zeros(Nfreq,Nel);
mean_null_POS=zeros(POS_st.Null_pos,Nfreq,Nel);
nPOS=zeros(length(Names_Test),POS_st.Null_pos,Nfreq,Nel);
for pnum=1:size(Names_Test,2)
   
   load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.output_file '_with_peak.mat']),'pos_val');
   mean_POS=mean_POS+pos_val;
   load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.null_output_file '_with_peak.mat']),'null_pos');
   mean_null_POS=mean_null_POS+null_pos;
  % nPOS(pnum,:,:,:)=null_pos;
end

mean_POS=mean_POS/size(Names_Test,2);
mean_null_POS=mean_null_POS/size(Names_Test,2);
test_matrix=[];
test_matrix(1,:,:)=mean_POS;
compare=mean_null_POS-repmat(test_matrix,POS_st.Null_pos,1,1);

compare=(compare>0);
pvalue=squeeze(mean(compare,1));
% pvalue=zeros(size(nPOS,3),size(nPOS,4));
% for i=1:1e6
%    s=randsample(1e4,size(Names_Test,2),true);
%    tmp=zeros(size(nPOS,3),size(nPOS,4));
%    for j=1:size(Names_Test,2)
%    tmp=tmp+squeeze(nPOS(j,s(j),:,:));
%    end
%    tmp=tmp/size(Names_Test,2);
%    pvalue=pvalue+(tmp>mean_POS);
% end
% 
% pvalue=pvalue/1e6;

[~ ,~ ,adjusted_pvalue]=fdr_bh(pvalue,0.05,'pdep','yes');
%%

% load('C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\04_Cortex_Analysis\Phase\Dataset_1\group_stats_pos.mat')
% load('C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\04_Cortex_Analysis\Phase\Dataset_1\group_pos.mat')


pos_data=[];
pos_data.label=Phase_st.labels;
pos_data.dimord='chan_freq';
pos_data.freq=Phase_st.FOI;
pos_data.powspctrm=mean_POS';
pos_data.stat=pvalue';
cfg=[];
cfg.layout=Phase_st.layout;
cfg.parameter='powspctrm';
cfg.style='straight';
cfg.marker='off';
cfg.highlight='on';
cfg.highlightsymbol='*';
for foi=1:length(pos_data.freq)
    subplot(3,4,foi)
     cfg.comment=' ';%['f=' num2str(pos_data.freq(foi)) ' Hz'];
    cfg.highlightchannel=Phase_st.labels((pvalue(foi,:)<=0.05));
    cfg.highlightcolor=[0 0 0];
    cfg.xlim=[pos_data.freq(foi) pos_data.freq(foi)];
    cfg.zlim=[0 0.04];
    ft_topoplotTFR(cfg,pos_data);
    
end





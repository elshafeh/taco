clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

fOUT    = ['../txt/' ext_mat 'ariance.HemiByModByFreq.Early.IAF4Paper.txt'];
fid     = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','MODALITY','HEMI','VAL');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   ['CnD.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
    fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('\nLoading %50s \n',fname_in); load(fname_in); freq        = rmfield(freq,'hidden_trialinfo');
    
    nw_chn              = [1 1;2 2;3 5; 4 6];
    nw_lst              = {'occ.L','occ.R','aud.L','aud.R'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.appenddim       = 'chan';
    freq                = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    cfg                 = [];
    cfg.frequency       = [5 15];
    cfg.latency         = [0.2 0.6];
    %     cfg.avgovertime     = 'yes';
    freq                = ft_selectdata(cfg,freq);
    
    for chn = 1:length(freq.label)
        
        data        = squeeze(freq.powspctrm(chn,:,:));
        [val,y]     = find(data == min(min(data)));
        iaf         = round(freq.freq(val));
        
        %             if chn < 3;
        %                 val = find(data == max(data));
        %             else
        %             end
        %         else
        %             data = squeeze(freq.powspctrm(chn,:,:));
        %             if chn < 3;
        %                 [x,y] = find(data == max(max(data)));
        %             else
        %                 [x,y] = find(data == min(min(data)));
        %             end
        %             iaf     = round(freq.freq(x));
        %             lat     = round(freq.time(y),2);
        
        x       = strsplit(freq.label{chn},'.');
        fprintf(fid,'%s\t%s\t%s\t%.2f\n',suj,x{1},x{2},iaf); clear iaf x;
        
    end
end

fclose(fid);
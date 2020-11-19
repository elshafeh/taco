clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_list        = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    lst_cnd     = {'CnD','LCnD','RCnD','NCnD'};
    
    lst_mth     = {'PLV'};
    lst_chn     = {'aud_R'};
    lst_tme     = {'m1000m200','p200p1000'};
    %     lst_tme     = {'m600m200','p600p1000'};

    
    for ncue = 1:length(lst_cnd)
        for nmethod = 1:length(lst_mth)
            for ntime = 1:length(lst_tme)
                for nchan = 1:length(lst_chn)
                    
                    fname   = ['../../PAT_MEG21/pat.field/data/' suj '.' lst_cnd{ncue} '.prep21.' lst_tme{ntime} '.' lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    tmp{nchan}.powspctrm(1,:,:)                 = seymour_pac.mpac_norm;
                    tmp{nchan}.freq                             = seymour_pac.amp_freq_vec;
                    tmp{nchan}.time                             = seymour_pac.pha_freq_vec;
                    tmp{nchan}.label                            = lst_chn(nchan);
                    tmp{nchan}.dimord                           = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                end
                
                if nchan == 1
                    allsuj_data{sb,ncue,nmethod,ntime} = tmp{1};
                else
                    cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                    allsuj_data{sb,ncue,nmethod,ntime} = ft_appendfreq(cfg,tmp{:});
                end
                
                clear data
                
            end
        end
    end
end

clearvars -except allsuj_data lst_* ; clc ;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;


cfg                     = [];

% cfg.latency             = [7 12];
% cfg.frequency           = [50 100];

cfg.dim                 = allsuj_data{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';
cfg.correctm            = 'fdr';
cfg.computecritval      = 'yes';
cfg.numrandomization    = 1000;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

for ncue = 1:size(allsuj_data,2)
    for nmethod = 1:size(allsuj_data,3)
        
        stat{ncue,nmethod}         = ft_freqstatistics(cfg,allsuj_data{:,ncue,nmethod,2}, allsuj_data{:,ncue,nmethod,1});
        
    end
end

for ncue = 1:size(allsuj_data,2)
    for nmethod = 1:size(allsuj_data,3)
        [min_p(ncue,nmethod),p_val{ncue,nmethod}] = h_pValSort(stat{ncue,nmethod});
    end
end

close all;

figure;
i = 0 ;

for ncue = 1:size(stat,1)
    for nmethod = 1:size(stat,2)
        for nchan = 1:length(stat{ncue,nmethod}.label)
            
            i = i + 1;
            
            p_limit                         = 0.11;
            
            stat{ncue,nmethod}.mask         = stat{ncue,nmethod}.prob < p_limit;
            
            subplot(size(stat,1),length(stat{ncue,nmethod}.label),i)
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.colorbar                    = 'no';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.zlim                        = [-2 2];
            
            ft_singleplotTFR(cfg,stat{ncue,nmethod});
            
            title([stat{ncue,nmethod}.label{nchan} '.' lst_cnd{ncue}]);
            
            xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
        end
    end
end

clear ; clc ;

load(['../data/template/template_grid_0.5cm.mat']);

brainnetome                 = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii');
brainnetome.tissuelabel     = brainnetome.tissuelabel';

template_grid               = ft_convert_units(template_grid,brainnetome.unit);

source                      = [];
source.pos                  = template_grid.pos ;
source.dim                  = template_grid.dim ;
source.pow                  = nan(length(source.pos),1);

cfg                         = [];
cfg.interpmethod            = 'nearest'; % 'nearest', 'linear', 'cubic',  'spline', 'sphere_avg' or 'smudge'
cfg.parameter               = 'tissue';
source_atlas                = ft_sourceinterpolate(cfg, brainnetome, source);

roi_interest                = [1:102 121:162 176:210];

index_vox                   = [];

for d = 1:length(roi_interest)
    
    x                       =   find(ismember(brainnetome.tissuelabel,brainnetome.tissuelabel{roi_interest(d)}));
    indxH                   =   find(source_atlas.tissue==x);
    index_vox               =   [index_vox ; indxH repmat(d,size(indxH,1),1)];
    clear indxH x

    index_name{d}           = brainnetome.tissuelabel{roi_interest(d)};
    
    clear indxH x
    
end

keep index_*

save ../data/template/com_btomeroi_select.mat
function behav_in_recoded = recode_detect_pos(behav_in)


behav_in(behav_in(:,2) == 253,:) = [];
behav_in(behav_in(:,2) == 255,:) = [];
behav_in(behav_in(:,2) == 90,:) = [];
behav_in(behav_in(:,2) == 91,:) = [];
behav_in(behav_in(:,2) == 10,:) = [];

behav_in_recoded = behav_in;

for x=1:length(behav_in)     

    if (behav_in(x,3) >= 1 && behav_in(x,3) <= 34) || (behav_in(x,3) >= 101 && behav_in(x,3) <= 234)
        
        behav_in_recoded(x,3)   =   1000+behav_in_recoded(x,3);
        behav_in_recoded(x,4)   =   behav_in_recoded(x,4)+delay_trigcue;
    
    elseif behav_in(x,3) >= 51 && behav_in(x,3) <= 53   
        
        codB                    =   behav_in(x,3)-50;
        behav_in_recoded(x,3)   =   2000+codB;
        behav_in_recoded(x,4)   =   behav_in_recoded(x,4)+delay_trigsound;
        
    elseif behav_in(x,3) >= 61 && behav_in(x,3) <= 64  
        
        codB                    =   behav_in(x,3)-60;
        behav_in_recoded(x,3)   =   3000+codB;
        behav_in_recoded(x,4)   =   behav_in_recoded(x,4)+delay_trigsound;
        
    elseif behav_in(x,3) == 251   ||   behav_in(x,3) == 252 
        
        codB                    =   behav_in(x,3)-250;
        behav_in_recoded(x,3)   =   9000+codB;
        
    end
    
    clear codB
    
end
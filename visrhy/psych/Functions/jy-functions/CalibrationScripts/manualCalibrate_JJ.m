%%%% Present uniform screen colors for manual calibration% Present red, green and blue in either ascending or descending voltage levels% evenly spaced between 0 and 255.% Press any key to advance to next color%% Created by frank tong, 2000/10/25% Modified as manualCalibrate2.m on 2002/01/07, modified for osX on 7/24/7% by JJclear all close allScreen('CloseAll'); global wptr dacsize scrnumscrnum = 1;dacsize = 8;addpath(pwd)% expdir = [pwd '/Calibration'];  	% experiment directory: function ExperimentPath specifies directory 'Experiments:'% cd(expdir); 						% change to experimental directory% calibrationFile = ['calib_' date '.mat'];calibrationFile = 'calib_20181107_BehLab1_Frida';nlevels = input('How many levels of each gun would you like to present? (press "enter" for default colors)   '); %8 is usually enoughif isempty(nlevels) || ~nlevels	color = [ 255 0 0; 0 255 0; 0 0 255;  255 255 255;  0 0 0];	nlevels = size(color,1);else	query = input('(a)scending or (d)escending luminance levels?   (default = ascending)   ', 's');		temp = [round(linspace(0,255,nlevels+1))]';	temp(1) = [];			% remove 0 as entry	if isempty(query)	elseif query == 'd' || 'D'		temp = flipud(temp);	end	color = zeros(nlevels*3,3);	color(1:nlevels,1) = temp;	color(nlevels+1:nlevels*2,2) = temp;	color(nlevels*2+1: nlevels*3,3) = temp;	color(size(color,1)+1,:) = [255,255,255];	color(size(color,1)+1,:) = [0,0,0];		query = input('Apply gamma correction? (y or n [default])  ', 's');	if ~isempty(query) & query == 'y' | ~isempty(query) & query == 'Y'% 		LoadCalibrationFile;			% script loads calibrationNameFile & variables in calibrationFile        err=0;		eval(['load ' calibrationFile ' gamInverse dacsize'],'err = 1');		% load gamInverse & dacsize from CalibrationFile        if err ==1            error('calibrationfile not loaded')        end        color = map2map(color/255,gamInverse);	% gamma correct the colors	else		gamInverse = [0:255;0:255;0:255]';	end	color = round(color);endHideCursor; %%DEBUGFlushEvents('KeyDown');scrnum = 0;[wptr,rect] = Screen('OpenWindow',1, 0);hardwareclut=Screen('LoadCLUT', wptr);Screen('Flip', wptr);for n = 1:size(color,1)		%uniformScreen(color(n,:)); 	% function draws a uniform screen		%of specified color         Screen('FillRect', wptr, color(n,:), rect);        Screen('Flip', wptr);        KbWait(-3,2);%		GetCharendScreen('LoadCLUT', wptr, hardwareclut);	Screen('CloseAll');ShowCursor;
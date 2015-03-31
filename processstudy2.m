function argout = processstudy()
% 
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 59 Temple
% Place - Suite 330, Boston, MA  02111-1307, USA.

%declare file data
% list directories
% 'C:\\study2\\subject2001\\',
%fpa = {'C:\\study2\\subject3001\\','C:\\study2\\subject5001\\','C:\\study2\\subject6001\\','C:\\study2\\subject7001\\','C:\\study2\\subject8001\\'};
fpa = {'C:\\study2\\subject3001\\'};
% list files and cc
fa = {
   % {{'subject2S001R02',''},{'subject2S001R04',''},{'subject2S001R05',''},{'subject2S001R06',''},{'subject2S001R09',''},{'subject2S001R10',''}},
   % R02 wouldn't run!?!
    {{'subject3S001R02',''}}
   % {{'subject5S001R02',''},{'subject5S001R03',''},{'subject5S001R04',''},{'subject5S001R05',''},{'subject5S001R08',''},{'subject5S001R09',''}},
    %{{'subject6S001R02',''},{'subject6S001R03',''},{'subject6S001R04',''},{'subject6S001R05',''},{'subject6S001R08',''},{'subject6S001R09',''}},
    %{{'subject7S001R02',''},{'subject7S001R03',''},{'subject7S001R04',''},{'subject7S001R05',''},{'subject7S001R08',''},{'subject7S001R09',''}},
    %{{'subject8S001R02',''},{'subject8S001R04',''},{'subject8S001R05',''},{'subject8S001R06',''},{'subject8S001R09',''},{'subject8S001R10',''}}
       %{{'nfaS019R01',''},{'nfaS019R02',''},{'nfaS019R03',''},{'nfaS019R04',''},{'nfaS019R06','{0,7,5,3,1,7,5,8,2,4,4}'},{'nfaS019R07',''},{'nfaS019R10',''}}
    };








addpath('C:\Program Files\MATLAB\R2011b\toolbox\signal\signal');
addpath('C:\Program Files\MATLAB\R2011b\toolbox\stats\stats');

addpath('C:\eeglab\eeglab_13_2\eeglab13_2_2b');
cd C:\eeglab\eeglab_13_2\eeglab13_2_2b
%eeglab
%pause(10);
cd plugins\bCI2000import0.35
fp = 'C:\\study2\\subject3001\\';
fp_out = 'C:\\study2\\processed\\';
fn = 'subject3S001R02';
cc = '{0,5,2,8,9,7,6,1,3}';





% loop over files and folders

for s = 1:length(fpa)
    for t = 1:length(fa{s})
        
        fp = fpa{s};
        fn = fa{s}{t}{1};
        % cc = fa{s}{t}{2};
        


        if ~isempty(fn)    

            %copyfile([fp fn '.dat'],[fp fn '_orig.dat']); %since runica
            %was deleting the dat file when saving to the same directory,
            %no longer needed since common output
            z1 = pop_loadBCI2000([fp fn '.dat']);
            z1 = pop_chanedit(z1, 'lookup','c:\\eeglab\\eeglab_13_2\\eeglab13_2_2b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
            z1 = pop_runica(z1, 'extended',1,'interupt','on');
            z1 = pop_selectevent( z1, 'type',{'SelectedColumn' 'SelectedRow' 'SelectedTarget' 'SpellerMenu' 'StimulusBegin' 'StimulusCode' 'StimulusCodeRes' 'StimulusType' 'StimulusTypeRes'},'deleteevents','on');
            z2 = pop_saveset( z1, 'filename',[fn '.set'],'filepath',fp_out);

            % from epoched data (on unfiltered stimulus begins) delete all epochs that
            % have a target event in them
            z2 = pop_epoch( z2, {  'StimulusBegin'  }, [0         0.8], 'newname', 'Imported BCI2000 data set epochs', 'epochinfo', 'yes');

            z2 = pop_selectevent( z2, 'StimulusType',1,'deleteevents','off','deleteepochs','on','invertepochs','on');
            % remove baseline
            z2 = pop_rmbase( z2, [0      789.0625]);

            z3 = pop_saveset( z2, 'filename',[fn '_nontargets.set'],'filepath',fp_out);

            % from continuous data, get rid of all events that are not target events
            % (ideally would be get rid of all data that are not alone in an epoch, but
            % we'll let those slide for the moment)
            z3 = pop_selectevent( z1, 'type',{'StimulusBegin'},'StimulusType',1,'deleteevents','on');

            % now epoch on those target events (again, would like to do sliding window
            % to grab only clean epochs, or go back through and throw away epochs with
            % more than one target)
            z3 = pop_epoch( z3, {  'StimulusBegin'  }, [0         0.8], 'newname', 'Imported BCI2000 data set_ones epochs', 'epochinfo', 'yes');

            % remove baseline
            z3 = pop_rmbase( z3, [0      789.0625]);

            z3 = pop_saveset( z3, 'filename',[fn '_targets.set'],'filepath',fp_out);

        end

    end
end

argout = 1;
return;
end

function [files] = grabFiles(inv_folder_name, iteration_no)
 
% Inputs:
%   inv_folder_name = folder name, where inversion results are stored
%   iteration no    = final number of iteration that needs to be plotted
% Outputs:
%   files           = a structure with inverted file directories

talapas_dir_home     = '/Users/asifashraf/Talapas/';
talapas_dir_cluster  = '/gpfs/projects/proteus/aashraf/srInput/';

addpath '/Users/asifashraf/Talapas/srInput';

glob_dir    = append(talapas_dir_home, 'tlOutput/', inv_folder_name);
addpath (glob_dir)

theControl  = append(glob_dir, '/tlControl.mat');
load(theControl)

files.theintModel = which(tlControl.files.Model((length(talapas_dir_cluster)+1):end));
files.theinvModel = which(append('srModel_it', num2str(iteration_no), '.mat'));
files.theArrival  = which(tlControl.files.Arrival((length(talapas_dir_cluster)+1):end));
files.theStation  = which(tlControl.files.Station((length(talapas_dir_cluster)+1):end));
files.theEvent    = which(tlControl.files.Event((length(talapas_dir_cluster)+1):end));
files.theGeometry = which(tlControl.files.Geometry((length(talapas_dir_cluster)+1):end));

% tlPert
file_type  = 'tlPert';
file       = append('/',file_type, '*.mat');
tlPert_dir = dir(append(glob_dir, file));
files.thePert        = append(tlPert_dir(iteration_no).folder, '/', tlPert_dir(iteration_no).name);

% srOutput
files.srOutputFolder = append(talapas_dir_home, 'srOutput/', inv_folder_name, '/');

end
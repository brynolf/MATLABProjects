%%baseline
 Baseline1 = AnalyseACR('C:\Users\maad0044.AD\Documents\MATLAB\ACR_standalone\Baseline_1');
 
 %% convert cell to .mat
 
 Baseline11 =cell2mat(Baseline1);
   
 %% changing Number of excitations
 
 Nex05 = AnalyseACR('C:\Users\maad0044.AD\Documents\MATLAB\ACR_standalone\Nex0.5_1');
 
 Nex05_1 =cell2mat(Nex05);
 
 Nex075 = AnalyseACR('C:\Users\maad0044.AD\Documents\MATLAB\ACR_standalone\Nex0.75_1');
 
 Nex075_1 =cell2mat(Nex075);
 
 Nex2 = AnalyseACR('C:\Users\maad0044.AD\Documents\MATLAB\ACR_standalone\Nex2_1');
 
 Nex2_1 =cell2mat(Nex2);
 
 %% Varying bandwidth
 
 Bw1 = AnalyseACR('C:\Users\maad0044.AD\Documents\MATLAB\ACR_standalone\BW1_1');
 
 Bw1_1 = cell2mat(Bw1);
 
 Bw8_33 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\8.33 kHz');
 Bw8_33 =cell2mat(Bw8_33);
 

 Bw16 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\16.67 kHz');
 Bw16 = cell2mat(Bw16);
 
 
 Bw25 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\25 kHz');
 Bw25 = cell2mat(Bw25);
 
 
 Bw31 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\Baseline_31.25');
 Bw31 = cell2mat(Bw31); 
 

 Bw41 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\41.67 kHz');
 Bw41  = cell2mat(Bw41 );
 
  
 
 Bw50 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\50 kHz');
 Bw50  = cell2mat(Bw50 );
 
  
 Bw62 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\62.50 kHz');
 Bw62  = cell2mat(Bw62 );
 
 %%
 Bw83 = AnalyseACR('C:\Users\maad0044.AD\Documents\Project 3\Scans\ACR Phantom scan\20180828\Bandwidth\83.3 kHz');
 Bw83 = cell2mat(Bw83 );
 
 
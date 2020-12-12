% createInfoStruct.m
%
% Create a struct to store information about each experiment
% (experiment name, csv name, plot color) and trigger user input prompt
% to determine which experiments to plot
%
function info = createInfoStruct()
    
    % Create struct with fields name, csvName, and color
    info = struct('name', NaN, 'csvName', NaN, 'color', NaN);
    
    % Replicate struct making it 1x3
    info = repmat(info, 1, 3);
    
    % Fill in info for each experiment
    info(1).name = 'Pitch';
    info(1).csvName = 'Face Pitch Rotation RT';
    info(1).color = [0 0.8 0.8];

    info(2).name = 'Yaw';
    info(2).csvName = 'Face Yaw Rotation RT';
    info(2).color = [0.86 0.27 0.07];

    info(3).name = 'Roll';
    info(3).csvName = 'Face Roll Rotation RT';
    info(3).color = [1 0.6 0];
    
    % ButtonUI function prompts the user with a checklist where they can
    % select which protocols to include in the analysis
    global CHECKBOXES;
    ButtonUI(info);
    info(1).include = CHECKBOXES(1);
    info(2).include = CHECKBOXES(2);
    info(3).include = CHECKBOXES(3);
end
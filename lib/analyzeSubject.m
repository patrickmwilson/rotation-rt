function analyzeSubject(subject)

    linearGraph = figure();

    info = struct('name', 'Pitch', ...
        'csvName', 'Face Pitch Rotation RT', 'color', [0 0.8 0.8]);

    info = repmat(info, 1, 3);

    info(2).name = 'Yaw';
    info(2).csvName = 'Face Yaw Rotation RT';
    info(2).color = [0.86 0.27 0.07];

    info(3).name = 'Roll';
    info(3).csvName = 'Face Roll Rotation RT';
    info(3).color = [1 0.6 0];
    
    
end
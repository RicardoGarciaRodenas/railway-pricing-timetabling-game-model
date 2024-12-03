function listFunctionDependencies(funcName)
    % listFunctionDependencies: Lists the functions used by a given MATLAB function.
    %
    % INPUT:
    %   funcName - (string) Name of the MATLAB function to analyze (include path if needed).
    %
    % OUTPUT:
    %   Displays a list of functions required by the specified function.
    %
    % Example:
    %   listFunctionDependencies('myFunction');
    
    if nargin < 1
        error('Please provide the name of the function to analyze.');
    end

    % Check if the file exists
    if ~exist(funcName, 'file')
        error('The specified function "%s" does not exist in the MATLAB path.', funcName);
    end

    % Get the list of required files and dependencies
    [requiredFiles, requiredProducts] = matlab.codetools.requiredFilesAndProducts(funcName);

    % Display the results
    fprintf('List of functions used by "%s":\n', funcName);
    fprintf('---------------------------------------\n');
    for i = 1:length(requiredFiles)
        fprintf('%d. %s\n', i, requiredFiles{i});
    end

    fprintf('\nProducts required by "%s":\n', funcName);
    fprintf('---------------------------------------\n');
    for i = 1:length(requiredProducts)
        fprintf('%d. %s\n', i, requiredProducts(i).Name);
    end
end
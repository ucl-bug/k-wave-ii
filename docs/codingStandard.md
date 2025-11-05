# Coding Standard

MATLAB coding standard used for k\-Wave II.

## Naming

-  Namespaces uses `+lowercase`. 
-  Class names use `TitleCase`. 
-  Function names and script filenames use `camelCase`. 
-  Test classes use `TestMyClassName` or `TestMyFunctionName`. 
-  Variables use `camelCase`. 
-  Name\-Value arguments use `TitleCase`. 
-  Descriptive naming should be used for the user\-facing API where possible, e.g., `soundSpeed` rather than `c`. Break this rule for internal variables for commonly used symbols (e.g. `c` for sound speed,  `p` for pressure), as long as the symbol is well known and stays within a limited scope (e.g., a function) where a short comment at the top says what the single letter stands for.

## Code

-  Each line of code should only contain one statement. 
-  Each line of executed code should be terminated with a semicolon without a preceding space. 
-  Class properties and argument validation code should not be terminated with a semicolon. 
-  For element\-wise multiply, divide, and power operations, use a preceding period, even when acting on a scalar. 
-  Always use a period before the transpose operator, unless the conjugate transpose is required. 
-  Mathematical operands and assignments, e.g., `+ * && = >` etc., should be space padded. Exceptions are power `^`, the colon operator `:`, the not operator `~`, and the `-` sign when used to signify a negative number. 
```matlab
x = 1:10;
x = a .* b.^2;
x = a && ~b;
x = 10 - 3.4;
x = -1e-3;
x = [1, 2, 3].';
```

-  Break the previous two rules if it helps readability for simple multiply and divide operations using scalar literals. 
```matlab
x = 2*pi;
x = 1/pi;
```

-  Decimals should have a preceding zero. 
-  Always preceed the imaginary unit with a number, e.g., `1i`. 
```matlab
x = 0.5 + 1i;
```

-  Align multiple similar lines of code if it makes sense for readability (similarly for comments). 
```matlab
windSpeed        = exp( x -   w .* t);
waterTemperature = exp(-x - 3*w .* t);
```

-  If long lines of code become difficult to read, then break lines of code using `...` and align for readability.

## Brackets and Commas

-  Brackets should have no interior spaces. Break this rule if needed for readability when using multiple nested brackets. 
-  Brackets should follow immediately after function names with no space. 
-  Commas should be used to separate multiple inputs, outputs, or matrix values. 
-  All commas should be followed by a space. 
```matlab
x = (a - b).^2;
[a, b, c] = myFunc(x, y, z);
x = [1, 2, 3];
x = [1; 2; 3];
```

-  Logical statements should be grouped using brackets 
```matlab
if (myHeight > 10) && (myDog.Name == "Fido")
    disp('Excellent.');
end
```

## Code Comments

-  All code comments should be written as sentences, including capitals and periods. 
-  Comments should be limited to a maximum column width of 75 characters (the default in MATLAB). 
-  Comments that span multiple lines should be aligned at the first character of each line. 
-  Code comments should appear on the previous line, rather than inline. Break this rule with common sense. 
-  Comments should be preceded by a blank line.

## Indentation and Line Breaks

-  Statements inside conditional loops and if\-statements (etc) should be indented. 
-  Each code indent level should be 4 spaces. 
-  Include a blank line at the beginning and end of the conditional IFF the code on the inside contains a comment. 
-  All files should end with a blank new line. 
-  Trailing spaces after lines of code or comments should be removed. 
```matlab
% Increment the counter if radius exceed maximum value. There are no
% comments inside the if statement, so do not include additional line
% breaks.
if radius > maximumRadius
    counter = counter + 1;
end

% Loop through possible heights and calculate weight. There are comments
% inside the if state, so include additional line breaks.
for index = 1:length(heightArray)
    
    % Assign current height.
    height = heightArray(index);
    
    % Calculate current weight based on time of day.
    weight(index) = height .* now;
    
end
```

## Error messages

-  Error messages should use the `kwave.toolbox.Logger` class. 
-  Error messages should begin with a capital letter (except when using a variable or function name) and end with a period. 
-  Error messages should use a two part identifier in the form  `ClassName:errorIdentifier` or  `functionName:errorIdentifier`. 
```matlab
kwave.toolbox.Logger.error('Grid:incorrectInputSize', 'gridSpacing must be a scalar or the same length as gridSize.');
```

## Class and Function Documentation

Classes should be written using [methods in separate files](https://uk.mathworks.com/help/matlab/matlab_oop/methods-in-separate-files.html). Class and function documentation should be written using [publishing markup](https://uk.mathworks.com/help/matlab/matlab_prog/marking-up-matlab-comments-for-publishing.html) following [the template](helpfilesweb/classDocsExample.md). The following structure and headings should be used (to open the template in the MATLAB Editor, `edit('kwave.docfiles.general.classDocsExample')`).

-  functionName or className 
-  Syntax 
-  Description 
-  Examples 
-  Input Arguments 
-  Name\-Value Arguments 
-  Output Arguments 
-  Properties (classes only) 
-  Methods (classes only) 
-  See Also 

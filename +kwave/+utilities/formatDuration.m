%% formatDuration
% Package: kwave.utilities
%
% Format calendarDuration object into string containing hours, minutes, and
% seconds.
%
%% Syntax
% formattedDuration = formatDuration(elapsedTime);
%
%% Description
% The formatDuration function takes a <matlab:doc('duration') duration> or
% <matlab:doc('calendarDuration') calendarDuration> object as input and
% outputs a formatted string representing the duration. The output string
% is composed of hours (if non-zero), minutes (if non-zero), and seconds,
% each followed by the respective unit label (h, m, s). This function is
% particularly useful for displaying human-readable durations in contexts
% such as performance measurement and event timing.
%
%% Examples
%   elapsedTime = hours(1) + minutes(23) + seconds(45);
%   formattedDuration = kwave.utilities.formatDuration(elapsedTime);
%   disp(formattedDuration);
%
%   1h 23m 45s
%
%% Input Arguments
% * |elapsedTime| - (duration) The duration to be formatted.
%
%% Output Arguments
% * |formattedDuration| - (string) A formatted string representing the
%   duration. The string includes hours (if non-zero), minutes (if
%   non-zero), and seconds, each followed by the respective unit label
%   (h, m, s).
%
%% See Also
% * <matlab:doc('duration') duration>
% * <matlab:doc('duration') calendarDuration>
% * <matlab:doc('hours') hours>
% * <matlab:doc('minutes') minutes>
% * <matlab:doc('seconds') seconds>

function formattedDuration = formatDuration(elapsedTime)

    arguments
        elapsedTime (1,1)
    end

    if isa(elapsedTime, 'calendarDuration')
        elapsedTime = time(elapsedTime);
    elseif ~isa(elapsedTime, 'duration')
        kwave.toolbox.Logger('Input must be of class duration or calendarDuration.');
    end

    [H, M, S] = hms(elapsedTime);
    
    formattedDuration = [num2str(S) 's'];
    if (M ~= 0)
        formattedDuration = [num2str(M) 'm ' formattedDuration];
    end
    if (H ~= 0)
        formattedDuration = [num2str(H) 'h ' formattedDuration];
    end
    
end

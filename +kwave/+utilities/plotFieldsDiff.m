%% Plot Fields Diff
% *Package:* kwave.utilities
%
% Plots two fields and the difference between them.
%
%% Syntax
%   f = plotFieldsDiff(referenceField, comparisonField)
%
%% Description
% |plotFieldsDiff| takes two fields and plots them, along with the
% different between them. The fields must be the same size, and can be in
% 1D to 4D. In 3D, the central slice in each Cartesian direction is
% plotted. If the input is 4D, the function is recursively called with 3D
% inputs.
%
%% Input Arguments
% * |referenceField| - (numeric) Reference field.
% * |comparisonField| - (numeric) Comparison field.
%
%% Output Arguments
% * |f| - (matlab.ui.Figure) Figure handle for generated figure.

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

function f = plotFieldsDiff(actual, expected, plotTitle)

arguments
    actual (:,:,:,:) {mustBeNumeric}
    expected {mustBeNumeric, kwave.utilities.mustBeEqualSize(expected, actual)}
    plotTitle {mustBeTextScalar} = ''
end

% If input is 4D, make recursive call with each component.
if size(actual, 4) > 1
    for ind = 1:size(actual, 4)
        f = kwave.utilities.plotFieldsDiff(actual(:, :, :, ind), expected(:, :, :, ind));
        return
    end
end

diff = actual - expected;

f = figure;

if isvector(actual)

    subplot(2, 1, 1);
    plot(actual);
    hold on;
    plot(expected, '--');
    legend('actual', 'expected');
    title('Fields');

    subplot(2, 1, 2);
    plot(diff);
    title('Difference');

elseif ismatrix(actual)

    subplot(1, 3, 1);
    imagesc(actual);
    colorbar;
    axis image;
    title('Actual')

    subplot(1, 3, 2);
    imagesc(expected);
    colorbar;
    axis image;
    title('Expected');

    subplot(1, 3, 3);
    imagesc(diff);
    colorbar;
    axis image;
    title('Difference');

else

    subplot(3, 3, 1);
    imagesc(actual(:, :, round(end/2)));
    colorbar;
    axis image;
    title('Actual x-y')

    subplot(3, 3, 2);
    imagesc(expected(:, :, round(end/2)));
    colorbar;
    axis image;
    title('Expected x-y');

    subplot(3, 3, 3);
    imagesc(diff(:, :, round(end/2)));
    colorbar;
    axis image;
    title('Difference x-y');

    subplot(3, 3, 4);
    imagesc(squeeze(actual(:, round(end/2), :)));
    colorbar;
    axis image;
    title('Actual x-z')

    subplot(3, 3, 5);
    imagesc(squeeze(expected(:, round(end/2), :)));
    colorbar;
    axis image;
    title('Expected x-z');

    subplot(3, 3, 6);
    imagesc(squeeze(diff(:, round(end/2), :)));
    colorbar;
    axis image;
    title('Difference x-z');

    subplot(3, 3, 7);
    imagesc(squeeze(actual(round(end/2), :, :)));
    colorbar;
    axis image;
    title('Actual y-z')

    subplot(3, 3, 8);
    imagesc(squeeze(expected(round(end/2), :, :)));
    colorbar;
    axis image;
    title('Expected y-z');

    subplot(3, 3, 9);
    imagesc(squeeze(diff(round(end/2), :, :)));
    colorbar;
    axis image;
    title('Difference y-z');

end

sgtitle(plotTitle);

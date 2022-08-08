function printFigure(h,fname,varargin)
% function printFigure(h,fname,varargin)
%
% INPUTS -
%  h     = figure handle
%  fname = file name to save to
%  varargin = option
%    'orientation' {'landscape',['portrait']}
%    'overwrite' {[1] or 0}, default=1 to overwrite
%    'imgType' {'ps','pdf','png'}
%    'PaperPosition' 1x4 vector of corners
p = inputParser;

p.addRequired('h')
p.addRequired('fname', @ischar)
p.addParamValue('orientation', 'portrait', @(c) strcmp(c,'landscape') | strcmp(c,'portrait'));
p.addParamValue('overwrite', 1, @(c) ismember(c,[1 0]));
p.addParamValue('imgType', 'ps', @ischar);
p.addParamValue('PaperPosition', [0 0 1 1], @(a) length(a)==4);

p.parse(h, fname, varargin{:});
p = p.Results;

set(h,'PaperOrientation',p.orientation);

set(h,'PaperUnits','normalized');
set(h,'PaperPosition',p.PaperPosition);
switch p.imgType
    case 'ps'
        if p.overwrite,  print(h, '-dpsc2', p.fname);
        else  print(h, '-dpsc2', p.fname, '-append'); end
    case 'png'
        if p.overwrite,  print(h, '-dpng', p.fname);
        else  print(h, '-dpng', p.fname, '-append'); end
    case 'pdf'
        if p.overwrite,  print(h, '-dpdf', p.fname);
        else  print(h, '-dpdf', p.fname, '-append'); end
    case 'svg'
        if p.overwrite,  print(h, '-dsvg', p.fname);
        else  print(h, '-dsvg', p.fname, '-append'); end
end
end
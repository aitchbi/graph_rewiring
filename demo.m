% Place FC (or any other graph adjacency matrices) in folder "data" and
% name them FC_<subject>.mat where <subject> is an integer, e.g. FC_1.mat,
% FC_2.mat.

clc
clear 
close all

subject = 1;

d_demo  = fileparts(mfilename("fullpath"));
d_data  = fullfile(d_demo, 'data');
d_utils = fullfile(d_demo, 'utils'); 

addpath(d_utils);

f_fc = fullfile(d_data, sprintf('FC_%d.mat', subject));

d = load(f_fc);
FC = d.FC;

maxswap1 = 10000;

fnames = {'behjat1', 'behjat2', 'betzel1', 'betzel2'};

Nf = length(fnames);

Z = FC;

%-Rewire while preserving degree sequence: Betzel + extension.
%--------------------------------------------------------------------------
XX   = struct;
xtoc = struct;

for k=1:Nf
    fnk = fnames{k};
    basetype = fnk(1:6);
    v1or2 = fnk(end);

    switch v1or2
        case '1'
            maxswap = maxswap1;
        case '2'
            switch basetype
                case 'behjat'
                    maxswap = [];
                case 'betzel'
                    maxswap = maxswap2;
            end
    end

    tic
    switch basetype
        case 'behjat'
            [XX.(fnk), d] = hb_graph_rewire( ...
                Z, ...
                'MaxSwap', maxswap, ...
                'DebugMode', false, ...
                'Verbose', false);
            switch v1or2
                case '2'
                    maxswap2 = d.MaxSwap;
            end

        case 'betzel'
            [~, XX.(fnk)] = fcn_randomize_str_hb( ...
                Z, ...
                'nstage', 100, ...
                'temp', 1000, ...
                'niter', 10000, ...
                'maxswap', maxswap, ...
                'JustGetB0', true);
    end
    xtoc.(fnk)= toc;

end

%-Rewire while preserving degrees + strengths, approximately: Milisav.
%--------------------------------------------------------------------------
Milisav = struct;
Milisav.nstage = 100;
Milisav.temp   = 1000;
Milisav.niter  = 10000;

YY    = struct;
ytoc  = struct;
minE  = struct;
initE = struct;

for k=1:Nf
    fnk = fnames{k};
    tic
    [YY.(fnk), d, minE.(fnk), initE.(fnk)] = fcn_randomize_str_hb( ...
        Z, ...
        'nstage', Milisav.nstage, ...
        'temp', Milisav.temp, ...
        'niter', Milisav.niter, ...
        'B0', XX.(fnk),...
        'verbose', false);
    ytoc.(fnk) = toc;
    assert(isequal(d, XX.(fnk)));
end

%-PLots.
doplots(Z, XX, YY, xtoc, ytoc, maxswap1, maxswap2, minE);
set(gcf, 'Name', sprintf('subject_%d', subject));

%==========================================================================
function doplots(Z,X,Y,xtoc,ytoc,maxswap1,maxswap2,minE)
fnames = fieldnames(X);
assert(isequal(fnames, fieldnames(Y)));

% degrees
D_in      = sum(logical(Z),2);
D_behj1 = sum(logical(X.behjat1),2);
D_behj2 = sum(logical(X.behjat2),2);
D_betz1 = sum(logical(X.betzel1),2);
D_betz2 = sum(logical(X.betzel2),2);

assert(isequal(D_behj1, D_in), 'degree sequence not preserved');
assert(isequal(D_behj2, D_in), 'degree sequence not preserved');
assert(isequal(D_betz1, D_in), 'degree sequence not preserved');
assert(isequal(D_betz2, D_in), 'degree sequence not preserved');

% strengths
S_in    = sum(Z,2);
S_behj1 = sum(Y.behjat1,2);
S_behj2 = sum(Y.behjat2,2);
S_betz1 = sum(Y.betzel1,2);
S_betz2 = sum(Y.betzel2,2);

hf = figure;
set(hf, 'Position', [50 50 1100 900]);

for isbplot = [1 9]
    subplot(4,4,isbplot);
    imagesc(Z);
    axis image;
    xlabel('nodes');
    ylabel('nodes');
    title('original');
    set(gca, 'FontSize',12);
end

% degree sequences
subplot(4,4,[2 3 4]);
stem(D_in, 'Color', [0 0 1], 'MarkerSize',12);
hold on;
stem(D_betz1, 'fill', 'Color', [0 1 1], 'MarkerSize', 9);
stem(D_betz2, 'fill', 'Color', [0 1 0], 'MarkerSize', 7);
stem(D_behj1, 'fill', 'Color', [1 0 0], 'MarkerSize', 5);
stem(D_behj2, 'fill', 'Color', [0 0 0], 'MarkerSize', 2);
legend({'input', 'betz1', 'betz2', 'behj1' 'behj2'}, ...
    'FontSize', 10, ...
    'Location', 'se');
xlabel('nodes');
ylabel('degree');
title('degree sequence');
set(gca, 'FontSize',12);

% strength sequences
subplot(4,4,[10 11 12]); 
stem(S_in, 'Color', [0 0 1], 'MarkerSize',12);
hold on;
stem(S_betz1, 'fill', 'Color', [0 1 1], 'MarkerSize', 9);
stem(S_betz2, 'fill', 'Color', [0 1 0], 'MarkerSize', 7);
stem(S_behj1, 'fill', 'Color', [1 0 0], 'MarkerSize', 5);
stem(S_behj2, 'fill', 'Color', [0 0 0], 'MarkerSize', 2);
legend({'input', 'betz1', 'betz2', 'behj1' 'behj2'}, ...
    'FontSize', 10, ...
    'Location', 'se');
xlabel('nodes');
ylabel('strength');
title('strength sequence');
set(gca, 'FontSize',12);

for k=1:length(fnames)

    fnk = fnames{k};
    basetype = fnk(1:6);
    v1or2 = fnk(end);

    switch v1or2
        case '1'
            maxswap = maxswap1;
        case '2'
            maxswap = maxswap2;
    end

    % degree preserve rewiring
    subplot(4,4, getubplt(v1or2,basetype, 'degree'));
    imagesc(X.(fnk));
    fixplot(basetype, v1or2, maxswap, [], ceil(xtoc.(fnk)), 'degree');

    % strength preserve rewiring
    subplot(4,4, getubplt(v1or2,basetype, 'strength'));
    imagesc(Y.(fnk));
    fixplot(basetype, v1or2, [], minE.(fnk), ceil(ytoc.(fnk)), 'strength');
end
end

%==========================================================================
function y = getubplt(v1or2,basetype,type)
switch type
    case 'degree'
        d = 4;
    case 'strength'
        d = 12;
end
switch basetype
    case 'betzel'
        switch v1or2
            case '1'
                y = d+1;
            case '2'
                y = d+2;
        end
    case 'behjat'
        switch v1or2
            case '1'
                y = d+3;
            case '2'
                y = d+4;
        end
end
end

%==========================================================================
function fixplot(basetype, v1or2, maxswap, minE, t, type)
axis image;
xlabel('nodes');
ylabel('nodes');
colormap pink;
set(gca, 'FontSize',12);
switch type 
    case 'degree'
        title(sprintf('%s preserve (%s)\n swaps: %d | time: %d s', ...
        type, [basetype(1:4) v1or2], maxswap, t));
    case 'strength'
        title(sprintf('%s preserve (%s)\n min E: %0.03f | time: %d s', ...
        type, [basetype(1:4) v1or2], minE, t));
end
end

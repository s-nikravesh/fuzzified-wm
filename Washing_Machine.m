% Fuzzified Washing Machine
% doc fuzzy for more information


clear
clc
close all


%% Constructing FIS and defineing properties
wm = mamfis();  % creating mamdani FIS (class constructor)
wm.Name = 'Fuzzified Washing Machine';  % system name
wm.AndMethod = 'min';  % min or prod
wm.OrMethod = 'max';  % max or probor
wm.ImplicationMethod = 'min';  % min or prod
wm.AggregationMethod = 'max';  % max or sum
wm.DefuzzificationMethod = 'centroid';  % centroid or bisector or mom or 
% lom or som


%% Adding inputs
wm = wm.addInput();  % adding inputs
wm.Inputs(1).Name = 'TOD';  % input name
wm.Inputs(1).Range = [0, 100];  % input range

wm.Inputs(2).Name = 'DOC';
wm.Inputs(2).Range = [0, 100];

wm.Inputs(3).Name = 'MOC';
wm.Inputs(3).Range = [0, 100];


%% Adding Output
wm = wm.addOutput();  % adding output
wm.Outputs(1).Name = 'SpinP';  % output name
wm.Outputs(1).Range = [0, 60];  % output range


%% Adding input membership functions
wm = wm.addMF('TOD', 'trimf', [0, 0, 50], 'name', 'NotGreasy');  % adding
% membership functions to inputs
wm = wm.addMF('TOD', 'trimf', [10, 50, 90], 'name', 'Medium');
wm = wm.addMF('TOD', 'trimf', [50, 100, 100], 'name', 'Greasy');

wm = wm.addMF('DOC', 'trimf', [0, 0, 50], 'name', 'Small');
wm = wm.addMF('DOC', 'trimf', [10, 50, 90], 'name', 'Medium');
wm = wm.addMF('DOC', 'trimf', [50, 100, 100], 'name', 'Large');

wm = wm.addMF('MOC', 'trimf', [0, 0, 50], 'name', 'Light');
wm = wm.addMF('MOC', 'trimf', [10, 50, 90], 'name', 'Medium');
wm = wm.addMF('MOC', 'trimf', [50, 100, 100], 'name', 'Heavy');

%% Adding output membership functions
wm.Outputs(1).MembershipFunction(1).Name = 'VeryShort'; 
wm.Outputs(1).MembershipFunction(1).Type = 'trimf';
wm.Outputs(1).MembershipFunction(1).Parameters = [-14, 6, 23];

wm.Outputs(1).MembershipFunction(2).Name = 'Short';
wm.Outputs(1).MembershipFunction(2).Type = 'trimf';
wm.Outputs(1).MembershipFunction(2).Parameters = [0, 14, 41];

wm.Outputs(1).MembershipFunction(3).Name = 'Medium';
wm.Outputs(1).MembershipFunction(3).Type = 'trimf';
wm.Outputs(1).MembershipFunction(3).Parameters = [11, 30, 45];

wm.Outputs(1).MembershipFunction(4).Name = 'Long';
wm.Outputs(1).MembershipFunction(4).Type = 'trimf';
wm.Outputs(1).MembershipFunction(4).Parameters = [23, 45, 60];

wm.Outputs(1).MembershipFunction(5).Name = 'VeryLong';
wm.Outputs(1).MembershipFunction(5).Type = 'trimf';
wm.Outputs(1).MembershipFunction(5).Parameters = [39, 58, 75];


%% Defineing Rules
R = cell(1, 27);  % preallocation for speed
Spin_Period = {'VeryShort', 'Short', 'Medium', 'Medium', 'Medium', 'Long', ...
            'Medium', 'Medium', 'Long', 'Short', 'Medium', 'Long', 'Medium', ...
            'Long', 'Long', 'Short', 'Long', 'Long', 'Short', 'Medium', 'Long', ...
            'Medium', 'Long', 'VeryLong', 'Medium', 'Long', 'VeryLong'};
c = 0;  % counter
for i = {'NotGreasy', 'Medium', 'Greasy'}
    for j = {'Small', 'Medium', 'Large'}
        for k = {'Light', 'Medium', 'Heavy'}
            c = c + 1;
            R{c} = ['If TOD is ' char(i) ' and DOC is ' char(j) ...
                   ' and MOC is ' char(k) ' then SpinP is ' ...
                   Spin_Period{c}];  % rules
            disp(['Rule ' num2str(c) ': If Type of Dirt is ' char(i) ...
                ' and Dirtiness of Cloth is ' char(j) ...
                ' and Mass of Clothes is ' ...
                char(k) ' then Spin Period is ' Spin_Period{c}])
            disp(newline)
            wm = wm.addRule(R{c});
        end
    end
end


%% Evaluation
ruleview(wm)  % showing rules and changing inputs
plotfis(wm)  % plotting Fuzzified Washing Machine system
surfview(wm)  % plotting FIS surface

figure('name', 'Membership Functions')
subplot(2, 2, 1)
plotmf(wm, 'input', 1)
title('Input(1): Type of Dirt');

subplot(2, 2, 2)
plotmf(wm, 'input', 2)
title('Input(2): Dirtiness of Cloth');

subplot(2, 2, 3)
plotmf(wm, 'input', 3)
title('Input(3): Mass of Clothes');

subplot(2, 2, 4)
plotmf (wm, 'output', 1)
title('Output(1): Spin Period');

n = 10;
A = (0 : n : 100).';
sz = size(A, 1);
In3 = repmat(A, sz^2, 1);

in2 = cell(sz, 1);
in1 = cell(sz, 1);
c=0;
for i = A.'
    c = c + 1;
   in2{c} = i * ones(sz, 1); 
   in1{c} = i * ones(sz^2, 1);
end
In2 = [in2{:}];
In2 = repmat(In2(:), sz, 1);

In1 = [in1{:}];
In1 = In1(:);

Out = evalfis(wm, [In1, In2, In3]);

figure
scatter3(In1, In2, In3, 70, Out, 'filled')
colorbar
colormap jet
xlabel('Type of Dirt');
ylabel('Dirtiness of Cloth');
zlabel('Mass of Clothes');

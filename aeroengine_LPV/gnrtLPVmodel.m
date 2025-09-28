clc
clear
load EngineData

%%
Actuator1 = tf(10, [1 10]);
Actuator1 = c2d(Actuator1, Engine.SimConfig.Ts);
Actuator1.InputName = 'WFM_cmd';
Actuator1.OutputName = 'WFM';

for i = 1:length(Engine.PWLM.SchdOutVec{1}) % 低压转子转速XNLC，也用N1表示

    EngineSS = Engine.PWLM.svm{1, 1, i};

    EngineSS.InputName = Engine.SVM.InName;
    EngineSS.OutputName = Engine.SVM.OutName;
    EngineSS.StateName = Engine.SVM.StateName;

    Plant_lpv(:, :, i) = EngineSS;
end

% 三个调度量马赫数、飞行高度、低压转子转速，本代码中，前两个调度量不考虑变化
[MA_grid, ALT_grid, XNLC_grid] = ndgrid(Engine.PWLM.SchdInVec{1}, Engine.PWLM.SchdInVec{2}, Engine.PWLM.SchdOutVec{1});

Plant_lpv.SamplingGrid = struct('XNLC', XNLC_grid);
lpv_u0 = permute(Engine.PWLM.steadyIn, [1 2 5 3 4]); % [number of 输入, 1, MA, ALT, XNLC]
lpv_y0 = permute(Engine.PWLM.steadyOut, [1 2 5 3 4]);
lpv_x0 = permute(Engine.PWLM.steadyState, [1 2 5 3 4]);

%%
schInd1 = 1; %1对应第一个调度值（70%转速）

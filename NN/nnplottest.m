function nnplottest(nn,fhandle,L,opts,i)
%NNPLOTTEST plots training and missclassification rate
% Plots all coefficients and training error. Used with opts.errfun set to
% @matthew.

%

%    plotting
figure(fhandle);

x_ax = 1:i;     %create axis

if opts.validation == 1
    
    % tranining error plot
    subplot(1,2,1);
    p = plot(x_ax, L.train.e, 'b', ...
        x_ax, L.val.e, 'r');
    legend(p, {'Training', 'Validation'},'Location','NorthEast');
    xlabel('Number of epochs'); ylabel('Error');title('Training Error');
    set(gca, 'Xlim',[0,opts.numepochs + 1])
    %create subplots of correlations
    
    subplot(1,2,2);
    p = plot(x_ax, L.train.e_errfun(:,1), 'b', ...
        x_ax, L.val.e_errfun(:,1),   'm');
    
    
    title('Missclassification rate')
    ylabel('Missclassification'); xlabel('Epoch');
    legend(p, {'Training', 'Validation'},'Location','NorthEast');
    set(gca, 'Xlim',[0,opts.numepochs + 1])
      
else  % no validation
    subplot(1,2,1);
    title('Training Errors')
    p = plot(x_ax,L.train.e,'b');
    legend(p, {'Training'},'Location','NorthEast');
    xlabel('Number of epochs'); ylabel('Error');title('Training Error');
    set(gca, 'Xlim',[0,opts.numepochs + 1])
     
    subplot(1,2,2);
    p = plot(x_ax, L.train.e_errfun(:,1), 'b');
    ylabel('Misclassification'); xlabel('Epoch');
    title('Misclassification rate')
    legend(p, {'Training'},'Location','NorthEast');
    set(gca, 'Xlim',[0,opts.numepochs + 1])
    
end

drawnow;

end
function loss = dnneval_batches(dnn, loss,i,htrain_x, htrain_y, hval_x, hval_y)
%wrapper for dnneval to add support for batch evalulation of perfomance
assert(nargin == 5 || nargin == 7, 'Wrong number of arguments');
if dnn.isGPU  % check if neural network is on gpu or not
    dnnfeedforward = @nnff_gpu;
else
    dnnfeedforward = @nnff;
end

nbatch_train = length(htrain_x);
nbatch_val = length(hval_x);

mtrain = 0;
for j=1:nbatch_train
    batch_size_train(j) = length(htrain_x{j}); 
    mtrain = mtrain+length(htrain_x{j});
end

mval = 0;
for j=1:nbatch_val
    batch_size_val(j) = length(hval_x{j});
    mval = mval+length(hval_x{j});
end

Ltrain = 0;
Lval = 0;



for j = 1:nbatch_train
    dtx = gpuArray(htrain_x{j});
    dty = gpuArray(htrain_y{j});
    
    dnn     = nnfeedforward(nn, dtx, dty);
    current_batch_size = length(dtx);
    Ltrain = Ltrain + dnn_new.L*(current_batch_size/mtrain);
    clear dtx dty
end
loss.train.e(i) =  Ltrain;

if nargin == 6
    for j = 1:nbatch_val
        dvx = gpuArray(hval_x{j});
        dvy = gpuArray(hval_y{j});

        dnn     = nnfeedforward(nn, dvx, dvy);
        current_batch_size = length(dvx);
        Lval = Lval + dnn.L*(current_batch_size/mval);
        clear dvx dvy
    end
end
loss.val.e(i)   =  Lval;

%If error function is supplied apply it
if ~isempty(nn.errfun)
    er_train = 0;
    for j = 1:nbatch_train
        [et, ~, opts_out]     = dnn.errfun(nn, htrain_x{j}, htrain_y{j});
          opts_out_train{i}     = opts_out;
          er_train{j} = et;
    end
    
    for j = 1:nbatch_val
        if nargin == 6
              [et, ~, opts_out]     = dnn.errfun(nn, hval_x{j}, hval_y{j});
              opts_out_val{i}       = opts_out;
              er_val{j} = et;
        end
    end
    
    if isfield(opts, 'errmergefun') && ~isempty(opts.errmergefun)
        loss.train.e_errfun(i,:) = opts.errmergefun(er_train, opts_out_train, batch_size_train);
        loss.val.e_errfun(i,:) = opts.errmergefun(er_val, opts_out_val, batch_size_val);
    else
       for j = 1:numel(er_train)
           loss.train.e_errfun(i,:) = loss.train.e_errfun + er_train{j}*(batch_size_train(j)/mtrain);
       end
       for j = 1:numel(er_val)
           loss.val.e_errfun(i,:) = loss.val.e_errfun + er_val{j}*(batch_size_val(j)/mval);
       end
    end
    
end

end
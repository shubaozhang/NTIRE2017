require 'nn'
require 'cunn'
require 'tvnorm-nn'

local function getLoss(opt)
    local criterion = nn.MultiCriterion()

    if opt.abs > 0 then
        local absLoss = nn.AbsCriterion()
        absLoss.sizeAverage = true
        criterion:add(absLoss, opt.abs)
    end
    if opt.chbn > 0 then
        require('loss/CharbonnierCriterion')
        local chbnLoss = nn.CharbonnierCriterion(true, 0.001)
        criterion:add(chbnLoss, opt.chbn)
    end
    if opt.smoothL1 > 0 then
        local smoothL1 = nn.smoothL1Criterion()
        smoothL1.sizeAverage = true
        criterion:add(smoothL1, opt.smoothL1)
    end
    if opt.mse > 0 then
        local mseLoss = nn.MSECriterion()
        mseLoss.sizeAverage = true  
        if opt.mse > 1 then
            criterion = nn.ParallelCriterion()
            criterion.repeatTarget = true
            for j=2,opt.mse do
                criterion:add(mseLoss, opt.mse)
            end
        end
        criterion:add(mseLoss, opt.mse)
    end
    if opt.ssim > 0 then
        require('loss/SSIMCriterion')
        local ssimLoss = nn.SSIMCriterion()
        criterion:add(ssimLoss, opt.ssim)
    end
    if opt.band > 0 then
        require('loss/BandCriterion')
        local bandLoss = nn.BandCriterion(opt.netwc, opt.lrLow, opt.lrHigh, true)
        criterion:add(bandLoss, opt.band)
    end
    if opt.grad > 0 then
        require('loss/GradCriterion')
        local gradLoss = nn.GradCriterion(opt)
        criterion:add(gradLoss, opt.grad)
    end
    if opt.gradPrior > 0 then
        require('loss/GradPriorCriterion')
        local gradPriorLoss = nn.GradPriorCriterion(opt)
        criterion:add(gradPriorLoss, opt.gradPrior)
    end
    if opt.fd > 0 then
        require('loss/FourierDistCriterion')
        local fdLoss = nn.FilteredDistCriterion(opt, true)
        criterion:add(fdLoss, opt.fd)
    end
    return criterion:cuda()
end

return getLoss

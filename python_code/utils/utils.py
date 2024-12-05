import torch
import torch.nn.functional as F
import torch.nn as nn
import numpy as np
from tqdm import tqdm


def pair_downsampler(img):
    #img has shape B C H W
    c = img.shape[1]

    filter1 = torch.FloatTensor([[[[0 ,0.5],[0.5, 0]]]]).to(img.device)
    filter1 = filter1.repeat(c,1, 1, 1)

    filter2 = torch.FloatTensor([[[[0.5 ,0],[0, 0.5]]]]).to(img.device)
    filter2 = filter2.repeat(c,1, 1, 1)

    output1 = F.conv2d(img, filter1, stride=2, groups=c)
    output2 = F.conv2d(img, filter2, stride=2, groups=c)

    return output1, output2


def mse(gt: torch.Tensor, pred:torch.Tensor)-> torch.Tensor:
    loss = torch.nn.MSELoss()
    return loss(gt,pred)


def loss_func(noisy_img, model, orientation,sigma):
    noisy1, noisy2 = pair_downsampler(noisy_img)

    if orientation == 'noise':
        if sigma == 0:
            pred1 = noisy1 - model(noisy1)
            pred2 = noisy2 - model(noisy2)

            loss_res = 1 / 2 * (mse(noisy1, pred2) + mse(noisy2, pred1))

            noisy_denoised = noisy_img - model(noisy_img)
            denoised1, denoised2 = pair_downsampler(noisy_denoised)

            loss_cons = 1 / 2 * (mse(pred1, denoised1) + mse(pred2, denoised2))

            loss = loss_cons + loss_res
        else:
            pred1 =  noisy1 - model(noisy1)
            pred2 =  noisy2 - model(noisy2)

            loss_res = 1/2*(mse(noisy1,pred2)+mse(noisy2,pred1))

            noisy_denoised =  noisy_img - model(noisy_img)
            denoised1, denoised2 = pair_downsampler(noisy_denoised)

            loss_cons = 1/2*(mse(pred1,denoised1) + mse(pred2,denoised2))

            loss = (loss_cons + loss_res)*1/2 + 1/2 * abs(model(noisy_img).var()-sigma)#+1/2*abs(model(noisy_img).mean()))
    else:
        if sigma == 0:
            pred1 = model(noisy1)
            pred2 = model(noisy2)

            loss_res = 1 / 2 * (mse(noisy1, pred2) + mse(noisy2, pred1))

            noisy_denoised = model(noisy_img)

            denoised1, denoised2 = pair_downsampler(noisy_denoised)

            loss_cons = 1 / 2 * (mse(pred1, denoised1) + mse(pred2, denoised2))

            loss = loss_cons + loss_res
        else:
            pred1 = model(noisy1)
            pred2 = model(noisy2)

            loss_res = 1 / 2 * (mse(noisy1, pred2) + mse(noisy2, pred1))

            noisy_denoised = model(noisy_img)

            denoised1, denoised2 = pair_downsampler(noisy_denoised)

            loss_cons = 1 / 2 * (mse(pred1, denoised1) + mse(pred2, denoised2))

            loss = (loss_cons + loss_res)*1/2 + 1 / 2 *abs((noisy_img-model(noisy_img)).var()-sigma)#+1/2*abs((noisy_img-model(noisy_img)).mean()))

    return loss


def estimate(data):
    # patch segmentation
    [b, _, _, _] = data.shape
    V = torch.zeros([1])
    seg = nn.Unfold(kernel_size=(9, 9), dilation=1, padding=0, stride=1)

    for k in range(b):
        patches = seg(data[k,:,:,:])
        # principal component analysis
        out = torch.cov(patches.squeeze(0))
        L_complex, _ = torch.linalg.eig(out)
        sv = torch.real(L_complex)
        sv, _ = torch.sort(sv, descending=True, dim=0)
        # noise estimate
        for i in range(int(81)):
            t = torch.sum(sv[i:81]) / (81 - i)
            f = int((80 + i) / 2)
            f1 = f - 1
            f2 = min(f + 1, 80)
            if (t <= sv[f1]) and (t >= sv[f2]):
                V = V + t  # torch.sqrt(t)
                break
    return V / b


def train_single_epoch(model, optimizer, noisy_img, orientation,sigma):

  loss = loss_func(noisy_img, model, orientation,sigma)
  out = loss.item()
  optimizer.zero_grad()
  loss.backward()
  optimizer.step()

  return out


def train(model, noisy_img, optimizer, scheduler, max_epoch, orientation,sigma):
    loss = []
    for epoch in range(int(max_epoch)):

        loss_value = train_single_epoch(model, optimizer, noisy_img, orientation,sigma)
        scheduler.step()
        loss.append(loss_value)

    return loss


def denoise(model, noisy_img, orientation):

    with torch.no_grad():
        if orientation == 'noise':
            pred = noisy_img - model(noisy_img)
        else:
            pred = model(noisy_img)

    return pred


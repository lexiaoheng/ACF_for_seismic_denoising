import scipy.io as scio
import torch

from utils.process import *
from utils.utils import *
import numpy as np


config = scio.loadmat('config.mat')
downsampling = config['downsample']

sigma = config['sigma'][0][0]
device = config['device'][0]

chan_embed = 16
layers = 3
max_epoch = 500
bias = 0
orientation = 'noise'

torch.manual_seed(3407)

# global learning
noisy_img = scio.loadmat('./python_code/in/1.mat')['data']


if downsampling == 0:
    noisy_img = torch.Tensor(noisy_img).unsqueeze(0).unsqueeze(0)
    network_param = {'chan_embed': chan_embed, 'layers': layers, 'bias': bias}
    training_param = {'device': device, 'max_epoch': max_epoch, 'lr': 0.001, 'step_size': max_epoch / 3, 'gamma': 0.5,
                      'orientation': orientation, 'sigma': sigma}

    [model_globe, denoised_img, loss] = process(noisy_img, training_param=training_param, network_param=network_param,
                                          model=None)

    denoised_data = denoised_img.cpu().squeeze(0).squeeze(0).numpy()
    scio.savemat('./python_code/out/1.mat', {'data': denoised_data})
    scio.savemat('./loss.mat', {'data': loss, 'params': sum(p.numel() for p in model_globe.parameters())})

else:
    noisy_img = torch.Tensor(noisy_img).unsqueeze(1)
    network_param = {'chan_embed': chan_embed, 'layers': layers, 'bias': bias}
    training_param = {'device': device, 'max_epoch': max_epoch, 'lr': 0.001, 'step_size': max_epoch / 3, 'gamma': 0.5,
                      'orientation': orientation,'sigma': sigma}

    [model_globe, denoised_img, loss] = process(noisy_img, training_param=training_param, network_param=network_param,
                                                model=None)

    denoised_data = denoised_img.cpu().squeeze(1).numpy()
    scio.savemat('./python_code/out/1.mat', {'data': denoised_data})
    scio.savemat('./loss.mat', {'data': loss, 'params': sum(p.numel() for p in model_globe.parameters())})


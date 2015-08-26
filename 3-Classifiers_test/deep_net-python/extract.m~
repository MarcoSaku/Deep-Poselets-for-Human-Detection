
format long
tic
[status,cmdout] = system('python deep_net_256train.py 1.jpg');
timespent2=toc
features256 = textscan(cmdout(2:end-1),'%f64');

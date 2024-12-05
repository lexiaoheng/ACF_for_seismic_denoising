function out = down_sampling(data,flag)

if flag == 'downsmp'
    if length(size(data))==2
        [h,w]=size(data);
        % out  = zeros([4,h/2,w/2]);
        for i=1:1:w/2
            down1(:,i)=data(:,i*2-1);
            down2(:,i)=data(:,i*2);
        end
        for i=1:1:h/2
            out(1,i,:)=down1(i*2-1,:);
            out(2,i,:)=down1(i*2,:);
            out(3,i,:)=down2(i*2-1,:);
            out(4,i,:)=down2(i*2,:);
        end
    else
        [n, h,w]=size(data);
        out  = zeros([4*n,h/2,w/2]);
        for i=1:1:w/2
            down1(:,:,i)=data(:,:,i*2-1);
            down2(:,:,i)=data(:,:,i*2);
        end
        for i=1:1:h/2
            out(1:n,i,:)=down1(:,i*2-1,:);
            out(n+1:2*n,i,:)=down1(:,i*2,:);
            out(2*n+1:3*n,i,:)=down2(:,i*2-1,:);
            out(3*n+1:4*n,i,:)=down2(:,i*2,:);
        end
    end
end

if flag=='reverse'
    [n,h,w]=size(data);
    out = zeros([n/4, 2*h,2*w]);
    for i=1:1:h
         down1(1:n/4,i*2-1,:)=data(1:n/4 ,i,:);
         down1(1:n/4,i*2,:)=data(n/4+1:n/2 ,i,:);
         down2(1:n/4,i*2-1,:)=data(n/2+1:3*n/4 ,i,:);
         down2(1:n/4,i*2,:)=data(3*n/4+1:n ,i,:);
    end

    for i=1:1:w
        out(:,:,i*2-1)=down1(:,:,i);
        out(:,:,i*2)=down2(:,:,i);
    end

     [n,h,w]=size(out);
     if n==1
        out = reshape(out,[h w]);
     end
end

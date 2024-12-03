function TOCs = Make_Request(Demand,TO, TOCs)

% Randomly requests time slots for each TOC


for i=1:TOCs.nTOC
    U=rand(size(TO.w));
    TOCs.data{i,1}=zeros(size(TO.w));
    TOCs.data{i,3}=randi(100,size(TO.w,1),size(TO.w,2));
    b=floor(TOCs.k(i)*size(TO.w,2));
    for s=1:size(TO.w,1)
        ind=randperm(size(TO.w,2),b);
        TOCs.data{i,1}(s, ind)=1;
    end
end

% Impose the feasibility of the solution
TOCs = A(TOCs,TO);

end
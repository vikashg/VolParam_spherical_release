function voxData = MarkBoundaryVer4(voxData, sx, sy, sz, temp_flag)
for i =1:sx
    for j =1:sy
        fill_vals=[];
        for k=1:sz
            if (voxData(i,j,k,2)==temp_flag)
            fill_vals=[fill_vals;k];
            end
        end
    
A=1:sz;
Lia=ismember(A,fill_vals);

        for k1=1:sz-1
            if((Lia(k1) == 0 && Lia(k1+1)==1))
                voxData(i,j,k1,2)=100;
            end
            if (Lia(k1) == 1 && Lia(k1+1) ==0)
                voxData(i,j,k1+1,2)=100;
            end
        end
    end
end


%%
for i=1:sx
    for k=1:sz
        fill_vals=[];
        for j=1:sy
            if (voxData(i,j,k,2)==temp_flag)
                fill_vals=[fill_vals;j];
            end
        end
        
        B=1:sy;
        Lia2=ismember(B,fill_vals);
        
        for j1=1:sy-1
            if ((Lia2(j1) ==0) && (Lia2(j1+1)==1))
                voxData(i,j1,k,2)=100;
            end
            if ((Lia2(j1)==1) && (Lia2(j1+1)==0))
                voxData(i,j1+1,k,2)=100;
            end
        end 
    end
end
%%
for j=1:sy
    for k=1:sz
        fill_vals=[];
        for i =1:sx
            if (voxData(i,j,k,2)==temp_flag)
                fill_vals=[fill_vals;i];
            end
        end
        
        C=1:sx;
        Lia3=ismember(C, fill_vals);
        
        for i1=1:sx-1
            if ((Lia3(i1) ==0) && (Lia3(i1+1)==1))
                voxData(i1,j,k,2)=100;
            end
            if ((Lia3(i1)==1) && Lia3(i1+1) ==0)
                voxData(i1+1,j,k,2)=100;
            end
         end
    end
end



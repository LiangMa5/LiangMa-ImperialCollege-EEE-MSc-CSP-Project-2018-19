% RSMA CoMP JT partial CSIT channel disparity
% Using CVX for optimization (download from: cvxr.com)

function [WMMSE,p_p,p_c] = RS_1layer_CVX_Optimization(SNR,weight,N_bs,N_user,u_opt_c_aveg,u_opt_p_aveg,e_c_aveg,e_p_aveg,f_c_aveg,f_p_aveg,v_c_aveg,v_p_aveg,w_c_aveg,w_p_aveg,Rth)
u1 = weight(1);

%% CVX
cvx_begin quiet
variable p_p(N_bs,N_user) complex
variable p_c(N_bs,1) complex
variable T_c(N_user,1)


%% objective function (i.e. WMMSE)
% ---  WMMSE common message  ---
for i_u = 1:N_user
    for i_sum = 1:N_user
        sum_p(i_sum) = p_p(:,i_sum)' * 0.5*(f_c_aveg(:,:,i_u)+f_c_aveg(:,:,i_u)') *p_p(:,i_sum);
    end
    c(i_u,:) = p_c'*0.5*(f_c_aveg(:,:,i_u)+f_c_aveg(:,:,i_u)')*p_c + sum(sum_p) + e_c_aveg(i_u) - 2*real(v_c_aveg(:,:,i_u)'*p_c)+u_opt_c_aveg(i_u)-w_c_aveg(i_u);
end


% ---  WMMSE Private message  ---
for i_u = 1:N_user
    for i_sum = 1:N_user
        sum_p(i_sum) = p_p(:,i_sum)' * 0.5*(f_p_aveg(:,:,i_u)+f_p_aveg(:,:,i_u)') * p_p(:,i_sum);
    end
    WMMSE_p0(i_u,:) = sum(sum_p) + e_p_aveg(i_u) -2*real(v_p_aveg(:,:,i_u)'*p_p(:,i_u))+u_opt_p_aveg(i_u)-w_p_aveg(i_u);
end
WMMSE0 = T_c + WMMSE_p0; % N_user *1 
WMMSE = sum(WMMSE0);


% ---  WMMSE  ---
minimize(WMMSE)


%% constraiN_bss
P = [p_c,p_p];

subject to

for i0 = 1:N_bs
    sum_square_abs(P(i0,:))-SNR/N_bs <= 0;
    WMMSE0(i0,:) <= 1-Rth;
    c(i0,:) <= 1 + sum(T_c);
    T_c(i0,:) <= 0;
end


cvx_end


end
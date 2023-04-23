clc;
clear;
N = 8;
% samples
x = rand(1, N);
Xgolden = fft(x, N); % -> the real fft values

% bit reversal
x = bitrevorder(x);

% sample buffer
x_buffer = zeros(1, 2*N);
x_buffer(1:2:end) = x;    % Copy even indices

% twiddle_ROM
% even for the real parts odd for the imag parts of the root
k = 0:N-1;
roots = exp(-2*pi*1i*k/N); % cos+isin
twiddle_ROM  = [real(roots); imag(roots)];
twiddle_ROM = twiddle_ROM(:).';  % odd index for the imaganiry part

Wr = twiddle_ROM(1:2:end);
Wi = twiddle_ROM(2:2:end);
 
% complex multiplication
function [real_part, imag_part] = complex_mult(B_r, B_i, W_r, W_i)
    
    real_part = B_r * W_r - B_i * W_i;
    imag_part = B_r * W_i + B_i * W_r;
end

% butterfly
function [BF_A_real, BF_A_imag, BF_B_real, BF_B_imag] = butterfly(A_r, A_i, B_r, B_i, W_r, W_i)
  [mult_real, mult_imag] = complex_mult(B_r, B_i, W_r, W_i);
  BF_A_real = A_r + mult_real;
  BF_A_imag = A_i + mult_imag;
  BF_B_real = A_r - mult_real;
  BF_B_imag = A_i - mult_imag;
end


% Perform N-point FFT
n_stages = log2(N);

% Stage 1
for n=1:2:N-1
    [BF_A_real, BF_A_imag, BF_B_real, BF_B_imag] = butterfly(x_buffer(n), x_buffer(n+1), x_buffer(n+2), x_buffer(n+3), 1, 0);
    x_buffer(n)   = BF_A_real;
    x_buffer(n+1) = BF_A_imag;
    x_buffer(n+2) = BF_B_real;
    x_buffer(n+3) = BF_B_imag;
end
% Stages 2 through log2(N)

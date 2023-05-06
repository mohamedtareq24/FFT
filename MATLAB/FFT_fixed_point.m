clc;
clear;
N = 2;
wl = 18; % word length
fl = 12; % fraction length 
x = rand(1, N);
X = fft(x ,N);
x = bitrevorder(x);  %% will be done using a register 

% sample buffer
x_buffer = zeros(1, 2*N);
x_buffer(1:2:end) = x;    % Copy even indices
x_buffer = fi (x_buffer,1,wl,fl);

% twiddle_ROM
% even for the real parts odd for the imag parts of the root
k = 0:N-1;
roots = exp(-2*pi*1i*k/N); % cos+isin
twiddle_ROM  = [real(roots); imag(roots)];
twiddle_ROM = twiddle_ROM(:).';  % odd index for the imaganiry part
twiddle_ROM_q = fi(twiddle_ROM,1,wl,fl);


for i = 0:log2(N)-1
    for j = 0:N/2-1
        % Generate addresses for data and twiddles
        pntr_a = bitshift(j, 1); % Multiply by 2 using left shift
        pntr_b = pntr_a + 1;
        pntr_a = bitand(bitor(bitshift(pntr_a, i),bitshift(pntr_a, -(log2(N) - i))), N-1); % Address A; 5-bit circular left shif
        pntr_b = bitand(bitor(bitshift(pntr_b, i),bitshift(pntr_b, -(log2(N) - i))), N-1); % Address A; 5-bit circular left shift
        TwAddr = bitand(bitshift((bitshift(uint32(hex2dec('ffffffff')), uint32(log2(N)-1))) , -i), bitand(N/2 - 1, j));
        [BF_A_real, BF_A_imag, BF_B_real, BF_B_imag] = butterfly(x_buffer(pntr_a*2+1),x_buffer(pntr_a*2+2),x_buffer(pntr_b*2+1),x_buffer(pntr_b*2+2),1,0);

        x_buffer(pntr_a*2+1)                 = BF_A_real;
        x_buffer(pntr_a*2+2)                 = BF_A_imag;
        x_buffer(pntr_b*2+1)                 = BF_B_real;
        x_buffer(pntr_b*2+2)                 = BF_B_imag;
    end
end


function [real_part, imag_part] = complex_mult(B_r, B_i, W_r, W_i)
    real_part = B_r * W_r - B_i * W_i;
    imag_part = B_r * W_i + B_i * W_r;
end

function [BF_A_real, BF_A_imag, BF_B_real, BF_B_imag] = butterfly(A_r, A_i, B_r, B_i, W_r, W_i)
  [mult_real, mult_imag] = complex_mult(B_r, B_i, W_r, W_i);
  BF_A_real = A_r + mult_real;
  BF_A_imag = A_i + mult_imag;
  BF_B_real = A_r - mult_real;
  BF_B_imag = A_i - mult_imag;
end


    

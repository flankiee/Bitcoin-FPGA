/*
 * Hash_Block.sv
 * Controlls the actual hashing and storage
*/

import Definitions::*;
module Hash_Block(input logic [31:0] wk,
				  input logic [7:0] round, 
                  input logic [1:0] opcode,
				  input logic clk, start,
				  input c_hash_struct c_hash,
				  
                  output logic [31:0] hash[0:7] );

logic[31:0] intermediate_vals[0:7], temporary_vals[0:2]; //real registers
logic[31:0] sha1_hash_result[0:7], md5_hash_result[0:7], sha256_hash_result[0:7];
logic[31:0] sha1_temp_result[0:2], md5_temp_result[0:2], sha256_temp_result[0:2];

SHA256_Hash_Block s256hf1(
	.a (intermediate_vals[0]),
	.b (intermediate_vals[1]),
	.c (intermediate_vals[2]),
	.d (intermediate_vals[3]),
	.e (intermediate_vals[4]),
	.f (intermediate_vals[5]),
	.g (intermediate_vals[6]),
	.h (intermediate_vals[7]),
	.wk (wk),
	.t0_in (temporary_vals[0]),
	.t1_in (temporary_vals[1]),
	.t2_in (temporary_vals[2]),
	.round (round),
	.round_type (c_hash.round_type),
						  
	.inter_out (sha256_hash_result),
	.temp_out (sha256_temp_result)
);


always_ff @(posedge clk) begin
	
	if (start) begin //we could also bring reset_en into this if need be
				hash[0] <= 32'h6a09e667;
				hash[1] <= 32'hbb67ae85;
				hash[2] <= 32'h3c6ef372;
				hash[3] <= 32'ha54ff53a;
				hash[4] <= 32'h510e527f;
				intermediate_vals[0] <= 32'h6a09e667;
				intermediate_vals[1] <= 32'hbb67ae85;
				intermediate_vals[2] <= 32'h3c6ef372;
				intermediate_vals[3] <= 32'ha54ff53a;
				intermediate_vals[4] <= 32'h510e527f;
	
		//rest of sha256: ignored for other hash functions, so we don't need to puth through logic
		hash[5] <= 32'h9b05688c;
		hash[6] <= 32'h1f83d9ab;
		hash[7] <= 32'h5be0cd19;
		intermediate_vals[5] <= 32'h9b05688c;
		intermediate_vals[6] <= 32'h1f83d9ab;
		intermediate_vals[7] <= 32'h5be0cd19;
		temporary_vals[0] <= 32'd0;
		temporary_vals[1] <= 32'd0;
		temporary_vals[2] <= 32'h6a09e667; //must be 'a'
	
	end
	
	else begin
		if (c_hash.chunk_done) begin
			hash[0] <= intermediate_vals[0] + hash[0];
			hash[1] <= intermediate_vals[1] + hash[1];
			hash[2] <= intermediate_vals[2] + hash[2];
			hash[3] <= intermediate_vals[3] + hash[3];
			hash[4] <= intermediate_vals[4] + hash[4];
			hash[5] <= intermediate_vals[5] + hash[5];
			hash[6] <= intermediate_vals[6] + hash[6];
			hash[7] <= intermediate_vals[7] + hash[7];
			intermediate_vals[0] <= intermediate_vals[0] + hash[0];
			intermediate_vals[1] <= intermediate_vals[1] + hash[1];
			intermediate_vals[2] <= intermediate_vals[2] + hash[2];
			intermediate_vals[3] <= intermediate_vals[3] + hash[3];
			intermediate_vals[4] <= intermediate_vals[4] + hash[4];
			intermediate_vals[5] <= intermediate_vals[5] + hash[5];
			intermediate_vals[6] <= intermediate_vals[6] + hash[6];
			intermediate_vals[7] <= intermediate_vals[7] + hash[7];
			temporary_vals[0] <= 32'd0;
			temporary_vals[1] <= 32'd0;
			temporary_vals[2] <= intermediate_vals[0] + hash[0]; //must be 'a' for 256. must be [2] for md5 to ignore
		end
		

			if (c_hash.enable) begin
					intermediate_vals <= sha256_hash_result;
					temporary_vals <= sha256_temp_result;
		end
	end
	
	
end
  
endmodule

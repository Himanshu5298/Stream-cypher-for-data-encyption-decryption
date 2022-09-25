module prng(input rst_n,
            input clk,
            input load_seed,
            input [7:0] seed_in,
            input encrypt_en,
			output reg [7:0] prng);
				
    localparam SEED = 8'hCD; // default value for the SEED
	
	wire feedback;	
	assign feedback = prng[7] ^ prng[5] ^ prng[4] ^ prng[3];
	
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)
		    prng <= SEED;
        else if (load_seed == 1'b1)
            prng <= seed_in;
	    else if (encrypt_en)
            prng <= {prng[6:0],feedback};	
	end

endmodule


module top_encrypt(input rst_n,
            input clk,
            input load_seed,
            input [7:0] seed_in,
            input encrypt_en,
            input [7:0] data_in,
		    output reg [7:0] data_out);
            
	reg encrypt_en_dly;
	reg [7:0] data_in_dly;
	wire [7:0] prng;

	prng   PRNG(.rst_n     (rst_n     ),
				.clk       (clk       ),
				.load_seed (load_seed ),
				.seed_in   (seed_in   ),
				.encrypt_en(encrypt_en),
				.prng      (prng      )
				);

	// Buffer encrypt_en
	always @(posedge clk or negedge rst_n)
	begin
	   if(!rst_n) begin
		  encrypt_en_dly <=0;
		  data_in_dly    <=0;
	   end else begin
		  encrypt_en_dly   <= encrypt_en;
		  data_in_dly[7:0] <= data_in[7:0];
	   end
	end

	// Encrypt or decrypt the data
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)
		    data_out <=0;
	    else if (encrypt_en_dly)
		    data_out[7:0] <= prng[7:0] ^ data_in_dly[7:0];
	end

endmodule


module top_encrypt_golden(input rst_n,
            input clk,
            input load_seed,
            input [7:0] seed_in,
            input encrypt_en,
            input [7:0] data_in,
		    output reg [7:0] data_out);
       
    localparam SEED = 8'hCD; // default value for the SEED
	   
	reg encrypt_en_dly;
	reg [7:0] data_in_dly;
    reg [7:0] prng;
	
    function [7:0] poly(input[7:0] data_in);
	    reg feedback;
		begin
			feedback = data_in[7] ^ data_in[5] ^ data_in[4] ^ data_in[3];	    
			poly = {data_in[6:0], feedback};
		end
    endfunction 

	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)
		    prng <= SEED;
        else if (load_seed == 1'b1)
            prng <= seed_in;
	    else if (encrypt_en)
            prng <= poly(prng);	
	end

	// Buffer encrypt_en
	always @(posedge clk or negedge rst_n)
	begin
	   if(!rst_n) begin
		  encrypt_en_dly <=0;
		  data_in_dly    <=0;
		  data_out       <=0;
	   end else begin
		  encrypt_en_dly   <= encrypt_en;
		  data_in_dly[7:0] <= data_in[7:0];
		  if (encrypt_en_dly)
		      data_out[7:0] <= prng [7:0] ^ data_in_dly[7:0];
	   end
	end

endmodule

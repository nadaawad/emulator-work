module pKold_prev(clk, input_data, write_enable,memory_output);
	
	parameter number_of_clusters = 1;
	parameter number_of_equations_per_cluster = 9;
	parameter element_width = 32;
	parameter address_width = 20;
	parameter memories_address_width=20;
	
	input wire clk;
	input wire write_enable;
	input wire [element_width*number_of_equations_per_cluster-1:0] input_data;
	
	

	output wire [element_width*number_of_equations_per_cluster-1:0] memory_output;
	
	reg x=0;
	reg [element_width*number_of_equations_per_cluster-1:0] mem [0 : 0];
	// pragma attribute mem ram_block 1
	
	assign memory_output=mem[0];
	
	
	
	always @(posedge clk) 
		begin
			if( write_enable == 1'b1 ) 
				begin
					mem[0] <= input_data; 
				end

			end
			
	

endmodule